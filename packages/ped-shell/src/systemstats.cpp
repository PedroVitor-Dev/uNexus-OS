#include "systemstats.h"
#include <QFile>
#include <QTextStream>
#include <QDir>
#include <QProcess>
#include <QRegularExpression>

SystemStats::SystemStats(QObject *parent) : QObject(parent) {
    connect(&m_timer, &QTimer::timeout, this, &SystemStats::update);
    m_timer.start(1000);
    update();
}

void SystemStats::update() {
    readCpu();
    readGpu();
    readRam();
}

void SystemStats::readCpu() {
    QFile file("/proc/stat");
    if (!file.open(QIODevice::ReadOnly)) return;

    QTextStream stream(&file);
    QString line = stream.readLine();
    file.close();

    QStringList parts = line.split(" ", Qt::SkipEmptyParts);
    if (parts.size() < 8) return;

    long user   = parts[1].toLong();
    long nice   = parts[2].toLong();
    long system = parts[3].toLong();
    long idle   = parts[4].toLong();
    long iowait = parts[5].toLong();
    long irq    = parts[6].toLong();
    long softirq= parts[7].toLong();

    long total = user + nice + system + idle + iowait + irq + softirq;
    long diffIdle  = idle - m_prevIdle;
    long diffTotal = total - m_prevTotal;

    if (diffTotal > 0) {
        int usage = (int)(100 * (1.0 - (double)diffIdle / diffTotal));
        if (usage != m_cpuUsage) {
            m_cpuUsage = usage;
            emit cpuUsageChanged();
        }
    }

    m_prevIdle  = idle;
    m_prevTotal = total;
}

void SystemStats::readGpu() {
    bool foundGpuUsage = false;
    bool foundGpuTemp = false;
    int newGpuUsage = 0;
    int newGpuTemp = 0;

    QDir drmDir("/sys/class/drm");
    QStringList cards = drmDir.entryList(QStringList() << "card*", QDir::Dirs | QDir::NoDotAndDotDot);

    for (const QString &card : cards) {
        QString busyPath = "/sys/class/drm/" + card + "/device/gpu_busy_percent";

        QFile busyFile(busyPath);
        if (busyFile.open(QIODevice::ReadOnly)) {
            QTextStream stream(&busyFile);
            bool ok = false;
            int usage = stream.readAll().trimmed().toInt(&ok);

            if (ok) {
                newGpuUsage = usage;
                foundGpuUsage = true;
            }
        }

        QDir hwmonDir("/sys/class/drm/" + card + "/device/hwmon");
        QStringList hwmons = hwmonDir.entryList(QStringList() << "hwmon*", QDir::Dirs | QDir::NoDotAndDotDot);

        for (const QString &hwmon : hwmons) {
            QString tempPath = hwmonDir.absoluteFilePath(hwmon + "/temp1_input");

            QFile tempFile(tempPath);
            if (tempFile.open(QIODevice::ReadOnly)) {
                QTextStream stream(&tempFile);
                bool ok = false;
                int temp = stream.readAll().trimmed().toInt(&ok);

                if (ok) {
                    newGpuTemp = temp / 1000;
                    foundGpuTemp = true;
                    break;
                }
            }
        }

        if (foundGpuUsage || foundGpuTemp)
            break;
    }

    if (!foundGpuUsage || !foundGpuTemp) {
        QProcess proc;
        proc.start("nvidia-smi", {
            "--query-gpu=utilization.gpu,temperature.gpu",
            "--format=csv,noheader,nounits"
        });

        if (proc.waitForFinished(500) && proc.exitCode() == 0) {
            QString out = proc.readAllStandardOutput().trimmed();
            QStringList parts = out.split(",");

            if (parts.size() >= 2) {
                bool usageOk = false;
                bool tempOk = false;

                int usage = parts[0].trimmed().toInt(&usageOk);
                int temp = parts[1].trimmed().toInt(&tempOk);

                if (usageOk) {
                    newGpuUsage = usage;
                    foundGpuUsage = true;
                }

                if (tempOk) {
                    newGpuTemp = temp;
                    foundGpuTemp = true;
                }
            }
        }
    }

    if (m_hasGpuStats != foundGpuUsage || m_hasGpuTemp != foundGpuTemp) {
        m_hasGpuStats = foundGpuUsage;
        m_hasGpuTemp = foundGpuTemp;
        emit gpuAvailabilityChanged();
    }

    if (m_gpuUsage != newGpuUsage) {
        m_gpuUsage = newGpuUsage;
        emit gpuUsageChanged();
    }

    if (m_gpuTemp != newGpuTemp) {
        m_gpuTemp = newGpuTemp;
        emit gpuTempChanged();
    }
}

void SystemStats::readRam() {
    QFile file("/proc/meminfo");
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return;

    QTextStream stream(&file);
    long total = 0;
    long available = 0;

    while (!stream.atEnd()) {
        QString line = stream.readLine();
        QStringList parts = line.split(QRegularExpression("\\s+"), Qt::SkipEmptyParts);

        if (parts.size() < 2)
            continue;

        if (parts[0] == "MemTotal:")
            total = parts[1].toLong();

        if (parts[0] == "MemAvailable:")
            available = parts[1].toLong();
    }

    if (total <= 0 || available <= 0)
        return;

    int usage = static_cast<int>(100.0 * (total - available) / total);

    if (usage != m_ramUsage) {
        m_ramUsage = usage;
        emit ramUsageChanged();
    }
}
}