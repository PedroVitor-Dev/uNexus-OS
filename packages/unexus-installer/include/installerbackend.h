#pragma once

#include <QObject>
#include <QProcess>
#include <QString>
#include <QStringList>
#include <QVariantList>
#include <QVariantMap>

class InstallerBackend : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)
    Q_PROPERTY(QString currentAction READ currentAction NOTIFY currentActionChanged)
    Q_PROPERTY(QString statusTitle READ statusTitle NOTIFY statusChanged)
    Q_PROPERTY(QString statusDetail READ statusDetail NOTIFY statusChanged)
    Q_PROPERTY(QString logText READ logText NOTIFY logChanged)
    Q_PROPERTY(bool installed READ installed NOTIFY installedChanged)
    Q_PROPERTY(bool pkexecAvailable READ pkexecAvailable NOTIFY prerequisitesChanged)
    Q_PROPERTY(bool setupAvailable READ setupAvailable NOTIFY prerequisitesChanged)
    Q_PROPERTY(bool diagnosticsAvailable READ diagnosticsAvailable NOTIFY prerequisitesChanged)
    Q_PROPERTY(bool canInstall READ canInstall NOTIFY prerequisitesChanged)
    Q_PROPERTY(bool diskInstallAvailable READ diskInstallAvailable NOTIFY prerequisitesChanged)
    Q_PROPERTY(bool canDiskInstall READ canDiskInstall NOTIFY diskOptionsChanged)
    Q_PROPERTY(int progress READ progress NOTIFY progressChanged)
    Q_PROPERTY(QVariantList readinessChecks READ readinessChecks NOTIFY prerequisitesChanged)
    Q_PROPERTY(QVariantList installSteps READ installSteps NOTIFY installStepsChanged)
    Q_PROPERTY(QVariantList diskDevices READ diskDevices NOTIFY diskDevicesChanged)
    Q_PROPERTY(bool installGamingLaunchers READ installGamingLaunchers WRITE setInstallGamingLaunchers NOTIFY optionsChanged)
    Q_PROPERTY(bool configureBootloader READ configureBootloader WRITE setConfigureBootloader NOTIFY optionsChanged)
    Q_PROPERTY(QString diskTarget READ diskTarget WRITE setDiskTarget NOTIFY diskOptionsChanged)
    Q_PROPERTY(QString diskUsername READ diskUsername WRITE setDiskUsername NOTIFY diskOptionsChanged)
    Q_PROPERTY(QString diskHostname READ diskHostname WRITE setDiskHostname NOTIFY diskOptionsChanged)
    Q_PROPERTY(QString diskTimezone READ diskTimezone WRITE setDiskTimezone NOTIFY diskOptionsChanged)
    Q_PROPERTY(QString diskLocale READ diskLocale WRITE setDiskLocale NOTIFY diskOptionsChanged)
    Q_PROPERTY(QString diskKeymap READ diskKeymap WRITE setDiskKeymap NOTIFY diskOptionsChanged)
    Q_PROPERTY(QString diskFilesystem READ diskFilesystem WRITE setDiskFilesystem NOTIFY diskOptionsChanged)
    Q_PROPERTY(QString diskNetworkMode READ diskNetworkMode WRITE setDiskNetworkMode NOTIFY diskOptionsChanged)
    Q_PROPERTY(QString repoRoot READ repoRoot CONSTANT)

public:
    explicit InstallerBackend(QObject *parent = nullptr);

    bool busy() const;
    QString currentAction() const;
    QString statusTitle() const;
    QString statusDetail() const;
    QString logText() const;
    bool installed() const;
    bool pkexecAvailable() const;
    bool setupAvailable() const;
    bool diagnosticsAvailable() const;
    bool canInstall() const;
    bool diskInstallAvailable() const;
    bool canDiskInstall() const;
    int progress() const;
    QVariantList readinessChecks() const;
    QVariantList installSteps() const;
    QVariantList diskDevices() const;
    bool installGamingLaunchers() const;
    bool configureBootloader() const;
    void setInstallGamingLaunchers(bool enabled);
    void setConfigureBootloader(bool enabled);
    QString diskTarget() const;
    QString diskUsername() const;
    QString diskHostname() const;
    QString diskTimezone() const;
    QString diskLocale() const;
    QString diskKeymap() const;
    QString diskFilesystem() const;
    QString diskNetworkMode() const;
    void setDiskTarget(const QString &target);
    void setDiskUsername(const QString &username);
    void setDiskHostname(const QString &hostname);
    void setDiskTimezone(const QString &timezone);
    void setDiskLocale(const QString &locale);
    void setDiskKeymap(const QString &keymap);
    void setDiskFilesystem(const QString &filesystem);
    void setDiskNetworkMode(const QString &mode);
    QString repoRoot() const;

    Q_INVOKABLE void install();
    Q_INVOKABLE void repair();
    Q_INVOKABLE void diagnose();
    Q_INVOKABLE void uninstall();
    Q_INVOKABLE void previewDiskInstall();
    Q_INVOKABLE void installDisk();
    Q_INVOKABLE void refresh();
    Q_INVOKABLE void refreshDiskDevices();
    Q_INVOKABLE void clearLog();

signals:
    void busyChanged();
    void currentActionChanged();
    void statusChanged();
    void logChanged();
    void installedChanged();
    void prerequisitesChanged();
    void progressChanged();
    void installStepsChanged();
    void optionsChanged();
    void diskOptionsChanged();
    void diskDevicesChanged();

private slots:
    void readOutput();
    void processFinished(int exitCode, QProcess::ExitStatus exitStatus);
    void processError(QProcess::ProcessError error);

private:
    void runAction(const QString &action, const QString &title, const QStringList &programAndArguments);
    void setBusy(bool busy);
    void setCurrentAction(const QString &action);
    void setStatus(const QString &title, const QString &detail);
    void appendLog(const QString &text);
    QString scriptPath(const QString &name) const;
    QVariantMap checkItem(const QString &label, const QString &value, const QString &status) const;
    QVariantMap stepItem(const QString &label, const QString &detail, const QString &status) const;
    QStringList diskInstallArguments(bool execute) const;
    QVariantList scanDiskDevices() const;
    static bool commandExists(const QString &command);

    QProcess m_process;
    bool m_busy = false;
    bool m_installed = false;
    bool m_installGamingLaunchers = true;
    bool m_configureBootloader = true;
    QString m_diskTarget;
    QString m_diskUsername = QStringLiteral("unexus");
    QString m_diskHostname = QStringLiteral("unexus-os");
    QString m_diskTimezone = QStringLiteral("UTC");
    QString m_diskLocale = QStringLiteral("en_US.UTF-8");
    QString m_diskKeymap = QStringLiteral("us");
    QString m_diskFilesystem = QStringLiteral("btrfs");
    QString m_diskNetworkMode = QStringLiteral("auto");
    QVariantList m_diskDevices;
    int m_progress = 0;
    QString m_currentAction;
    QString m_statusTitle;
    QString m_statusDetail;
    QString m_logText;
};
