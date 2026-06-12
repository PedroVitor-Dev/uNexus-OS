#include "installerbackend.h"

#include <QCoreApplication>
#include <QDir>
#include <QFileInfo>
#include <QProcessEnvironment>
#include <QStandardPaths>
#include <QVariantMap>

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
           QFileInfo::exists(scriptPath(QStringLiteral("install-system.sh"))) &&
           QFileInfo::exists(scriptPath(QStringLiteral("provision-system.sh"))) &&
           QFileInfo::exists(scriptPath(QStringLiteral("uninstall.sh")));
}

bool InstallerBackend::diagnosticsAvailable() const
{
    return !QStandardPaths::findExecutable(QStringLiteral("unexus-doctor")).isEmpty() ||
           QFileInfo::exists(scriptPath(QStringLiteral("unexus-doctor.sh")));
}

bool InstallerBackend::canInstall() const
{
    return pkexecAvailable() && setupAvailable();
}

int InstallerBackend::progress() const
{
    if (m_busy)
        return m_progress;

    if (m_installed)
        return 100;

    return setupAvailable() ? 20 : 0;
}

QVariantList InstallerBackend::readinessChecks() const
{
    QVariantList checks;
    checks << checkItem(QStringLiteral("Repository"),
                        setupAvailable() ? QStringLiteral("setup and uninstall scripts found")
                                         : QStringLiteral("missing setup or uninstall scripts"),
                        setupAvailable() ? QStringLiteral("ready") : QStringLiteral("blocked"));
    checks << checkItem(QStringLiteral("Authorization"),
                        pkexecAvailable() ? QStringLiteral("pkexec available")
                                          : QStringLiteral("polkit pkexec is required for graphical install"),
                        pkexecAvailable() ? QStringLiteral("ready") : QStringLiteral("blocked"));
    checks << checkItem(QStringLiteral("Diagnostics"),
                        diagnosticsAvailable() ? QStringLiteral("doctor command available")
                                               : QStringLiteral("diagnostics will be available after install"),
                        diagnosticsAvailable() ? QStringLiteral("ready") : QStringLiteral("warning"));
    checks << checkItem(QStringLiteral("Current install"),
                        installed() ? QStringLiteral("uNexus shell detected")
                                    : QStringLiteral("not installed yet"),
                        installed() ? QStringLiteral("ready") : QStringLiteral("warning"));
    checks << checkItem(QStringLiteral("Provisioning"),
                        setupAvailable() ? QStringLiteral("user, bootloader, Hyprland, Flathub, GameMode and launchers available")
                                         : QStringLiteral("provisioning script missing"),
                        setupAvailable() ? QStringLiteral("ready") : QStringLiteral("blocked"));
    return checks;
}

QVariantList InstallerBackend::installSteps() const
{
    const bool installing = m_busy && (m_currentAction == QStringLiteral("install") ||
                                      m_currentAction == QStringLiteral("repair"));

    QVariantList steps;
    steps << stepItem(QStringLiteral("Authorize"),
                      QStringLiteral("Request administrator permission through pkexec."),
                      installing ? QStringLiteral("running") : (m_installed ? QStringLiteral("done") : QStringLiteral("pending")));
    steps << stepItem(QStringLiteral("Build"),
                      QStringLiteral("Configure and compile the Qt/QML shell with CMake."),
                      installing ? QStringLiteral("running") : (m_installed ? QStringLiteral("done") : QStringLiteral("pending")));
    steps << stepItem(QStringLiteral("Install session"),
                      QStringLiteral("Install session launchers, desktop entries and shell assets."),
                      installing ? QStringLiteral("running") : (m_installed ? QStringLiteral("done") : QStringLiteral("pending")));
    steps << stepItem(QStringLiteral("Provision system"),
                      QStringLiteral("Configure user groups, Hyprland defaults, Flathub, GameMode, MangoHud and launchers."),
                      installing ? QStringLiteral("running") : (m_installed ? QStringLiteral("done") : QStringLiteral("pending")));
    steps << stepItem(QStringLiteral("Bootloader"),
                      QStringLiteral("Prepare safe uNexus boot defaults and write a systemd-boot entry when detected."),
                      installing ? QStringLiteral("running") : (m_installed ? QStringLiteral("done") : QStringLiteral("pending")));
    steps << stepItem(QStringLiteral("Validate"),
                      QStringLiteral("Run uNexus Doctor and initialize user state."),
                      m_busy ? QStringLiteral("pending") : (m_installed ? QStringLiteral("done") : QStringLiteral("pending")));
    return steps;
}

bool InstallerBackend::installGamingLaunchers() const
{
    return m_installGamingLaunchers;
}

bool InstallerBackend::configureBootloader() const
{
    return m_configureBootloader;
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
              {QStringLiteral("pkexec"), QStringLiteral("sh"), scriptPath(QStringLiteral("install-system.sh"))});
}

void InstallerBackend::repair()
{
    runAction(QStringLiteral("repair"),
              QStringLiteral("Repairing uNexus"),
              {QStringLiteral("pkexec"), QStringLiteral("sh"), scriptPath(QStringLiteral("install-system.sh"))});
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
    emit progressChanged();
    emit installStepsChanged();
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

    if (m_busy && m_progress < 92) {
        m_progress += 3;
        if (m_progress > 92)
            m_progress = 92;
        emit progressChanged();
    }
}

void InstallerBackend::processFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
    readOutput();
    const bool ok = exitStatus == QProcess::NormalExit && exitCode == 0;
    setBusy(false);
    m_progress = ok ? 100 : 0;
    emit progressChanged();

    const QString finishedAction = m_currentAction;
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
    emit installStepsChanged();
}

void InstallerBackend::processError(QProcess::ProcessError error)
{
    appendLog(QStringLiteral("Process error: %1\n").arg(m_process.errorString()));

    if (error != QProcess::FailedToStart)
        return;

    setBusy(false);
    m_progress = 0;
    emit progressChanged();
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
    m_progress = action == QStringLiteral("diagnose") ? 35 : 45;
    emit progressChanged();
    emit installStepsChanged();
    setBusy(true);

    QProcessEnvironment environment = QProcessEnvironment::systemEnvironment();
    environment.insert(QStringLiteral("UNEXUS_INSTALLER"), QStringLiteral("1"));
    environment.insert(QStringLiteral("UNEXUS_INSTALL_GAMING_LAUNCHERS"), m_installGamingLaunchers ? QStringLiteral("1") : QStringLiteral("0"));
    environment.insert(QStringLiteral("UNEXUS_CONFIGURE_BOOTLOADER"), m_configureBootloader ? QStringLiteral("1") : QStringLiteral("0"));
    m_process.setProcessEnvironment(environment);
    m_process.setWorkingDirectory(repoRoot());
    m_process.start(programAndArguments.first(), programAndArguments.mid(1));

    if (!m_process.waitForStarted(3000)) {
        appendLog(m_process.errorString() + QStringLiteral("\n"));
        setBusy(false);
        m_progress = 0;
        emit progressChanged();
        setStatus(QStringLiteral("Could not start action"),
                  QStringLiteral("The installer backend process did not start."));
        setCurrentAction(QString());
        emit installStepsChanged();
    }
}

void InstallerBackend::setBusy(bool busy)
{
    if (m_busy == busy)
        return;

    m_busy = busy;
    emit busyChanged();
    emit installStepsChanged();
}

void InstallerBackend::setCurrentAction(const QString &action)
{
    if (m_currentAction == action)
        return;

    m_currentAction = action;
    emit currentActionChanged();
    emit installStepsChanged();
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

void InstallerBackend::setInstallGamingLaunchers(bool enabled)
{
    if (m_installGamingLaunchers == enabled)
        return;

    m_installGamingLaunchers = enabled;
    emit optionsChanged();
}

void InstallerBackend::setConfigureBootloader(bool enabled)
{
    if (m_configureBootloader == enabled)
        return;

    m_configureBootloader = enabled;
    emit optionsChanged();
}

QVariantMap InstallerBackend::checkItem(const QString &label, const QString &value, const QString &status) const
{
    QVariantMap item;
    item.insert(QStringLiteral("label"), label);
    item.insert(QStringLiteral("value"), value);
    item.insert(QStringLiteral("status"), status);
    return item;
}

QVariantMap InstallerBackend::stepItem(const QString &label, const QString &detail, const QString &status) const
{
    QVariantMap item;
    item.insert(QStringLiteral("label"), label);
    item.insert(QStringLiteral("detail"), detail);
    item.insert(QStringLiteral("status"), status);
    return item;
}

bool InstallerBackend::commandExists(const QString &command)
{
    return !QStandardPaths::findExecutable(command).isEmpty();
}
