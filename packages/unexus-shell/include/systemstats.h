#pragma once

#include <QObject>
#include <QTimer>

class SystemStats : public QObject {
    Q_OBJECT

    Q_PROPERTY(int cpuUsage READ cpuUsage NOTIFY cpuUsageChanged)
    Q_PROPERTY(int gpuUsage READ gpuUsage NOTIFY gpuUsageChanged)
    Q_PROPERTY(int gpuTemp READ gpuTemp NOTIFY gpuTempChanged)
    Q_PROPERTY(int ramUsage READ ramUsage NOTIFY ramUsageChanged)
    Q_PROPERTY(bool hasGpuStats READ hasGpuStats NOTIFY gpuAvailabilityChanged)
    Q_PROPERTY(bool hasGpuTemp READ hasGpuTemp NOTIFY gpuAvailabilityChanged)
    Q_PROPERTY(bool visible READ visible WRITE setVisible NOTIFY visibleChanged)

public:
    explicit SystemStats(QObject *parent = nullptr);
    ~SystemStats() override = default;

    int cpuUsage() const { return m_cpuUsage; }
    int gpuUsage() const { return m_gpuUsage; }
    int gpuTemp() const { return m_gpuTemp; }
    int ramUsage() const { return m_ramUsage; }
    bool hasGpuStats() const { return m_hasGpuStats; }
    bool hasGpuTemp() const { return m_hasGpuTemp; }
    bool visible() const { return m_visible; }

    void setVisible(bool v) {
        if (m_visible != v) {
            m_visible = v;
            emit visibleChanged();
        }
    }

signals:
    void cpuUsageChanged();
    void gpuUsageChanged();
    void gpuTempChanged();
    void ramUsageChanged();
    void gpuAvailabilityChanged();
    void visibleChanged();

private slots:
    void update();

private:
    int m_cpuUsage = 0;
    int m_gpuUsage = 0;
    int m_gpuTemp = 0;
    int m_ramUsage = 0;
    bool m_hasGpuStats = false;
    bool m_hasGpuTemp = false;
    bool m_visible = false;
    QTimer m_timer;

    void readCpu();
    void readGpu();
    void readRam();

    long m_prevIdle = 0;
    long m_prevTotal = 0;
};