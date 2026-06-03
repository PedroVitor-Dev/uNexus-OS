#include "systeminfo.h"
#include <QFile>
#include <QTextStream>
#include <QDir>

SystemInfo::SystemInfo(QObject *parent) : QObject(parent) {
    connect(&m_timer, &QTimer::timeout, this, &SystemInfo::update);
    m_timer.start(5000);
    update();
}

void SystemInfo::update() {
    readBattery();
    readNetwork();
}

void SystemInfo::readBattery() {
    QString basePath = "/sys/class/power_supply/";
    QDir dir(basePath);
    QStringList entries = dir.entryList(QDir::Dirs | QDir::NoDotAndDotDot);

    for (const QString &entry : entries) {
        if (entry.startsWith("BAT")) {
            QString capacityPath = basePath + entry + "/capacity";
            QString statusPath = basePath + entry + "/status";

            QFile capacityFile(capacityPath);
            if (capacityFile.open(QIODevice::ReadOnly)) {
                QTextStream stream(&capacityFile);
                int level = stream.readAll().trimmed().toInt();
                if (level != m_batteryLevel) {
                    m_batteryLevel = level;
                    emit batteryLevelChanged();
                }
            }

            QFile statusFile(statusPath);
            if (statusFile.open(QIODevice::ReadOnly)) {
                QTextStream stream(&statusFile);
                bool charging = stream.readAll().trimmed() == "Charging";
                if (charging != m_batteryCharging) {
                    m_batteryCharging = charging;
                    emit batteryChargingChanged();
                }
            }

            if (!m_hasBattery) {
                m_hasBattery = true;
                emit hasBatteryChanged();
            }
            return;
        }
    }

    if (m_hasBattery) {
        m_hasBattery = false;
        emit hasBatteryChanged();
    }
}

void SystemInfo::readNetwork() {
    QString path = "/sys/class/net/";
    QDir dir(path);
    QStringList entries = dir.entryList(QDir::Dirs | QDir::NoDotAndDotDot);

    bool connected = false;
    for (const QString &entry : entries) {
        if (entry == "lo") continue;
        QFile operstate(path + entry + "/operstate");
        if (operstate.open(QIODevice::ReadOnly)) {
            QTextStream stream(&operstate);
            QString state = stream.readAll().trimmed();
            if (state == "up" || state == "unknown") {
                connected = true;
                break;
            }
        }
    }

    if (connected != m_networkConnected) {
        m_networkConnected = connected;
        emit networkConnectedChanged();
    }
}