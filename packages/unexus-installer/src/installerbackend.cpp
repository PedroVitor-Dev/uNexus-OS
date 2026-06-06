#include "installerbackend.h"

#include <QCoreApplication>
#include <QDir>
#include <QFileInfo>
#include <QProcessEnvironment>
#include <QStandardPaths>

InstallerBackend::InstallerBackend(QObject *parent)
    : QObject(parent)
{
    connect(&m_process, &QProcess::readyReadStandardOutput, this, &InstallerBackend::readOutput);
    connect(&m_process, &QProcess::readyReadStandardError, this, &InstallerBackend::readOutput);
    connect(&m_process, &QProcess::finished, this, &InstallerBackend::processFinished);
    connect(&m_process, &QProcess::errorOccurred, this, &InstallerBackend::processError);

    refresh();
    setStatus(m_installed ? QStringLiteral("uNexus is installed") : QStringLiteral("Ready to install"),
              m_installed ? QStringLiteral("Repair, diagnose or remove the local session.")
                          : QStringLiteral("Install the shell session from this repository."));
}

bool InstallerBackend::busy() const
{
    return m_busy;
}

QString InstallerBackend::currentAction() const
{
    return m_currentAction;
}

QString InstallerBackend::statusTitle() const
{
    return m_statusTitle;
}

QString InstallerBackend::statusDetail() const
{
    return m_statusDetail;
}

QString InstallerBackend::logText() const
{
    return m_logText;
}

bool InstallerBackend::installed() const
{
    return m_installed;
}

bool InstallerBackend::pkexecAvailable() const
{
    return commandExists(QStringLiteral("pkexec"));
}

bool InstallerBackend::setupAvailable() const
{
    return QFileInfo::exists(scriptPath(QStringLiteral("setup.sh"))) &&
           QFileInfo::exists(scriptPath(QStringLiteral("uninstall.sh")));
}

bool InstallerBackend::diagnosticsAvailable() const
{
    return !QStandardPaths::findExecutable(QStringLiteral("unexus-doctor")).isEmpty() ||
           QFileInfo::exists(scriptPath(QStringLiteral("unexus-doctor.sh")));
}

QString InstallerBackend::repoRoot() const
{
#ifdef UNEXUS_REPO_ROOT
    return QString::fromUtf8(UNEXUS_REPO_ROOT);
#else
    QDir dir(QCoreApplication::applicationDirPath());
    for (int i = 0; i < 5; ++i) {
        if (dir.exists(QStringLiteral("scripts/setup.sh")) &&
            dir.exists(QStringLiteral("packages/unexus-shell/CMakeLists.txt"))) {
            return dir.absolutePath();
        }
        if (!dir.cdUp())
            break;
    }
    return QDir::currentPath();
#endif
}

void InstallerBackend::install()
{
    runAction(QStringLiteral("install"),
              QStringLiteral("Installing uNexus"),
              {QStringLiteral("pkexec"), QStringLiteral("sh"), scriptPath(QStringLiteral("setup.sh"))});
}

void InstallerBackend::repair()
{
    runAction(QStringLiteral("repair"),
              QStringLiteral("Repairing uNexus"),
              {QStringLiteral("pkexec"), QStringLiteral("sh"), scriptPath(QStringLiteral("setup.sh"))});
}

void InstallerBackend::diagnose()
{
    const QString installedDoctor = QStandardPaths::findExecutable(QStringLiteral("unexus-doctor"));
    if (!installedDoctor.isEmpty()) {
        runAction(QStringLiteral("diagnose"),
                  QStringLiteral("Running diagnostics"),
                  {installedDoctor});
        return;
    }

    runAction(QStringLiteral("diagnose"),
              QStringLiteral("Running diagnostics"),
              {QStringLiteral("sh"), scriptPath(QStringLiteral("unexus-doctor.sh"))});
}

void InstallerBackend::uninstall()
{
    runAction(QStringLiteral("uninstall"),
              QStringLiteral("Removing uNexus"),
              {QStringLiteral("pkexec"), QStringLiteral("sh"), scriptPath(QStringLiteral("uninstall.sh"))});
}

void InstallerBackend::refresh()
{
    const bool wasInstalled = m_installed;
    m_installed = !QStandardPaths::findExecutable(QStringLiteral("unexus-shell")).isEmpty() ||
                  QFileInfo::exists(QStringLiteral("/usr/bin/unexus-shell"));

    if (wasInstalled != m_installed)
        emit installedChanged();

    emit prerequisitesChanged();
}

void InstallerBackend::clearLog()
{
    m_logText.clear();
    emit logChanged();
}

void InstallerBackend::readOutput()
{
    appendLog(QString::fromLocal8Bit(m_process.readAllStandardOutput()));
    appendLog(QString::fromLocal8Bit(m_process.readAllStandardError()));
}

void InstallerBackend::processFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
    readOutput();
    setBusy(false);

    const QString finishedAction = m_currentAction;
    const bool ok = exitStatus == QProcess::NormalExit && exitCode == 0;
    refresh();

    if (ok) {
        if (finishedAction == QStringLiteral("diagnose")) {
            setStatus(QStringLiteral("Diagnostics complete"),
                      QStringLiteral("Diagnostics finished without reported failures."));
        } else if (finishedAction == QStringLiteral("uninstall")) {
            setStatus(QStringLiteral("uNexus removed"),
                      QStringLiteral("The local shell session and launcher entries were removed."));
        } else if (finishedAction == QStringLiteral("repair")) {
            setStatus(QStringLiteral("Repair complete"),
                      QStringLiteral("The local shell session was rebuilt, reinstalled and validated."));
        } else {
            setStatus(QStringLiteral("uNexus installed"),
                      QStringLiteral("The local shell session was built, installed and validated."));
        }
    } else {
        setStatus(exitStatus == QProcess::CrashExit ? QStringLiteral("Action crashed") : QStringLiteral("Action failed"),
                  QStringLiteral("Review the backend log and retry after resolving the reported issue."));
    }

    setCurrentAction(QString());
}

void InstallerBackend::processError(QProcess::ProcessError error)
{
    appendLog(QStringLiteral("Process error: %1\n").arg(m_process.errorString()));

    if (error != QProcess::FailedToStart)
        return;

    setBusy(false);
    setStatus(QStringLiteral("Could not start action"),
              QStringLiteral("The installer backend process did not start."));
    setCurrentAction(QString());
}

void InstallerBackend::runAction(const QString &action, const QString &title, const QStringList &programAndArguments)
{
    if (m_busy || programAndArguments.isEmpty())
        return;

    if (action == QStringLiteral("diagnose") && !diagnosticsAvailable()) {
        setStatus(QStringLiteral("Diagnostics unavailable"),
                  QStringLiteral("Install uNexus first or run this installer from a complete repository checkout."));
        return;
    }

    if (!setupAvailable() && action != QStringLiteral("diagnose")) {
        setStatus(QStringLiteral("Installer files missing"),
                  QStringLiteral("Run this installer from a complete uNexus repository checkout."));
        return;
    }

    if ((action == QStringLiteral("install") ||
         action == QStringLiteral("repair") ||
         action == QStringLiteral("uninstall")) && !pkexecAvailable()) {
        setStatus(QStringLiteral("pkexec unavailable"),
                  QStringLiteral("Install polkit or use sudo sh scripts/setup.sh from a terminal."));
        return;
    }

    clearLog();
    setCurrentAction(action);
    setStatus(title, QStringLiteral("Waiting for authorization and backend output."));
    setBusy(true);

    QProcessEnvironment environment = QProcessEnvironment::systemEnvironment();
    environment.insert(QStringLiteral("UNEXUS_INSTALLER"), QStringLiteral("1"));
    m_process.setProcessEnvironment(environment);
    m_process.setWorkingDirectory(repoRoot());
    m_process.start(programAndArguments.first(), programAndArguments.mid(1));

    if (!m_process.waitForStarted(3000)) {
        appendLog(m_process.errorString() + QStringLiteral("\n"));
        setBusy(false);
        setStatus(QStringLiteral("Could not start action"),
                  QStringLiteral("The installer backend process did not start."));
        setCurrentAction(QString());
    }
}

void InstallerBackend::setBusy(bool busy)
{
    if (m_busy == busy)
        return;

    m_busy = busy;
    emit busyChanged();
}

void InstallerBackend::setCurrentAction(const QString &action)
{
    if (m_currentAction == action)
        return;

    m_currentAction = action;
    emit currentActionChanged();
}

void InstallerBackend::setStatus(const QString &title, const QString &detail)
{
    if (m_statusTitle == title && m_statusDetail == detail)
        return;

    m_statusTitle = title;
    m_statusDetail = detail;
    emit statusChanged();
}

void InstallerBackend::appendLog(const QString &text)
{
    if (text.isEmpty())
        return;

    m_logText += text;
    emit logChanged();
}

QString InstallerBackend::scriptPath(const QString &name) const
{
    return QDir(repoRoot()).filePath(QStringLiteral("scripts/") + name);
}

bool InstallerBackend::commandExists(const QString &command)
{
    return !QStandardPaths::findExecutable(command).isEmpty();
}
