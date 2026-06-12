#pragma once

#include <QObject>
#include <QProcess>
#include <QString>
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
    Q_PROPERTY(int progress READ progress NOTIFY progressChanged)
    Q_PROPERTY(QVariantList readinessChecks READ readinessChecks NOTIFY prerequisitesChanged)
    Q_PROPERTY(QVariantList installSteps READ installSteps NOTIFY installStepsChanged)
    Q_PROPERTY(bool installGamingLaunchers READ installGamingLaunchers WRITE setInstallGamingLaunchers NOTIFY optionsChanged)
    Q_PROPERTY(bool configureBootloader READ configureBootloader WRITE setConfigureBootloader NOTIFY optionsChanged)
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
    int progress() const;
    QVariantList readinessChecks() const;
    QVariantList installSteps() const;
    bool installGamingLaunchers() const;
    bool configureBootloader() const;
    void setInstallGamingLaunchers(bool enabled);
    void setConfigureBootloader(bool enabled);
    QString repoRoot() const;

    Q_INVOKABLE void install();
    Q_INVOKABLE void repair();
    Q_INVOKABLE void diagnose();
    Q_INVOKABLE void uninstall();
    Q_INVOKABLE void refresh();
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
    static bool commandExists(const QString &command);

    QProcess m_process;
    bool m_busy = false;
    bool m_installed = false;
    bool m_installGamingLaunchers = true;
    bool m_configureBootloader = true;
    int m_progress = 0;
    QString m_currentAction;
    QString m_statusTitle;
    QString m_statusDetail;
    QString m_logText;
};
