#pragma once

#include <QObject>
#include <QString>
#include <QTimer>

class SystemInfo : public QObject {
    Q_OBJECT

    Q_PROPERTY(int batteryLevel READ batteryLevel NOTIFY batteryLevelChanged)
    Q_PROPERTY(bool batteryCharging READ batteryCharging NOTIFY batteryChargingChanged)
    Q_PROPERTY(bool networkConnected READ networkConnected NOTIFY networkConnectedChanged)
    Q_PROPERTY(bool hasBattery READ hasBattery NOTIFY hasBatteryChanged)
    Q_PROPERTY(QString gpuName READ gpuName NOTIFY hardwareChanged)
    Q_PROPERTY(QString vram READ vram NOTIFY hardwareChanged)
    Q_PROPERTY(QString activeDriver READ activeDriver NOTIFY hardwareChanged)
    Q_PROPERTY(QString recommendedGpuDrivers READ recommendedGpuDrivers NOTIFY hardwareChanged)
    Q_PROPERTY(QString kernelVersion READ kernelVersion NOTIFY hardwareChanged)
    Q_PROPERTY(QString mesaVersion READ mesaVersion NOTIFY hardwareChanged)

public:
    explicit SystemInfo(QObject *parent = nullptr);
    ~SystemInfo() override = default;

    int batteryLevel() const { return m_batteryLevel; }
    bool batteryCharging() const { return m_batteryCharging; }
    bool networkConnected() const { return m_networkConnected; }
    bool hasBattery() const { return m_hasBattery; }
    QString gpuName() const { return m_gpuName; }
    QString vram() const { return m_vram; }
    QString activeDriver() const { return m_activeDriver; }
    QString recommendedGpuDrivers() const { return m_recommendedGpuDrivers; }
    QString kernelVersion() const { return m_kernelVersion; }
    QString mesaVersion() const { return m_mesaVersion; }

signals:
    void batteryLevelChanged();
    void batteryChargingChanged();
    void networkConnectedChanged();
    void hasBatteryChanged();
    void hardwareChanged();

private slots:
    void update();

private:
    int m_batteryLevel = 100;
    bool m_batteryCharging = false;
    bool m_networkConnected = true;
    bool m_hasBattery = false;
    QString m_gpuName = QStringLiteral("Unknown");
    QString m_vram = QStringLiteral("Unknown");
    QString m_activeDriver = QStringLiteral("Unknown");
    QString m_recommendedGpuDrivers = QStringLiteral("Unknown");
    QString m_kernelVersion = QStringLiteral("Unknown");
    QString m_mesaVersion = QStringLiteral("Unknown");
    QTimer m_timer;

    void readBattery();
    void readNetwork();
    void readHardware();
};
