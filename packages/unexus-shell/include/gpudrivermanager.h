#pragma once

#include <QObject>
#include <QProcess>
#include <QString>
#include <QStringList>
#include <QVariantList>

class GpuDriverManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(DriverState state READ state NOTIFY stateChanged)
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)
    Q_PROPERTY(QString vendor READ vendor NOTIFY hardwareChanged)
    Q_PROPERTY(QString gpuVendor READ vendor NOTIFY hardwareChanged)
    Q_PROPERTY(QString gpuName READ gpuName NOTIFY hardwareChanged)
    Q_PROPERTY(QString gpuModel READ gpuName NOTIFY hardwareChanged)
    Q_PROPERTY(QString activeDriver READ activeDriver NOTIFY hardwareChanged)
    Q_PROPERTY(QString currentDriver READ activeDriver NOTIFY hardwareChanged)
    Q_PROPERTY(QString recommendedPackages READ recommendedPackages NOTIFY hardwareChanged)
    Q_PROPERTY(QString summary READ summary NOTIFY hardwareChanged)
    Q_PROPERTY(QString detail READ detail NOTIFY hardwareChanged)
    Q_PROPERTY(bool installRecommended READ installRecommended NOTIFY hardwareChanged)
    Q_PROPERTY(bool secureBootActive READ secureBootActive NOTIFY hardwareChanged)
    Q_PROPERTY(bool hybridGpu READ hybridGpu NOTIFY hardwareChanged)
    Q_PROPERTY(QVariantList devices READ devices NOTIFY hardwareChanged)
    Q_PROPERTY(QString lastOutput READ lastOutput NOTIFY outputChanged)

public:
    enum DriverState {
        Unknown,
        Detecting,
        Ready,
        NeedsAction,
        Installing,
        RebootRequired,
        Error
    };
    Q_ENUM(DriverState)

    explicit GpuDriverManager(QObject *parent = nullptr);

    DriverState state() const { return m_state; }
    bool busy() const { return m_busy; }
    QString vendor() const { return m_vendor; }
    QString gpuName() const { return m_gpuName; }
    QString activeDriver() const { return m_activeDriver; }
    QString recommendedPackages() const { return m_recommendedPackages.join(QLatin1Char(' ')); }
    QString summary() const { return m_summary; }
    QString detail() const { return m_detail; }
    bool installRecommended() const { return m_installRecommended; }
    bool secureBootActive() const { return m_secureBootActive; }
    bool hybridGpu() const { return m_hybridGpu; }
    QVariantList devices() const { return m_devices; }
    QString lastOutput() const { return m_lastOutput; }

    Q_INVOKABLE void refresh();
    Q_INVOKABLE void detectGpu() { refresh(); }
    Q_INVOKABLE void installRecommendedDriver();
    Q_INVOKABLE void rebootNow();

signals:
    void stateChanged();
    void busyChanged();
    void hardwareChanged();
    void outputChanged();

private slots:
    void readInstallOutput();
    void installFinished(int exitCode, QProcess::ExitStatus exitStatus);
    void installError(QProcess::ProcessError error);

private:
    struct GpuDevice {
        QString name;
        QString vendor;
        QString vendorId;
        QString driver;
        QString pciLine;
    };

    void setState(DriverState state);
    void setBusy(bool busy);
    void setOutput(const QString &output);
    void appendOutput(const QString &output);
    void publishDetection(const QList<GpuDevice> &gpus);
    QList<GpuDevice> detectGpus() const;
    QStringList recommendedPackagesFor(const GpuDevice &gpu) const;
    QString unexusctlPath() const;
    bool detectSecureBoot() const;
    static QString commandOutput(const QString &program, const QStringList &arguments = {}, int timeoutMs = 2000);
    static QString driverFromBlock(const QStringList &block);

    QProcess m_installProcess;
    DriverState m_state = Unknown;
    bool m_busy = false;
    QString m_vendor = QStringLiteral("Unknown");
    QString m_gpuName = QStringLiteral("Unknown GPU");
    QString m_activeDriver = QStringLiteral("Unknown");
    QStringList m_recommendedPackages;
    QString m_summary = QStringLiteral("GPU driver status unknown.");
    QString m_detail = QStringLiteral("Run detection to inspect the active graphics driver.");
    bool m_installRecommended = false;
    bool m_secureBootActive = false;
    bool m_hybridGpu = false;
    QVariantList m_devices;
    QString m_lastOutput;
};
