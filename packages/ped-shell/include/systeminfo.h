#pragma once

#include <QObject>
#include <QTimer>

class SystemInfo : public QObject {
    Q_OBJECT

    Q_PROPERTY(int batteryLevel READ batteryLevel NOTIFY batteryLevelChanged)
    Q_PROPERTY(bool batteryCharging READ batteryCharging NOTIFY batteryChargingChanged)
    Q_PROPERTY(bool networkConnected READ networkConnected NOTIFY networkConnectedChanged)
    Q_PROPERTY(bool hasBattery READ hasBattery NOTIFY hasBatteryChanged)

public:
    explicit SystemInfo(QObject *parent = nullptr);

    int batteryLevel() const { return m_batteryLevel; }
    bool batteryCharging() const { return m_batteryCharging; }
    bool networkConnected() const { return m_networkConnected; }
    bool hasBattery() const { return m_hasBattery; }

signals:
    void batteryLevelChanged();
    void batteryChargingChanged();
    void networkConnectedChanged();
    void hasBatteryChanged();

private slots:
    void update();

private:
    int m_batteryLevel = 100;
    bool m_batteryCharging = false;
    bool m_networkConnected = true;
    bool m_hasBattery = false;
    QTimer m_timer;

    void readBattery();
    void readNetwork();
};