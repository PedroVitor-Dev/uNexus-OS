#include "commandrunner.h"

#include <QDir>
#include <QProcessEnvironment>

CommandRunner::CommandRunner(QObject *parent)
    : QObject(parent),
      m_workingDirectory(QDir::homePath())
{
    connect(&m_process, &QProcess::readyReadStandardOutput, this, &CommandRunner::readOutput);
    connect(&m_process, &QProcess::readyReadStandardError, this, &CommandRunner::readOutput);
    connect(&m_process, &QProcess::finished, this, &CommandRunner::processFinished);
    connect(&m_process, &QProcess::errorOccurred, this, &CommandRunner::processError);
    m_process.setProcessChannelMode(QProcess::MergedChannels);
}

void CommandRunner::setWorkingDirectory(const QString &directory)
{
    const QString normalized = directory.trimmed().isEmpty() ? QDir::homePath() : QDir::cleanPath(directory);
    if (m_workingDirectory == normalized)
        return;

    m_workingDirectory = normalized;
    emit workingDirectoryChanged();
}

void CommandRunner::run(const QString &command)
{
    const QString trimmed = command.trimmed();
    if (m_busy || trimmed.isEmpty())
        return;

    if (trimmed == QStringLiteral("clear")) {
        clear();
        return;
    }

    if (trimmed == QStringLiteral("cd") || trimmed.startsWith(QStringLiteral("cd "))) {
        QString target = trimmed == QStringLiteral("cd") ? QDir::homePath() : trimmed.mid(3).trimmed();
        if (target == QStringLiteral("~"))
            target = QDir::homePath();
        else if (target.startsWith(QStringLiteral("~/")))
            target = QDir::home().absoluteFilePath(target.mid(2));

        QDir dir(target.startsWith(QLatin1Char('/')) ? target : QDir(m_workingDirectory).absoluteFilePath(target));
        if (dir.exists()) {
            setWorkingDirectory(dir.absolutePath());
            appendOutput(QStringLiteral("$ %1\n").arg(trimmed));
            return;
        }
        appendOutput(QStringLiteral("$ %1\ncd: no such directory: %2\n").arg(trimmed, target));
        return;
    }

    appendOutput(QStringLiteral("$ %1\n").arg(trimmed));
    setBusy(true);

    QProcessEnvironment environment = QProcessEnvironment::systemEnvironment();
    environment.insert(QStringLiteral("UNEXUS_CMD"), QStringLiteral("1"));
    m_process.setProcessEnvironment(environment);
    m_process.setWorkingDirectory(m_workingDirectory);

    const QString shell = environment.value(QStringLiteral("SHELL"), QStringLiteral("/bin/sh"));
    m_process.start(shell, {QStringLiteral("-lc"), trimmed});
}

void CommandRunner::stop()
{
    if (!m_busy)
        return;

    m_process.terminate();
    if (!m_process.waitForFinished(1200))
        m_process.kill();
}

void CommandRunner::clear()
{
    m_output.clear();
    emit outputChanged();
}

void CommandRunner::readOutput()
{
    appendOutput(QString::fromLocal8Bit(m_process.readAll()));
}

void CommandRunner::processFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
    readOutput();
    appendOutput(QStringLiteral("[exit %1%2]\n")
        .arg(exitCode)
        .arg(exitStatus == QProcess::CrashExit ? QStringLiteral(", crashed") : QString()));
    setBusy(false);
}

void CommandRunner::processError(QProcess::ProcessError error)
{
    appendOutput(QStringLiteral("process error: %1\n").arg(m_process.errorString()));
    if (error == QProcess::FailedToStart)
        setBusy(false);
}

void CommandRunner::setBusy(bool busy)
{
    if (m_busy == busy)
        return;

    m_busy = busy;
    emit busyChanged();
}

void CommandRunner::appendOutput(const QString &text)
{
    if (text.isEmpty())
        return;

    m_output += text;
    emit outputChanged();
}
