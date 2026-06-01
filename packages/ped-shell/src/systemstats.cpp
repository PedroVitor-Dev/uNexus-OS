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
    // AMD
    QDir amdDir("/sys/class/drm");
    QStringList cards = amdDir.entryList(QStringList() << "card*", QDir::Dirs);
    for (const QString &card : cards) {
        QString busyPath = "/sys/class/drm/" + card + "/device/gpu_busy_percent";
        QString tempPath = "/sys/class/drm/" + card + "/device/hwmon/hwmon0/temp1_input";

        QFile busyFile(busyPath);
        if (busyFile.open(QIODevice::ReadOnly)) {
            QTextStream s(&busyFile);
            int usage = s.readAll().trimmed().toInt();
            if (usage != m_gpuUsage) {
                m_gpuUsage = usage;
                emit gpuUsageChanged();
            }
        }

        QFile tempFile(tempPath);
        if (tempFile.open(QIODevice::ReadOnly)) {
            QTextStream s(&tempFile);
            int temp = s.readAll().trimmed().toInt() / 1000;
            if (temp != m_gpuTemp) {
                m_gpuTemp = temp;
                emit gpuTempChanged();
            }
        }
    }

    // NVIDIA fallback
    if (m_gpuUsage == 0) {
        QProcess proc;
        proc.start("nvidia-smi", {"--query-gpu=utilization.gpu,temperature.gpu", "--format=csv,noheader,nounits"});
        if (proc.waitForFinished(500)) {
            QString out = proc.readAllStandardOutput().trimmed();
            QStringList parts = out.split(",");
            if (parts.size() >= 2) {
                int usage = parts[0].trimmed().toInt();
                int temp  = parts[1].trimmed().toInt();
                if (usage != m_gpuUsage) { m_gpuUsage = usage; emit gpuUsageChanged(); }
                if (temp  != m_gpuTemp)  { m_gpuTemp  = temp;  emit gpuTempChanged(); }
            }
        }
    }
}

void SystemStats::readRam() {
    QFile file("/proc/meminfo");
    if (!file.open(QIODevice::ReadOnly)) return;

    QTextStream stream(&file);
    long total = 0, available = 0;

    while (!stream.atEnd()) {
        QString line = stream.readLine();
        if (line.startsWith("MemTotal:"))
            total = line.split(QRegularExpression("\\s+"))[1].toLong();
        if (line.startsWith("MemAvailable:"))
            available = line.split(QRegularExpression("\\s+"))[1].toLong();
    }

    if (total > 0) {
        int usage = (int)(100.0 * (total - available) / total);
        if (usage != m_ramUsage) {
            m_ramUsage = usage;
            emit ramUsageChanged();
        }
    }
}