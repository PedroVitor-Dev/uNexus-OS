#include "installerbackend.h"

#include <QCoreApplication>
#include <QDir>
#include <QFileInfo>
#include <QProcessEnvironment>
#include <QRegularExpression>
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

bool InstallerBackend::diskInstallAvailable() const
{
    return QFileInfo::exists(scriptPath(QStringLiteral("install-os.sh")));
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

bool InstallerBackend::canDiskInstall() const
{
    return pkexecAvailable() && diskInstallAvailable() && !m_diskTarget.trimmed().isEmpty();
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
    checks << checkItem(QStringLiteral("Disk installer"),
                        diskInstallAvailable() ? QStringLiteral("native install-os backend available")
                                               : QStringLiteral("install-os.sh missing"),
                        diskInstallAvailable() ? QStringLiteral("ready") : QStringLiteral("blocked"));
    return checks;
}

QVariantList InstallerBackend::installSteps() const
{
    const bool installing = m_busy && (m_currentAction == QStringLiteral("install") ||
                                      m_currentAction == QStringLiteral("repair") ||
                                      m_currentAction == QStringLiteral("disk-preview") ||
                                      m_currentAction == QStringLiteral("disk-install"));

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
    steps << stepItem(QStringLiteral("Disk backend"),
                      QStringLiteral("Preview or execute install-os.sh for full OS installs."),
                      m_currentAction == QStringLiteral("disk-preview") || m_currentAction == QStringLiteral("disk-install") ? QStringLiteral("running") : QStringLiteral("pending"));
    steps << stepItem(QStringLiteral("Validate"),
                      QStringLiteral("Run uNexus Doctor and initialize user state."),
                      m_busy ? QStringLiteral("pending") : (m_installed ? QStringLiteral("done") : QStringLiteral("pending")));
    return steps;
}

QVariantList InstallerBackend::diskDevices() const
{
    return m_diskDevices;
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

void InstallerBackend::previewDiskInstall()
{
    if (!canDiskInstall()) {
        setStatus(QStringLiteral("Disk install unavailable"),
                  QStringLiteral("Choose a target disk and make sure pkexec and install-os.sh are available."));
        return;
    }

    QStringList command = {QStringLiteral("pkexec"), QStringLiteral("sh"), scriptPath(QStringLiteral("install-os.sh"))};
    command << diskInstallArguments(false);
    runAction(QStringLiteral("disk-preview"), QStringLiteral("Previewing disk install"), command);
}

void InstallerBackend::installDisk()
{
    if (!canDiskInstall()) {
        setStatus(QStringLiteral("Disk install unavailable"),
                  QStringLiteral("Choose a target disk and make sure pkexec and install-os.sh are available."));
        return;
    }

    QStringList command = {QStringLiteral("pkexec"), QStringLiteral("sh"), scriptPath(QStringLiteral("install-os.sh"))};
    command << diskInstallArguments(true);
    runAction(QStringLiteral("disk-install"), QStringLiteral("Installing uNexus OS"), command);
}

void InstallerBackend::refresh()
{
    const bool wasInstalled = m_installed;
    m_installed = !QStandardPaths::findExecutable(QStringLiteral("unexus-shell")).isEmpty() ||
                  QFileInfo::exists(QStringLiteral("/usr/bin/unexus-shell"));
    m_diskDevices = scanDiskDevices();

    if (wasInstalled != m_installed)
        emit installedChanged();

    emit prerequisitesChanged();
    emit diskOptionsChanged();
    emit diskDevicesChanged();
    emit progressChanged();
    emit installStepsChanged();
}

void InstallerBackend::refreshDiskDevices()
{
    m_diskDevices = scanDiskDevices();
    emit diskDevicesChanged();
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
        } else if (finishedAction == QStringLiteral("disk-preview")) {
            setStatus(QStringLiteral("Disk plan ready"),
                      QStringLiteral("Review the plan and only execute when the target disk is correct."));
        } else if (finishedAction == QStringLiteral("disk-install")) {
            setStatus(QStringLiteral("Disk install complete"),
                      QStringLiteral("uNexus OS was installed to the selected disk."));
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

    const bool diskAction = action == QStringLiteral("disk-preview") || action == QStringLiteral("disk-install");

    if (!setupAvailable() && action != QStringLiteral("diagnose") && !diskAction) {
        setStatus(QStringLiteral("Installer files missing"),
                  QStringLiteral("Run this installer from a complete uNexus repository checkout."));
        return;
    }

    if ((action == QStringLiteral("install") ||
         action == QStringLiteral("repair") ||
         action == QStringLiteral("uninstall") ||
         diskAction) && !pkexecAvailable()) {
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

QString InstallerBackend::diskTarget() const { return m_diskTarget; }
QString InstallerBackend::diskUsername() const { return m_diskUsername; }
QString InstallerBackend::diskHostname() const { return m_diskHostname; }
QString InstallerBackend::diskTimezone() const { return m_diskTimezone; }
QString InstallerBackend::diskLocale() const { return m_diskLocale; }
QString InstallerBackend::diskKeymap() const { return m_diskKeymap; }
QString InstallerBackend::diskFilesystem() const { return m_diskFilesystem; }
QString InstallerBackend::diskNetworkMode() const { return m_diskNetworkMode; }

void InstallerBackend::setDiskTarget(const QString &target)
{
    const QString normalized = target.trimmed();
    if (m_diskTarget == normalized)
        return;
    m_diskTarget = normalized;
    emit diskOptionsChanged();
}

void InstallerBackend::setDiskUsername(const QString &username)
{
    const QString normalized = username.trimmed().isEmpty() ? QStringLiteral("unexus") : username.trimmed();
    if (m_diskUsername == normalized)
        return;
    m_diskUsername = normalized;
    emit diskOptionsChanged();
}

void InstallerBackend::setDiskHostname(const QString &hostname)
{
    const QString normalized = hostname.trimmed().isEmpty() ? QStringLiteral("unexus-os") : hostname.trimmed();
    if (m_diskHostname == normalized)
        return;
    m_diskHostname = normalized;
    emit diskOptionsChanged();
}

void InstallerBackend::setDiskTimezone(const QString &timezone)
{
    const QString normalized = timezone.trimmed().isEmpty() ? QStringLiteral("UTC") : timezone.trimmed();
    if (m_diskTimezone == normalized)
        return;
    m_diskTimezone = normalized;
    emit diskOptionsChanged();
}

void InstallerBackend::setDiskLocale(const QString &locale)
{
    const QString normalized = locale.trimmed().isEmpty() ? QStringLiteral("en_US.UTF-8") : locale.trimmed();
    if (m_diskLocale == normalized)
        return;
    m_diskLocale = normalized;
    emit diskOptionsChanged();
}

void InstallerBackend::setDiskKeymap(const QString &keymap)
{
    const QString normalized = keymap.trimmed().isEmpty() ? QStringLiteral("us") : keymap.trimmed();
    if (m_diskKeymap == normalized)
        return;
    m_diskKeymap = normalized;
    emit diskOptionsChanged();
}

void InstallerBackend::setDiskFilesystem(const QString &filesystem)
{
    const QString normalized = filesystem == QStringLiteral("ext4") ? QStringLiteral("ext4") : QStringLiteral("btrfs");
    if (m_diskFilesystem == normalized)
        return;
    m_diskFilesystem = normalized;
    emit diskOptionsChanged();
}

void InstallerBackend::setDiskNetworkMode(const QString &mode)
{
    QString normalized = mode;
    if (normalized != QStringLiteral("offline") && normalized != QStringLiteral("online"))
        normalized = QStringLiteral("auto");
    if (m_diskNetworkMode == normalized)
        return;
    m_diskNetworkMode = normalized;
    emit diskOptionsChanged();
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

QStringList InstallerBackend::diskInstallArguments(bool execute) const
{
    QStringList args = {
        QStringLiteral("--target"), m_diskTarget.trimmed(),
        QStringLiteral("--username"), m_diskUsername,
        QStringLiteral("--hostname"), m_diskHostname,
        QStringLiteral("--timezone"), m_diskTimezone,
        QStringLiteral("--locale"), m_diskLocale,
        QStringLiteral("--keymap"), m_diskKeymap,
        QStringLiteral("--filesystem"), m_diskFilesystem
    };

    if (m_installGamingLaunchers)
        args << QStringLiteral("--gaming-launchers");

    if (m_diskNetworkMode == QStringLiteral("offline"))
        args << QStringLiteral("--offline");
    else if (m_diskNetworkMode == QStringLiteral("online"))
        args << QStringLiteral("--online");

    if (execute)
        args << QStringLiteral("--execute") << QStringLiteral("--confirm") << QStringLiteral("ERASE-AND-INSTALL");

    return args;
}

QVariantList InstallerBackend::scanDiskDevices() const
{
    QVariantList devices;
    const QString lsblk = QStandardPaths::findExecutable(QStringLiteral("lsblk"));
    if (lsblk.isEmpty())
        return devices;

    QProcess process;
    const QStringList arguments = {
        QStringLiteral("-dn"),
        QStringLiteral("-P"),
        QStringLiteral("-o"),
        QStringLiteral("NAME,SIZE,MODEL,TRAN,TYPE")
    };
    process.start(lsblk, arguments);

    if (!process.waitForFinished(2500))
        return devices;

    const QString output = QString::fromLocal8Bit(process.readAllStandardOutput());
    const QRegularExpression pairExpression(QStringLiteral("(\\w+)=\"([^\"]*)\""));
    const QStringList lines = output.split(QLatin1Char('\n'), Qt::SkipEmptyParts);

    for (const QString &line : lines) {
        QVariantMap raw;
        QRegularExpressionMatchIterator it = pairExpression.globalMatch(line);
        while (it.hasNext()) {
            const QRegularExpressionMatch match = it.next();
            raw.insert(match.captured(1).toLower(), match.captured(2).trimmed());
        }

        if (raw.value(QStringLiteral("type")).toString() != QStringLiteral("disk"))
            continue;

        const QString name = raw.value(QStringLiteral("name")).toString();
        if (name.isEmpty())
            continue;

        const QString path = QStringLiteral("/dev/") + name;
        const QString model = raw.value(QStringLiteral("model")).toString();
        const QString transport = raw.value(QStringLiteral("tran")).toString();
        const QString size = raw.value(QStringLiteral("size")).toString();

        QVariantMap device;
        device.insert(QStringLiteral("path"), path);
        device.insert(QStringLiteral("name"), name);
        device.insert(QStringLiteral("size"), size.isEmpty() ? QStringLiteral("unknown size") : size);
        device.insert(QStringLiteral("model"), model.isEmpty() ? QStringLiteral("Unknown disk") : model);
        device.insert(QStringLiteral("transport"), transport.isEmpty() ? QStringLiteral("disk") : transport);
        device.insert(QStringLiteral("selected"), path == m_diskTarget);
        devices << device;
    }

    return devices;
}

bool InstallerBackend::commandExists(const QString &command)
{
    return !QStandardPaths::findExecutable(command).isEmpty();
}
