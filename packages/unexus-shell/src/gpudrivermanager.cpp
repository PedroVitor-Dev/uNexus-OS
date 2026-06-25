#include "gpudrivermanager.h"

#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QProcessEnvironment>
#include <QRegularExpression>
#include <QStandardPaths>
#include <QVariantMap>

GpuDriverManager::GpuDriverManager(QObject *parent)
    : QObject(parent)
{
    connect(&m_installProcess, &QProcess::readyReadStandardOutput, this, &GpuDriverManager::readInstallOutput);
    connect(&m_installProcess, &QProcess::readyReadStandardError, this, &GpuDriverManager::readInstallOutput);
    connect(&m_installProcess, &QProcess::finished, this, &GpuDriverManager::installFinished);
    connect(&m_installProcess, &QProcess::errorOccurred, this, &GpuDriverManager::installError);
    refresh();
}

void GpuDriverManager::refresh()
{
    if (m_busy)
        return;

    setState(Detecting);
    m_secureBootActive = detectSecureBoot();
    publishDetection(detectGpus());
}

void GpuDriverManager::installRecommendedDriver()
{
    if (m_busy || !m_installRecommended || m_recommendedPackages.isEmpty())
        return;

    const QString ctl = unexusctlPath();
    if (ctl.isEmpty()) {
        setOutput(QStringLiteral("unexusctl was not found. Install uNexus first or run from a complete checkout.\n"));
        setState(Error);
        return;
    }

    const QString pkexec = QStandardPaths::findExecutable(QStringLiteral("pkexec"));
    if (pkexec.isEmpty()) {
        setOutput(QStringLiteral("pkexec was not found. Install polkit to use graphical driver installation.\n"));
        setState(Error);
        return;
    }

    setOutput(QStringLiteral("Starting privileged GPU driver install through unexusctl.\n"));
    setState(Installing);
    setBusy(true);

    QProcessEnvironment environment = QProcessEnvironment::systemEnvironment();
    environment.insert(QStringLiteral("UNEXUS_GPU_DRIVER_MANAGER"), QStringLiteral("1"));
    m_installProcess.setProcessEnvironment(environment);
    m_installProcess.start(pkexec, {ctl, QStringLiteral("driver-apply"), QStringLiteral("--yes")});
}

void GpuDriverManager::rebootNow()
{
    const QString systemctl = QStandardPaths::findExecutable(QStringLiteral("systemctl"));
    if (!systemctl.isEmpty()) {
        QProcess::startDetached(systemctl, {QStringLiteral("reboot")});
        return;
    }

    const QString loginctl = QStandardPaths::findExecutable(QStringLiteral("loginctl"));
    if (!loginctl.isEmpty())
        QProcess::startDetached(loginctl, {QStringLiteral("reboot")});
}

void GpuDriverManager::readInstallOutput()
{
    appendOutput(QString::fromLocal8Bit(m_installProcess.readAllStandardOutput()));
    appendOutput(QString::fromLocal8Bit(m_installProcess.readAllStandardError()));
}

void GpuDriverManager::installFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
    readInstallOutput();
    setBusy(false);

    if (exitStatus == QProcess::NormalExit && exitCode == 0) {
        m_summary = QStringLiteral("GPU driver install staged.");
        m_detail = QStringLiteral("Reboot to load the new graphics module. uNexus will confirm the next successful boot automatically.");
        setState(RebootRequired);
        emit hardwareChanged();
        return;
    }

    m_summary = QStringLiteral("GPU driver install failed.");
    m_detail = QStringLiteral("Review the backend output and retry after fixing the reported issue.");
    setState(Error);
    emit hardwareChanged();
}

void GpuDriverManager::installError(QProcess::ProcessError error)
{
    appendOutput(QStringLiteral("Process error: %1\n").arg(m_installProcess.errorString()));
    if (error != QProcess::FailedToStart)
        return;

    setBusy(false);
    setState(Error);
}

void GpuDriverManager::setState(DriverState state)
{
    if (m_state == state)
        return;
    m_state = state;
    emit stateChanged();
}

void GpuDriverManager::setBusy(bool busy)
{
    if (m_busy == busy)
        return;
    m_busy = busy;
    emit busyChanged();
}

void GpuDriverManager::setOutput(const QString &output)
{
    m_lastOutput = output;
    emit outputChanged();
}

void GpuDriverManager::appendOutput(const QString &output)
{
    if (output.isEmpty())
        return;
    m_lastOutput += output;
    emit outputChanged();
}

void GpuDriverManager::publishDetection(const QList<GpuDevice> &gpus)
{
    m_devices.clear();
    m_hybridGpu = gpus.size() > 1;
    m_installRecommended = false;
    m_recommendedPackages.clear();

    if (gpus.isEmpty()) {
        m_vendor = QStringLiteral("Unknown");
        m_gpuName = QStringLiteral("No GPU detected");
        m_activeDriver = QStringLiteral("Unknown");
        m_summary = QStringLiteral("No supported GPU was detected.");
        m_detail = QStringLiteral("Install pciutils and make sure lspci can read the PCI device list.");
        setState(Error);
        emit hardwareChanged();
        return;
    }

    GpuDevice selected = gpus.first();
    for (const GpuDevice &gpu : gpus) {
        if (gpu.vendorId == QStringLiteral("10de")) {
            selected = gpu;
            break;
        }
        if (gpu.vendorId == QStringLiteral("1002") || gpu.vendorId == QStringLiteral("1022"))
            selected = gpu;
    }

    for (const GpuDevice &gpu : gpus) {
        QVariantMap item;
        item.insert(QStringLiteral("name"), gpu.name);
        item.insert(QStringLiteral("vendor"), gpu.vendor);
        item.insert(QStringLiteral("vendorId"), gpu.vendorId);
        item.insert(QStringLiteral("driver"), gpu.driver.isEmpty() ? QStringLiteral("none") : gpu.driver);
        item.insert(QStringLiteral("selected"), gpu.pciLine == selected.pciLine);
        m_devices << item;
    }

    m_vendor = selected.vendor;
    m_gpuName = selected.name;
    m_activeDriver = selected.driver.isEmpty() ? QStringLiteral("none") : selected.driver;
    m_recommendedPackages = recommendedPackagesFor(selected);

    if (selected.vendorId == QStringLiteral("10de")) {
        const bool nvidiaLoaded = selected.driver.contains(QStringLiteral("nvidia"), Qt::CaseInsensitive);
        m_installRecommended = !nvidiaLoaded;
        m_summary = nvidiaLoaded ? QStringLiteral("NVIDIA driver is active.") : QStringLiteral("NVIDIA proprietary driver is recommended.");
        m_detail = nvidiaLoaded
            ? QStringLiteral("The NVIDIA kernel driver is already in use.")
            : QStringLiteral("Install nvidia-dkms, nvidia-utils and lib32-nvidia-utils, then reboot.");
        if (m_secureBootActive)
            m_detail += QStringLiteral(" Secure Boot is active; the NVIDIA DKMS module may need signing or Secure Boot must be disabled.");
        setState(m_installRecommended ? NeedsAction : Ready);
    } else if (selected.vendorId == QStringLiteral("1002") || selected.vendorId == QStringLiteral("1022")) {
        m_summary = QStringLiteral("AMD graphics stack is ready.");
        m_detail = QStringLiteral("Mesa and vulkan-radeon are the recommended default path for AMD gaming.");
        setState(Ready);
    } else if (selected.vendorId == QStringLiteral("8086")) {
        m_summary = QStringLiteral("Intel graphics stack is ready.");
        m_detail = QStringLiteral("Mesa, vulkan-intel and intel-media-driver are the recommended default path for Intel graphics.");
        setState(Ready);
    } else {
        m_summary = QStringLiteral("GPU vendor needs manual review.");
        m_detail = QStringLiteral("uNexus could not map this GPU to a trusted driver set yet.");
        setState(Unknown);
    }

    if (m_hybridGpu)
        m_detail += QStringLiteral(" Hybrid GPU detected; uNexus prioritized the discrete GPU for driver decisions.");

    emit hardwareChanged();
}

QList<GpuDriverManager::GpuDevice> GpuDriverManager::detectGpus() const
{
    QList<GpuDevice> result;
    const QString output = commandOutput(QStringLiteral("lspci"), {QStringLiteral("-k"), QStringLiteral("-nn")});
    if (output.trimmed().isEmpty())
        return result;

    const QStringList lines = output.split(QLatin1Char('\n'));
    QStringList block;

    auto flushBlock = [&]() {
        if (block.isEmpty())
            return;

        const QString first = block.first();
        const QString lower = first.toLower();
        if (!lower.contains(QStringLiteral("vga compatible controller")) &&
            !lower.contains(QStringLiteral("3d controller")) &&
            !lower.contains(QStringLiteral("display controller"))) {
            block.clear();
            return;
        }

        GpuDevice gpu;
        gpu.pciLine = first.trimmed();
        gpu.driver = driverFromBlock(block);
        const QRegularExpression vendorExpression(QStringLiteral("\\[([0-9a-fA-F]{4}):([0-9a-fA-F]{4})\\]"));
        const QRegularExpressionMatch match = vendorExpression.match(first);
        if (match.hasMatch())
            gpu.vendorId = match.captured(1).toLower();

        if (gpu.vendorId == QStringLiteral("10de"))
            gpu.vendor = QStringLiteral("NVIDIA");
        else if (gpu.vendorId == QStringLiteral("1002") || gpu.vendorId == QStringLiteral("1022"))
            gpu.vendor = QStringLiteral("AMD");
        else if (gpu.vendorId == QStringLiteral("8086"))
            gpu.vendor = QStringLiteral("Intel");
        else
            gpu.vendor = QStringLiteral("Unknown");

        const int colon = first.indexOf(QStringLiteral(": "));
        gpu.name = colon >= 0 ? first.mid(colon + 2).trimmed() : first.trimmed();
        result << gpu;
        block.clear();
    };

    for (const QString &line : lines) {
        if (!line.isEmpty() && !line.at(0).isSpace()) {
            flushBlock();
            block << line;
        } else if (!block.isEmpty()) {
            block << line;
        }
    }
    flushBlock();

    return result;
}

QStringList GpuDriverManager::recommendedPackagesFor(const GpuDevice &gpu) const
{
    if (gpu.vendorId == QStringLiteral("10de"))
        return {QStringLiteral("nvidia-dkms"), QStringLiteral("nvidia-utils"), QStringLiteral("lib32-nvidia-utils")};
    if (gpu.vendorId == QStringLiteral("1002") || gpu.vendorId == QStringLiteral("1022"))
        return {QStringLiteral("mesa"), QStringLiteral("vulkan-radeon"), QStringLiteral("lib32-mesa"), QStringLiteral("lib32-vulkan-radeon")};
    if (gpu.vendorId == QStringLiteral("8086"))
        return {QStringLiteral("mesa"), QStringLiteral("vulkan-intel"), QStringLiteral("intel-media-driver"), QStringLiteral("lib32-mesa")};
    return {};
}

QString GpuDriverManager::unexusctlPath() const
{
    const QString installed = QStandardPaths::findExecutable(QStringLiteral("unexusctl"));
    if (!installed.isEmpty())
        return installed;

    QDir dir(QCoreApplication::applicationDirPath());
    for (int i = 0; i < 6; ++i) {
        const QString candidate = dir.filePath(QStringLiteral("scripts/unexusctl.sh"));
        if (QFileInfo::exists(candidate))
            return candidate;
        if (!dir.cdUp())
            break;
    }
    return QString();
}

bool GpuDriverManager::detectSecureBoot() const
{
    const QString mokutil = QStandardPaths::findExecutable(QStringLiteral("mokutil"));
    if (!mokutil.isEmpty()) {
        const QString output = commandOutput(mokutil, {QStringLiteral("--sb-state")});
        if (output.contains(QStringLiteral("enabled"), Qt::CaseInsensitive))
            return true;
        if (output.contains(QStringLiteral("disabled"), Qt::CaseInsensitive))
            return false;
    }

    QDir efivars(QStringLiteral("/sys/firmware/efi/efivars"));
    const QStringList entries = efivars.entryList({QStringLiteral("SecureBoot-*")}, QDir::Files);
    if (entries.isEmpty())
        return false;

    QFile secureBootFile(efivars.filePath(entries.first()));
    if (!secureBootFile.open(QIODevice::ReadOnly))
        return true;

    const QByteArray data = secureBootFile.readAll();
    return data.size() >= 5 && data.at(4) == char(1);
}

QString GpuDriverManager::commandOutput(const QString &program, const QStringList &arguments, int timeoutMs)
{
    QProcess process;
    process.start(program, arguments);
    if (!process.waitForFinished(timeoutMs))
        return QString();
    return QString::fromLocal8Bit(process.readAllStandardOutput()) +
           QString::fromLocal8Bit(process.readAllStandardError());
}

QString GpuDriverManager::driverFromBlock(const QStringList &block)
{
    const QRegularExpression expression(QStringLiteral("Kernel driver in use:\\s*(.+)$"));
    for (const QString &line : block) {
        const QRegularExpressionMatch match = expression.match(line.trimmed());
        if (match.hasMatch())
            return match.captured(1).trimmed();
    }
    return QString();
}
