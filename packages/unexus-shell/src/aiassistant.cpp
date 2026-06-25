#include "aiassistant.h"

#include "gamemode.h"
#include "systeminfo.h"
#include "systemstats.h"
#include "usersettings.h"

#include <QDir>
#include <QFile>
#include <QFileDevice>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonValue>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QStandardPaths>
#include <QUrl>

AIAssistant::AIAssistant(SystemInfo *systemInfo, SystemStats *stats, GameMode *gameMode, UserSettings *settings, QObject *parent)
    : QObject(parent)
    , m_engine(new AIEngine(this))
    , m_net(new QNetworkAccessManager(this))
    , m_systemInfo(systemInfo)
    , m_stats(stats)
    , m_gameMode(gameMode)
    , m_settings(settings)
{
    connect(m_engine, &AIEngine::engineStarted, this, [this]() {
        setReady(true);
    });
    connect(m_engine, &AIEngine::engineStopped, this, [this]() {
        setReady(false);
        setBusy(false);
    });
    connect(m_engine, &AIEngine::engineError, this, &AIAssistant::errorOccurred);
    if (m_settings) {
        connect(m_settings, &UserSettings::aiHistoryPersistenceEnabledChanged, this, [this]() {
            if (m_settings->aiHistoryPersistenceEnabled()) {
                if (m_history.isEmpty())
                    loadHistoryIfEnabled();
                else
                    persistHistoryIfEnabled();
            } else {
                removePersistedHistory();
            }
        });
    }
    loadHistoryIfEnabled();
}

void AIAssistant::startEngine(const QString &modelPath)
{
    const QString normalizedPath = modelPath.trimmed();
    if (normalizedPath.isEmpty()) {
        emit errorOccurred(QStringLiteral("Choose a local .gguf model before starting uNexus AI."));
        return;
    }

    m_engine->start(normalizedPath);
}

void AIAssistant::stopEngine()
{
    m_engine->stop();
}

void AIAssistant::sendMessage(const QString &userText)
{
    const QString trimmed = userText.trimmed();
    if (trimmed.isEmpty() || m_busy)
        return;

    if (!m_engine->isRunning()) {
        emit errorOccurred(QStringLiteral("Local AI engine is not running."));
        return;
    }

    m_history.append(QStringLiteral("user: ") + trimmed);
    m_currentAssistantResponse.clear();
    m_sseBuffer.clear();
    setBusy(true);

    QJsonArray messages;
    messages.append(QJsonObject{{QStringLiteral("role"), QStringLiteral("system")}, {QStringLiteral("content"), buildSystemPrompt()}});
    for (const QString &line : m_history) {
        const bool assistant = line.startsWith(QStringLiteral("assistant: "));
        messages.append(QJsonObject{
            {QStringLiteral("role"), assistant ? QStringLiteral("assistant") : QStringLiteral("user")},
            {QStringLiteral("content"), assistant ? line.mid(11) : line.mid(6)}
        });
    }

    QJsonObject body;
    body[QStringLiteral("stream")] = true;
    body[QStringLiteral("messages")] = messages;

    const QUrl url(QStringLiteral("http://127.0.0.1:%1/v1/chat/completions").arg(m_engine->port()));
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, QStringLiteral("application/json"));

    QNetworkReply *reply = m_net->post(request, QJsonDocument(body).toJson(QJsonDocument::Compact));
    connect(reply, &QNetworkReply::readyRead, this, [this, reply]() {
        processSseChunk(reply->readAll());
    });
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        if (reply->error() != QNetworkReply::NoError)
            emit errorOccurred(reply->errorString());
        if (!m_currentAssistantResponse.isEmpty()) {
            m_history.append(QStringLiteral("assistant: ") + m_currentAssistantResponse);
            persistHistoryIfEnabled();
        }
        setBusy(false);
        emit responseFinished();
        reply->deleteLater();
    });
}

void AIAssistant::clearHistory()
{
    m_history.clear();
    m_currentAssistantResponse.clear();
    m_sseBuffer.clear();
    removePersistedHistory();
    emit historyCleared();
}

QString AIAssistant::defaultModelDirectory() const
{
    return QDir::home().absoluteFilePath(QStringLiteral(".local/share/unexus/ai/models"));
}

QStringList AIAssistant::installedModelPaths() const
{
    QDir dir(defaultModelDirectory());
    const QStringList fileNames = dir.entryList(QStringList{QStringLiteral("*.gguf")}, QDir::Files, QDir::Name);
    QStringList paths;
    paths.reserve(fileNames.size());
    for (const QString &fileName : fileNames)
        paths << dir.absoluteFilePath(fileName);
    return paths;
}

void AIAssistant::setReady(bool ready)
{
    if (m_ready == ready)
        return;

    m_ready = ready;
    emit readyChanged();
}

void AIAssistant::setBusy(bool busy)
{
    if (m_busy == busy)
        return;

    m_busy = busy;
    emit busyChanged();
}

QString AIAssistant::buildSystemPrompt() const
{
    return QStringLiteral(
        "You are uNexus AI, the local assistant built into uNexus OS. "
        "You run fully offline on the user's machine through a local model. "
        "Help with gaming setup, GPU drivers, performance, shell usage and recovery. "
        "Do not claim that you can access cloud services or send data anywhere. "
        "Be concise, practical and privacy-aware.\n\n"
        "Local system context:\n%1"
    ).arg(gatherLocalSystemContext());
}

QString AIAssistant::gatherLocalSystemContext() const
{
    if (!m_settings || !m_settings->aiSystemContextEnabled())
        return QStringLiteral("(system context disabled by user)");

    QStringList lines;
    if (m_systemInfo) {
        lines << QStringLiteral("GPU: %1").arg(m_systemInfo->gpuName().isEmpty() ? QStringLiteral("unknown") : m_systemInfo->gpuName());
        lines << QStringLiteral("Active driver: %1").arg(m_systemInfo->activeDriver().isEmpty() ? QStringLiteral("unknown") : m_systemInfo->activeDriver());
        lines << QStringLiteral("Recommended GPU drivers: %1").arg(m_systemInfo->recommendedGpuDrivers().isEmpty() ? QStringLiteral("unknown") : m_systemInfo->recommendedGpuDrivers());
        lines << QStringLiteral("Kernel: %1").arg(m_systemInfo->kernelVersion().isEmpty() ? QStringLiteral("unknown") : m_systemInfo->kernelVersion());
        lines << QStringLiteral("Mesa: %1").arg(m_systemInfo->mesaVersion().isEmpty() ? QStringLiteral("unknown") : m_systemInfo->mesaVersion());
    }

    if (m_stats) {
        lines << QStringLiteral("CPU usage: %1%").arg(m_stats->cpuUsage());
        lines << QStringLiteral("RAM usage: %1%").arg(m_stats->ramUsage());
        lines << QStringLiteral("GPU usage: %1").arg(m_stats->hasGpuStats() ? QStringLiteral("%1%").arg(m_stats->gpuUsage()) : QStringLiteral("unavailable"));
        lines << QStringLiteral("GPU temperature: %1").arg(m_stats->hasGpuTemp() ? QStringLiteral("%1 C").arg(m_stats->gpuTemp()) : QStringLiteral("unavailable"));
    }

    if (m_gameMode)
        lines << QStringLiteral("Game Mode active: %1").arg(m_gameMode->active() ? QStringLiteral("yes") : QStringLiteral("no"));

    lines << QStringLiteral("This context was read locally and is never transmitted outside this device.");
    return lines.join(QLatin1Char('\n'));
}

void AIAssistant::processSseChunk(const QByteArray &chunk)
{
    m_sseBuffer += QString::fromUtf8(chunk);
    m_sseBuffer.replace(QStringLiteral("\r\n"), QStringLiteral("\n"));

    int sepIndex = -1;
    while ((sepIndex = m_sseBuffer.indexOf(QStringLiteral("\n\n"))) != -1) {
        const QString event = m_sseBuffer.left(sepIndex);
        m_sseBuffer.remove(0, sepIndex + 2);

        const QStringList lines = event.split(QLatin1Char('\n'));
        for (const QString &rawLine : lines) {
            const QString line = rawLine.trimmed();
            if (!line.startsWith(QStringLiteral("data:")))
                continue;

            const QString payload = line.mid(5).trimmed();
            if (payload.isEmpty() || payload == QStringLiteral("[DONE]"))
                continue;

            QJsonParseError parseError;
            const QJsonDocument document = QJsonDocument::fromJson(payload.toUtf8(), &parseError);
            if (parseError.error != QJsonParseError::NoError || !document.isObject())
                continue;

            const QJsonArray choices = document.object().value(QStringLiteral("choices")).toArray();
            if (choices.isEmpty())
                continue;

            const QJsonObject delta = choices.first().toObject().value(QStringLiteral("delta")).toObject();
            const QString token = delta.value(QStringLiteral("content")).toString();
            if (!token.isEmpty()) {
                m_currentAssistantResponse += token;
                emit tokenReceived(token);
            }
        }
    }
}

void AIAssistant::persistHistoryIfEnabled() const
{
    if (!m_settings || !m_settings->aiHistoryPersistenceEnabled())
        return;

    const QString dirPath = QDir::home().absoluteFilePath(QStringLiteral(".local/share/unexus/ai"));
    QDir().mkpath(dirPath);
    QFile file(historyFilePath());
    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate | QIODevice::Text))
        return;

    QJsonArray items;
    for (const QString &line : m_history) {
        const bool assistant = line.startsWith(QStringLiteral("assistant: "));
        const bool user = line.startsWith(QStringLiteral("user: "));
        if (!assistant && !user)
            continue;

        items.append(QJsonObject{
            {QStringLiteral("role"), assistant ? QStringLiteral("assistant") : QStringLiteral("user")},
            {QStringLiteral("content"), assistant ? line.mid(11) : line.mid(6)}
        });
    }

    file.setPermissions(QFileDevice::ReadOwner | QFileDevice::WriteOwner);
    file.write(QJsonDocument(items).toJson(QJsonDocument::Indented));
}

void AIAssistant::removePersistedHistory() const
{
    QFile::remove(historyFilePath());
    QFile::remove(QDir::home().absoluteFilePath(QStringLiteral(".local/share/unexus/ai/history.txt")));
}

void AIAssistant::loadHistoryIfEnabled()
{
    if (!m_settings || !m_settings->aiHistoryPersistenceEnabled())
        return;

    QFile file(historyFilePath());
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return;

    QJsonParseError parseError;
    const QJsonDocument document = QJsonDocument::fromJson(file.readAll(), &parseError);
    if (parseError.error != QJsonParseError::NoError || !document.isArray())
        return;

    m_history.clear();
    const QJsonArray items = document.array();
    for (const QJsonValue &value : items) {
        const QJsonObject item = value.toObject();
        const QString role = item.value(QStringLiteral("role")).toString();
        const QString content = item.value(QStringLiteral("content")).toString().trimmed();
        if (content.isEmpty())
            continue;

        if (role == QStringLiteral("assistant"))
            m_history.append(QStringLiteral("assistant: ") + content);
        else if (role == QStringLiteral("user"))
            m_history.append(QStringLiteral("user: ") + content);
    }
}

QString AIAssistant::historyFilePath() const
{
    return QDir::home().absoluteFilePath(QStringLiteral(".local/share/unexus/ai/history.json"));
}
