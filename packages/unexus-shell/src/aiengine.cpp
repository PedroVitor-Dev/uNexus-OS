#include "aiengine.h"

#include <QCoreApplication>
#include <QFile>
#include <QHostAddress>
#include <QProcessEnvironment>
#include <QStandardPaths>
#include <QTcpServer>

AIEngine::AIEngine(QObject *parent)
    : QObject(parent)
{
}

AIEngine::~AIEngine()
{
    stop();
}

quint16 AIEngine::pickFreeLoopbackPort() const
{
    QTcpServer probe;
    if (!probe.listen(QHostAddress::LocalHost, 0))
        return 0;

    const quint16 port = probe.serverPort();
    probe.close();
    return port;
}

QString AIEngine::findLlamaServerBinary() const
{
    const QStringList candidates = {
        QCoreApplication::applicationDirPath() + QStringLiteral("/ai/llama-server"),
        QStringLiteral("/usr/lib/unexus/ai/llama-server"),
        QStringLiteral("/usr/bin/llama-server")
    };

    for (const QString &path : candidates) {
        if (QFile::exists(path))
            return path;
    }

    return QStandardPaths::findExecutable(QStringLiteral("llama-server"));
}

bool AIEngine::start(const QString &modelPath)
{
    if (isRunning())
        return true;

    const QString binary = findLlamaServerBinary();
    if (binary.isEmpty()) {
        emit engineError(QStringLiteral("llama-server was not found. Install llama.cpp or add a bundled runtime."));
        return false;
    }

    if (!QFile::exists(modelPath)) {
        emit engineError(QStringLiteral("Local GGUF model file was not found."));
        return false;
    }

    m_port = pickFreeLoopbackPort();
    if (m_port == 0) {
        emit engineError(QStringLiteral("Could not allocate a private loopback port for the AI engine."));
        return false;
    }

    m_process = new QProcess(this);
    m_process->setProcessChannelMode(QProcess::MergedChannels);

    QProcessEnvironment environment = QProcessEnvironment::systemEnvironment();
    environment.remove(QStringLiteral("http_proxy"));
    environment.remove(QStringLiteral("https_proxy"));
    environment.remove(QStringLiteral("HTTP_PROXY"));
    environment.remove(QStringLiteral("HTTPS_PROXY"));
    environment.insert(QStringLiteral("UNEXUS_AI_LOCAL_ONLY"), QStringLiteral("1"));
    m_process->setProcessEnvironment(environment);

    connect(m_process, &QProcess::errorOccurred, this, [this](QProcess::ProcessError) {
        emit engineError(m_process ? m_process->errorString() : QStringLiteral("AI engine process error"));
    });
    connect(m_process, &QProcess::finished, this, [this](int, QProcess::ExitStatus) {
        QProcess *finishedProcess = m_process;
        m_process = nullptr;
        m_port = 0;
        if (finishedProcess)
            finishedProcess->deleteLater();
        emit engineStopped();
    });

    const QStringList args = {
        QStringLiteral("-m"), modelPath,
        QStringLiteral("--host"), QStringLiteral("127.0.0.1"),
        QStringLiteral("--port"), QString::number(m_port),
        QStringLiteral("-c"), QStringLiteral("4096"),
        QStringLiteral("--no-webui")
    };

    m_process->start(binary, args);
    if (!m_process->waitForStarted(3000)) {
        emit engineError(QStringLiteral("Failed to start local AI engine."));
        m_process->deleteLater();
        m_process = nullptr;
        m_port = 0;
        return false;
    }

    emit engineStarted();
    return true;
}

void AIEngine::stop()
{
    if (!m_process)
        return;

    QProcess *process = m_process;
    m_process = nullptr;
    disconnect(process, nullptr, this, nullptr);
    process->terminate();
    if (!process->waitForFinished(2000))
        process->kill();
    process->deleteLater();
    m_port = 0;
    emit engineStopped();
}

bool AIEngine::isRunning() const
{
    return m_process && m_process->state() == QProcess::Running;
}
