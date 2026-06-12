#include "applauncher.h"

#include <algorithm>
#include <cmath>
#include <QClipboard>
#include <QDateTime>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QGuiApplication>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonValue>
#include <QList>
#include <QProcess>
#include <QProcessEnvironment>
#include <QStandardPaths>
#include <QSysInfo>
#include <QTextStream>

AppLauncher::AppLauncher(QObject *parent)
    : QObject(parent)
{
}

bool AppLauncher::launch(const QString &command, const QStringList &arguments)
{
    if (command.trimmed().isEmpty())
        return false;

    return QProcess::startDetached(command, arguments);
}

bool AppLauncher::launchFirstAvailable(const QStringList &commands, const QStringList &arguments)
{
    for (const QString &command : commands) {
        if (QStandardPaths::findExecutable(command).isEmpty())
            continue;

        if (QProcess::startDetached(command, arguments))
            return true;
    }

    return false;
}

bool AppLauncher::isInstalled(const QString &command)
{
    if (command.trimmed().isEmpty())
        return false;

    return !QStandardPaths::findExecutable(command).isEmpty();
}

bool AppLauncher::isFlatpakInstalled(const QString &flatpakId)
{
    if (flatpakId.trimmed().isEmpty())
        return false;

    if (QStandardPaths::findExecutable("flatpak").isEmpty())
        return false;

    QProcess process;
    process.start("flatpak", {"info", flatpakId});
    process.waitForFinished(1500);

    return process.exitStatus() == QProcess::NormalExit && process.exitCode() == 0;
}


bool AppLauncher::installFlatpak(const QString &flatpakId)
{
    const QString appId = flatpakId.trimmed();
    if (appId.isEmpty())
        return false;

    if (QStandardPaths::findExecutable("flatpak").isEmpty())
        return false;

    QProcess::execute("flatpak", {
        QStringLiteral("remote-add"),
        QStringLiteral("--if-not-exists"),
        QStringLiteral("flathub"),
        QStringLiteral("https://flathub.org/repo/flathub.flatpakrepo")
    });

    return QProcess::startDetached("flatpak", {
        QStringLiteral("install"),
        QStringLiteral("-y"),
        QStringLiteral("flathub"),
        appId
    });
}

bool AppLauncher::isMangoHudInstalled()
{
    return !QStandardPaths::findExecutable("mangohud").isEmpty();
}

bool AppLauncher::isGameModeRunInstalled()
{
    return !QStandardPaths::findExecutable("gamemoderun").isEmpty();
}

void AppLauncher::copyToClipboard(const QString &text)
{
    if (QClipboard *clipboard = QGuiApplication::clipboard())
        clipboard->setText(text);
}
QString AppLauncher::findIcon(const QStringList &iconNames)
{
    QStringList roots = QStandardPaths::standardLocations(QStandardPaths::GenericDataLocation);
    roots << QStringLiteral("/var/lib/flatpak/exports/share");
    roots << QDir::homePath() + QStringLiteral("/.local/share/flatpak/exports/share");
    roots.removeDuplicates();

    const QStringList sizes = {QStringLiteral("512x512"), QStringLiteral("256x256"), QStringLiteral("128x128"), QStringLiteral("64x64"), QStringLiteral("48x48"), QStringLiteral("32x32")};
    const QStringList extensions = {QStringLiteral("png"), QStringLiteral("svg")};

    for (const QString &iconName : iconNames) {
        if (iconName.trimmed().isEmpty())
            continue;

        const QFileInfo directInfo(iconName);
        if (directInfo.isAbsolute() && directInfo.exists())
            return QStringLiteral("file://") + directInfo.absoluteFilePath();

        for (const QString &root : roots) {
            QStringList themes = {QStringLiteral("hicolor")};
            const QDir iconsDir(root + QStringLiteral("/icons"));
            if (iconsDir.exists()) {
                themes << iconsDir.entryList(QDir::Dirs | QDir::NoDotAndDotDot);
                themes.removeDuplicates();
            }

            for (const QString &theme : themes) {
                for (const QString &size : sizes) {
                    for (const QString &extension : extensions) {
                        const QString path = root + QStringLiteral("/icons/") + theme + QStringLiteral("/") + size + QStringLiteral("/apps/") + iconName + QStringLiteral(".") + extension;
                        if (QFileInfo::exists(path))
                            return QStringLiteral("file://") + path;
                    }
                }

                for (const QString &extension : extensions) {
                    const QString scalablePath = root + QStringLiteral("/icons/") + theme + QStringLiteral("/scalable/apps/") + iconName + QStringLiteral(".") + extension;
                    if (QFileInfo::exists(scalablePath))
                        return QStringLiteral("file://") + scalablePath;

                    const QString symbolicPath = root + QStringLiteral("/icons/") + theme + QStringLiteral("/symbolic/apps/") + iconName + QStringLiteral(".") + extension;
                    if (QFileInfo::exists(symbolicPath))
                        return QStringLiteral("file://") + symbolicPath;
                }
            }

            for (const QString &extension : extensions) {
                const QString pixmapPath = root + QStringLiteral("/pixmaps/") + iconName + QStringLiteral(".") + extension;
                if (QFileInfo::exists(pixmapPath))
                    return QStringLiteral("file://") + pixmapPath;
            }
        }
    }

    return QString();
}

QVariantMap AppLauncher::prepareBugReport(const QString &updateChannel)
{
    QVariantMap result;
    const QString reportsRoot = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation)
        + QStringLiteral("/unexus/bug-reports");
    QDir().mkpath(reportsRoot);

    const QString stamp = QDateTime::currentDateTimeUtc().toString(QStringLiteral("yyyyMMdd-HHmmss"));
    const QString reportPath = QDir(reportsRoot).filePath(QStringLiteral("unexus-bug-%1.md").arg(stamp));
    QFile report(reportPath);
    if (!report.open(QIODevice::WriteOnly | QIODevice::Text)) {
        result.insert(QStringLiteral("ok"), false);
        result.insert(QStringLiteral("path"), reportPath);
        result.insert(QStringLiteral("error"), report.errorString());
        return result;
    }

    const QString stateBase = QProcessEnvironment::systemEnvironment().value(
        QStringLiteral("XDG_STATE_HOME"),
        QDir::homePath() + QStringLiteral("/.local/state"));
    const QString sessionLog = stateBase + QStringLiteral("/unexus/logs/session.log");
    const QString doctorLog = stateBase + QStringLiteral("/unexus/logs/doctor.log");

    QTextStream out(&report);
    out << "# uNexus Bug Report\n\n";
    out << "## Summary\n\n";
    out << "- What happened:\n";
    out << "- What you expected:\n";
    out << "- Steps to reproduce:\n\n";
    out << "## Environment\n\n";
    out << "- Update channel: " << (updateChannel == QStringLiteral("beta") ? QStringLiteral("beta") : QStringLiteral("stable")) << "\n";
    out << "- Generated UTC: " << QDateTime::currentDateTimeUtc().toString(Qt::ISODate) << "\n";
    out << "- Kernel type: " << QSysInfo::kernelType() << "\n";
    out << "- Kernel version: " << QSysInfo::kernelVersion() << "\n";
    out << "- Product: " << QSysInfo::prettyProductName() << "\n";
    out << "- CPU architecture: " << QSysInfo::currentCpuArchitecture() << "\n\n";
    out << "## Versions\n\n";
    out << "```text\n";
    out << "uNexus shell: 0.1.0\n";
    out << "git: " << commandOutput(QStringLiteral("git"), {QStringLiteral("rev-parse"), QStringLiteral("--short"), QStringLiteral("HEAD")}).trimmed() << "\n";
    out << "hyprctl: " << commandOutput(QStringLiteral("hyprctl"), {QStringLiteral("version")}).left(800).trimmed() << "\n";
    out << "flatpak: " << commandOutput(QStringLiteral("flatpak"), {QStringLiteral("--version")}).trimmed() << "\n";
    out << "gamemoderun: " << commandOutput(QStringLiteral("gamemoderun"), {QStringLiteral("--version")}).trimmed() << "\n";
    out << "mangohud: " << commandOutput(QStringLiteral("mangohud"), {QStringLiteral("--version")}).trimmed() << "\n";
    out << "```\n\n";
    out << "## Hardware\n\n";
    out << "```text\n";
    out << commandOutput(QStringLiteral("lscpu"), {}).left(4000);
    out << commandOutput(QStringLiteral("lspci"), {}).left(4000);
    out << "```\n\n";
    out << "## Hyprland Clients\n\n";
    out << "```json\n";
    out << commandOutput(QStringLiteral("hyprctl"), {QStringLiteral("-j"), QStringLiteral("clients")}).left(12000);
    out << "\n```\n\n";

    auto appendLogTail = [&out](const QString &label, const QString &path) {
        out << "## " << label << "\n\n";
        out << "Path: `" << path << "`\n\n";
        out << "```text\n";
        QFile file(path);
        if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
            const QString text = QString::fromUtf8(file.readAll());
            out << text.right(12000);
        } else {
            out << "Not available.\n";
        }
        out << "\n```\n\n";
    };

    appendLogTail(QStringLiteral("Session Log"), sessionLog);
    appendLogTail(QStringLiteral("Doctor Log"), doctorLog);

    report.close();
    copyToClipboard(reportPath);

    result.insert(QStringLiteral("ok"), true);
    result.insert(QStringLiteral("path"), reportPath);
    result.insert(QStringLiteral("issueUrl"), QStringLiteral("https://github.com/PedroVitor-Dev/uNexus-OS/issues/new"));
    return result;
}

QJsonArray AppLauncher::hyprctlJsonArray(const QStringList &arguments) const
{
    if (QStandardPaths::findExecutable(QStringLiteral("hyprctl")).isEmpty())
        return {};

    QProcess process;
    process.start(QStringLiteral("hyprctl"), arguments);

    if (!process.waitForFinished(1500) ||
        process.exitStatus() != QProcess::NormalExit ||
        process.exitCode() != 0) {
        return {};
    }

    const QJsonDocument document = QJsonDocument::fromJson(process.readAllStandardOutput());
    return document.isArray() ? document.array() : QJsonArray();
}

QJsonObject AppLauncher::hyprctlJsonObject(const QStringList &arguments) const
{
    if (QStandardPaths::findExecutable(QStringLiteral("hyprctl")).isEmpty())
        return {};

    QProcess process;
    process.start(QStringLiteral("hyprctl"), arguments);

    if (!process.waitForFinished(1500) ||
        process.exitStatus() != QProcess::NormalExit ||
        process.exitCode() != 0) {
        return {};
    }

    const QJsonDocument document = QJsonDocument::fromJson(process.readAllStandardOutput());
    return document.isObject() ? document.object() : QJsonObject();
}

QJsonObject AppLauncher::findHyprlandClient(const QStringList &windowClasses) const
{
    if (windowClasses.isEmpty())
        return {};

    const QJsonArray clients = hyprctlJsonArray({QStringLiteral("clients"), QStringLiteral("-j")});

    for (const QJsonValue &value : clients) {
        const QJsonObject client = value.toObject();
        const QString windowClass = client.value(QStringLiteral("class")).toString();

        for (const QString &candidate : windowClasses) {
            if (windowClass.compare(candidate, Qt::CaseInsensitive) == 0)
                return client;
        }
    }

    return {};
}

bool AppLauncher::dispatchHyprctl(const QStringList &arguments) const
{
    if (QStandardPaths::findExecutable(QStringLiteral("hyprctl")).isEmpty())
        return false;

    return QProcess::execute(QStringLiteral("hyprctl"), arguments) == 0;
}

bool AppLauncher::isWindowOpen(const QStringList &windowClasses)
{
    if (windowClasses.isEmpty())
        return false;

    if (!QStandardPaths::findExecutable("hyprctl").isEmpty()) {
        QProcess clientsProcess;
        clientsProcess.start("hyprctl", {"clients", "-j"});

        if (clientsProcess.waitForFinished(1500) &&
            clientsProcess.exitStatus() == QProcess::NormalExit &&
            clientsProcess.exitCode() == 0) {

            const QJsonDocument document = QJsonDocument::fromJson(clientsProcess.readAllStandardOutput());

            if (document.isArray()) {
                const QJsonArray clients = document.array();

                for (const QJsonValue &value : clients) {
                    const QJsonObject client = value.toObject();
                    const QString windowClass = client.value("class").toString();

                    for (const QString &candidate : windowClasses) {
                        if (windowClass.compare(candidate, Qt::CaseInsensitive) == 0)
                            return true;
                    }
                }
            }
        }
    }

    if (!QStandardPaths::findExecutable("wmctrl").isEmpty()) {
        QProcess process;
        process.start("wmctrl", {"-lx"});

        if (process.waitForFinished(1500) &&
            process.exitStatus() == QProcess::NormalExit &&
            process.exitCode() == 0) {

            const QString output = QString::fromUtf8(process.readAllStandardOutput());

            for (const QString &candidate : windowClasses) {
                if (output.contains(candidate, Qt::CaseInsensitive))
                    return true;
            }
        }
    }

    return false;
}

bool AppLauncher::isWindowHidden(const QStringList &windowClasses)
{
    if (windowClasses.isEmpty())
        return false;

    if (QStandardPaths::findExecutable("hyprctl").isEmpty())
        return false;

    QProcess clientsProcess;
    clientsProcess.start("hyprctl", {"clients", "-j"});

    if (!clientsProcess.waitForFinished(1500) ||
        clientsProcess.exitStatus() != QProcess::NormalExit ||
        clientsProcess.exitCode() != 0) {
        return false;
    }

    const QJsonDocument document = QJsonDocument::fromJson(clientsProcess.readAllStandardOutput());
    if (!document.isArray())
        return false;

    const QJsonArray clients = document.array();

    for (const QJsonValue &value : clients) {
        const QJsonObject client = value.toObject();
        const QString windowClass = client.value("class").toString();
        const bool hidden = client.value("hidden").toBool(false);
        const bool mapped = client.value("mapped").toBool(true);
        const QString workspaceName = client.value("workspace").toObject().value("name").toString();

        for (const QString &candidate : windowClasses) {
            if (windowClass.compare(candidate, Qt::CaseInsensitive) != 0)
                continue;

            if (hidden || !mapped || workspaceName.startsWith(QStringLiteral("special:"), Qt::CaseInsensitive))
                return true;
        }
    }

    return false;
}

bool AppLauncher::isProcessRunning(const QStringList &processNames)
{
    if (processNames.isEmpty())
        return false;

    if (QStandardPaths::findExecutable("pgrep").isEmpty())
        return false;

    for (const QString &processName : processNames) {
        if (processName.trimmed().isEmpty())
            continue;

      QStringList args;

if (processName.length() > 15)
    args = {"-f", processName};
else
    args = {"-x", processName};

const int result = QProcess::execute("pgrep", args);

        if (result == 0)
            return true;
    }

    return false;
}

bool AppLauncher::focusWindow(const QStringList &windowClasses)
{
    if (windowClasses.isEmpty())
        return false;

    if (focusWithHyprctl(windowClasses))
        return true;

    if (focusWithWmctrl(windowClasses))
        return true;

    return false;
}

bool AppLauncher::focusOrLaunch(
    const QStringList &windowClasses,
    const QString &command,
    const QStringList &arguments,
    const QString &flatpakId
)
{
    if (focusWindow(windowClasses))
        return true;

    if (!command.trimmed().isEmpty() && launch(command, arguments))
        return true;

    if (!flatpakId.trimmed().isEmpty())
        return launch("flatpak", {"run", flatpakId});

    return false;
}

bool AppLauncher::focusOrLaunchGame(
    const QStringList &windowClasses,
    const QString &command,
    const QStringList &arguments,
    const QString &flatpakId,
    bool useMangoHud,
    bool useGameMode
)
{
    if (focusWindow(windowClasses))
        return true;

    QString launchCommand = command;
    QStringList launchArguments = arguments;
    const bool hasMangoHud = useMangoHud && isMangoHudInstalled();
    const bool hasGameModeRun = useGameMode && isGameModeRunInstalled();
    const QString normalizedCommand = command.trimmed().toLower();
    const QString normalizedFlatpakId = flatpakId.trimmed().toLower();
    const bool isGameLauncher =
        normalizedCommand == "steam" ||
        normalizedCommand == "lutris" ||
        normalizedCommand == "heroic" ||
        normalizedCommand == "heroicgameslauncher" ||
        normalizedCommand == "bottles" ||
        normalizedFlatpakId == "com.valvesoftware.steam" ||
        normalizedFlatpakId == "net.lutris.lutris" ||
        normalizedFlatpakId == "com.heroicgameslauncher.hgl" ||
        normalizedFlatpakId == "com.usebottles.bottles";

    if (launchCommand.trimmed().isEmpty() ||
        (QStandardPaths::findExecutable(launchCommand).isEmpty() && !flatpakId.trimmed().isEmpty())) {
        launchCommand = "flatpak";
        launchArguments = {"run", flatpakId};
    }

    if (launchCommand.trimmed().isEmpty())
        return false;

    if (hasGameModeRun && !isGameLauncher) {
        launchArguments.prepend(launchCommand);
        launchCommand = "gamemoderun";
    }

    if (hasMangoHud && !isGameLauncher) {
        launchArguments.prepend(launchCommand);
        launchCommand = "mangohud";
    }

    QProcess process;
    process.setProgram(launchCommand);
    process.setArguments(launchArguments);

    if (hasMangoHud) {
        QProcessEnvironment environment = QProcessEnvironment::systemEnvironment();
        environment.insert("MANGOHUD", "1");
        process.setProcessEnvironment(environment);
    }

    return process.startDetached();
}

bool AppLauncher::focusWithHyprctl(const QStringList &windowClasses)
{
    if (QStandardPaths::findExecutable("hyprctl").isEmpty())
        return false;

    QProcess clientsProcess;
    clientsProcess.start("hyprctl", {"clients", "-j"});

    if (!clientsProcess.waitForFinished(1500))
        return false;

    if (clientsProcess.exitStatus() != QProcess::NormalExit || clientsProcess.exitCode() != 0)
        return false;

    const QJsonDocument document = QJsonDocument::fromJson(clientsProcess.readAllStandardOutput());

    if (!document.isArray())
        return false;

    const QJsonArray clients = document.array();

    for (const QJsonValue &value : clients) {
        const QJsonObject client = value.toObject();
        const QString windowClass = client.value("class").toString();
        const QString address = client.value("address").toString();

        if (address.isEmpty())
            continue;

        for (const QString &candidate : windowClasses) {
            if (windowClass.compare(candidate, Qt::CaseInsensitive) != 0)
                continue;

            const int result = QProcess::execute("hyprctl", {
                "dispatch",
                "focuswindow",
                "address:" + address
            });

            return result == 0;
        }
    }

    return false;
}

bool AppLauncher::focusWithWmctrl(const QStringList &windowClasses)
{
    if (QStandardPaths::findExecutable("wmctrl").isEmpty())
        return false;

    for (const QString &windowClass : windowClasses) {
        const int result = QProcess::execute("wmctrl", {"-x", "-a", windowClass});

        if (result == 0)
            return true;
    }

    return false;
}

bool AppLauncher::closeWindow(const QStringList &windowClasses)
{
    if (windowClasses.isEmpty())
        return false;

    if (!QStandardPaths::findExecutable("hyprctl").isEmpty()) {
        QProcess clientsProcess;
        clientsProcess.start("hyprctl", {"clients", "-j"});

        if (clientsProcess.waitForFinished(1500) &&
            clientsProcess.exitStatus() == QProcess::NormalExit &&
            clientsProcess.exitCode() == 0) {

            const QJsonDocument document = QJsonDocument::fromJson(clientsProcess.readAllStandardOutput());

            if (document.isArray()) {
                const QJsonArray clients = document.array();

                for (const QJsonValue &value : clients) {
                    const QJsonObject client = value.toObject();
                    const QString windowClass = client.value("class").toString();
                    const QString address = client.value("address").toString();

                    if (address.isEmpty())
                        continue;

                    for (const QString &candidate : windowClasses) {
                        if (windowClass.compare(candidate, Qt::CaseInsensitive) != 0)
                            continue;

                        const int result = QProcess::execute("hyprctl", {
                            "dispatch",
                            "closewindow",
                            "address:" + address
                        });

                        return result == 0;
                    }
                }
            }
        }
    }

    if (!QStandardPaths::findExecutable("wmctrl").isEmpty()) {
        for (const QString &windowClass : windowClasses) {
            const int result = QProcess::execute("wmctrl", {"-x", "-c", windowClass});

            if (result == 0)
                return true;
        }
    }

    return false;
}

bool AppLauncher::closeApp(const QStringList &windowClasses, const QStringList &processNames)
{
    if (closeWindow(windowClasses))
        return true;

    return terminateProcesses(processNames);
}

bool AppLauncher::maximizeWindow(const QStringList &windowClasses)
{
    const QJsonObject client = findHyprlandClient(windowClasses);
    const QString address = client.value(QStringLiteral("address")).toString();

    if (address.isEmpty())
        return false;

    return maximizeWindowAddress(address);
}

bool AppLauncher::moveWindowToNextWorkspace(const QStringList &windowClasses)
{
    const QJsonObject client = findHyprlandClient(windowClasses);
    const QString address = client.value(QStringLiteral("address")).toString();

    if (address.isEmpty())
        return false;

    const int currentWorkspace = activeWorkspace();
    const int targetWorkspace = currentWorkspace > 0 ? currentWorkspace + 1 : 2;

    return dispatchHyprctl({
        QStringLiteral("dispatch"),
        QStringLiteral("movetoworkspacesilent"),
        QStringLiteral("%1,address:%2").arg(targetWorkspace).arg(address)
    });
}

bool AppLauncher::minimizeWindow(const QStringList &windowClasses)
{
    const QJsonObject client = findHyprlandClient(windowClasses);
    const QString address = client.value(QStringLiteral("address")).toString();

    if (address.isEmpty())
        return false;

    return minimizeWindowAddress(address);
}

bool AppLauncher::restoreWindow(const QStringList &windowClasses)
{
    const QJsonObject client = findHyprlandClient(windowClasses);
    const QString address = client.value(QStringLiteral("address")).toString();

    if (address.isEmpty())
        return false;

    return restoreWindowAddress(address);
}

QVariantMap AppLauncher::windowPreviewDirection(const QStringList &windowClasses)
{
    QVariantMap result;
    result.insert(QStringLiteral("direction"), QStringLiteral("center"));
    result.insert(QStringLiteral("workspace"), activeWorkspace());
    result.insert(QStringLiteral("monitor"), QStringLiteral(""));
    result.insert(QStringLiteral("available"), false);

    const QJsonObject client = findHyprlandClient(windowClasses);
    if (client.isEmpty())
        return result;

    const int monitorId = client.value(QStringLiteral("monitor")).toInt(-1);
    const QJsonArray at = client.value(QStringLiteral("at")).toArray();
    const QJsonArray size = client.value(QStringLiteral("size")).toArray();

    if (at.size() < 2 || size.size() < 2)
        return result;

    const double windowCenterX = at.at(0).toDouble() + size.at(0).toDouble() / 2.0;
    const double windowCenterY = at.at(1).toDouble() + size.at(1).toDouble() / 2.0;
    const QJsonArray monitors = hyprctlJsonArray({QStringLiteral("monitors"), QStringLiteral("-j")});

    for (const QJsonValue &value : monitors) {
        const QJsonObject monitor = value.toObject();
        if (monitor.value(QStringLiteral("id")).toInt(-2) != monitorId)
            continue;

        const double x = monitor.value(QStringLiteral("x")).toDouble();
        const double y = monitor.value(QStringLiteral("y")).toDouble();
        const double width = monitor.value(QStringLiteral("width")).toDouble();
        const double height = monitor.value(QStringLiteral("height")).toDouble();
        const double centerX = x + width / 2.0;
        const double centerY = y + height / 2.0;
        QString direction = QStringLiteral("center");

        if (std::abs(windowCenterX - centerX) > std::abs(windowCenterY - centerY))
            direction = windowCenterX < centerX ? QStringLiteral("left") : QStringLiteral("right");
        else
            direction = windowCenterY < centerY ? QStringLiteral("up") : QStringLiteral("down");

        result.insert(QStringLiteral("direction"), direction);
        result.insert(QStringLiteral("monitor"), monitor.value(QStringLiteral("name")).toString());
        result.insert(QStringLiteral("available"), true);
        return result;
    }

    return result;
}

QVariantList AppLauncher::workspaces()
{
    QVariantList result;
    const int activeId = activeWorkspace();
    const QJsonArray workspaceArray = hyprctlJsonArray({QStringLiteral("workspaces"), QStringLiteral("-j")});
    QList<QJsonObject> workspaceObjects;

    for (const QJsonValue &value : workspaceArray)
        workspaceObjects << value.toObject();

    std::sort(workspaceObjects.begin(), workspaceObjects.end(), [](const QJsonObject &left, const QJsonObject &right) {
        return left.value(QStringLiteral("id")).toInt() < right.value(QStringLiteral("id")).toInt();
    });

    for (const QJsonObject &workspace : workspaceObjects) {
        const int id = workspace.value(QStringLiteral("id")).toInt();

        if (id < 0)
            continue;

        QVariantMap item;
        item.insert(QStringLiteral("id"), id);
        item.insert(QStringLiteral("name"), workspace.value(QStringLiteral("name")).toString(QString::number(id)));
        item.insert(QStringLiteral("windows"), workspace.value(QStringLiteral("windows")).toInt());
        item.insert(QStringLiteral("monitor"), workspace.value(QStringLiteral("monitor")).toString());
        item.insert(QStringLiteral("active"), id == activeId);
        result << item;
    }

    if (result.isEmpty()) {
        for (int i = 1; i <= 4; ++i) {
            QVariantMap item;
            item.insert(QStringLiteral("id"), i);
            item.insert(QStringLiteral("name"), QString::number(i));
            item.insert(QStringLiteral("windows"), 0);
            item.insert(QStringLiteral("monitor"), QString());
            item.insert(QStringLiteral("active"), i == 1);
            result << item;
        }
    }

    return result;
}

QVariantList AppLauncher::workspaceWindows()
{
    QVariantList result;
    const QJsonArray clients = hyprctlJsonArray({QStringLiteral("clients"), QStringLiteral("-j")});

    for (const QJsonValue &value : clients) {
        const QJsonObject client = value.toObject();
        const QJsonObject workspace = client.value(QStringLiteral("workspace")).toObject();
        const int workspaceId = workspace.value(QStringLiteral("id")).toInt(-1);
        const QString workspaceName = workspace.value(QStringLiteral("name")).toString();
        const QString address = client.value(QStringLiteral("address")).toString();
        const bool hidden = client.value(QStringLiteral("hidden")).toBool(false);
        const bool mapped = client.value(QStringLiteral("mapped")).toBool(true);

        if (workspaceId < 0 || address.isEmpty() || hidden || !mapped ||
            workspaceName.startsWith(QStringLiteral("special:"), Qt::CaseInsensitive)) {
            continue;
        }

        const QJsonArray at = client.value(QStringLiteral("at")).toArray();
        const QJsonArray size = client.value(QStringLiteral("size")).toArray();
        QVariantMap item;
        item.insert(QStringLiteral("address"), address);
        item.insert(QStringLiteral("workspaceId"), workspaceId);
        item.insert(QStringLiteral("workspaceName"), workspaceName.isEmpty() ? QString::number(workspaceId) : workspaceName);
        item.insert(QStringLiteral("title"), client.value(QStringLiteral("title")).toString());
        item.insert(QStringLiteral("className"), client.value(QStringLiteral("class")).toString());
        item.insert(QStringLiteral("monitor"), client.value(QStringLiteral("monitor")).toInt(-1));
        item.insert(QStringLiteral("floating"), client.value(QStringLiteral("floating")).toBool(false));
        item.insert(QStringLiteral("x"), at.size() > 0 ? at.at(0).toDouble() : 0.0);
        item.insert(QStringLiteral("y"), at.size() > 1 ? at.at(1).toDouble() : 0.0);
        item.insert(QStringLiteral("width"), size.size() > 0 ? size.at(0).toDouble() : 800.0);
        item.insert(QStringLiteral("height"), size.size() > 1 ? size.at(1).toDouble() : 500.0);
        result << item;
    }

    return result;
}

QVariantList AppLauncher::minimizedWindows()
{
    QVariantList result;
    const QJsonArray clients = hyprctlJsonArray({QStringLiteral("clients"), QStringLiteral("-j")});

    for (const QJsonValue &value : clients) {
        const QJsonObject client = value.toObject();
        const QJsonObject workspace = client.value(QStringLiteral("workspace")).toObject();
        const QString workspaceName = workspace.value(QStringLiteral("name")).toString();
        const QString address = client.value(QStringLiteral("address")).toString();

        if (address.isEmpty() ||
            !workspaceName.startsWith(QStringLiteral("special:unexus-minimized"), Qt::CaseInsensitive)) {
            continue;
        }

        const QJsonArray at = client.value(QStringLiteral("at")).toArray();
        const QJsonArray size = client.value(QStringLiteral("size")).toArray();
        QVariantMap item;
        item.insert(QStringLiteral("address"), address);
        item.insert(QStringLiteral("workspaceId"), -1);
        item.insert(QStringLiteral("workspaceName"), QStringLiteral("Minimized"));
        item.insert(QStringLiteral("title"), client.value(QStringLiteral("title")).toString());
        item.insert(QStringLiteral("className"), client.value(QStringLiteral("class")).toString());
        item.insert(QStringLiteral("monitor"), client.value(QStringLiteral("monitor")).toInt(-1));
        item.insert(QStringLiteral("floating"), client.value(QStringLiteral("floating")).toBool(false));
        item.insert(QStringLiteral("x"), at.size() > 0 ? at.at(0).toDouble() : 0.0);
        item.insert(QStringLiteral("y"), at.size() > 1 ? at.at(1).toDouble() : 0.0);
        item.insert(QStringLiteral("width"), size.size() > 0 ? size.at(0).toDouble() : 800.0);
        item.insert(QStringLiteral("height"), size.size() > 1 ? size.at(1).toDouble() : 500.0);
        item.insert(QStringLiteral("minimized"), true);
        result << item;
    }

    return result;
}

bool AppLauncher::focusWorkspace(int workspaceId)
{
    if (workspaceId < 1)
        return false;

    return dispatchHyprctl({
        QStringLiteral("dispatch"),
        QStringLiteral("workspace"),
        QString::number(workspaceId)
    });
}

bool AppLauncher::focusWindowAddress(const QString &address)
{
    const QString normalizedAddress = address.trimmed();
    if (normalizedAddress.isEmpty())
        return false;

    return dispatchHyprctl({
        QStringLiteral("dispatch"),
        QStringLiteral("focuswindow"),
        QStringLiteral("address:") + normalizedAddress
    });
}

bool AppLauncher::closeWindowAddress(const QString &address)
{
    const QString normalizedAddress = address.trimmed();
    if (normalizedAddress.isEmpty())
        return false;

    return dispatchHyprctl({
        QStringLiteral("dispatch"),
        QStringLiteral("closewindow"),
        QStringLiteral("address:") + normalizedAddress
    });
}

bool AppLauncher::maximizeWindowAddress(const QString &address)
{
    const QString normalizedAddress = address.trimmed();
    if (normalizedAddress.isEmpty())
        return false;

    if (!focusWindowAddress(normalizedAddress))
        return false;

    return dispatchHyprctl({
        QStringLiteral("dispatch"),
        QStringLiteral("fullscreen"),
        QStringLiteral("0")
    });
}

bool AppLauncher::minimizeWindowAddress(const QString &address)
{
    const QString normalizedAddress = address.trimmed();
    if (normalizedAddress.isEmpty())
        return false;

    return dispatchHyprctl({
        QStringLiteral("dispatch"),
        QStringLiteral("movetoworkspacesilent"),
        QStringLiteral("special:unexus-minimized,address:") + normalizedAddress
    });
}

bool AppLauncher::restoreWindowAddress(const QString &address)
{
    const QString normalizedAddress = address.trimmed();
    if (normalizedAddress.isEmpty())
        return false;

    const int currentWorkspace = activeWorkspace();
    const QString targetWorkspace = currentWorkspace > 0 ? QString::number(currentWorkspace) : QStringLiteral("current");

    if (!dispatchHyprctl({
            QStringLiteral("dispatch"),
            QStringLiteral("movetoworkspace"),
            targetWorkspace + QStringLiteral(",address:") + normalizedAddress
        })) {
        return false;
    }

    return focusWindowAddress(normalizedAddress);
}

bool AppLauncher::moveWindowAddressToWorkspace(const QString &address, int workspaceId)
{
    const QString normalizedAddress = address.trimmed();
    if (normalizedAddress.isEmpty() || workspaceId < 1)
        return false;

    return dispatchHyprctl({
        QStringLiteral("dispatch"),
        QStringLiteral("movetoworkspacesilent"),
        QStringLiteral("%1,address:%2").arg(workspaceId).arg(normalizedAddress)
    });
}
int AppLauncher::activeWorkspace()
{
    const QJsonObject workspace = hyprctlJsonObject({
        QStringLiteral("activeworkspace"),
        QStringLiteral("-j")
    });

    return workspace.value(QStringLiteral("id")).toInt(1);
}

bool AppLauncher::terminateProcesses(const QStringList &processNames)
{
    if (processNames.isEmpty())
        return false;

    if (QStandardPaths::findExecutable("pkill").isEmpty())
        return false;

    bool terminatedAny = false;

    for (const QString &processName : processNames) {
        if (processName.trimmed().isEmpty())
            continue;

        QStringList termArgs;
        QStringList killArgs;

        if (processName.length() > 15) {
            termArgs = {"-TERM", "-f", processName};
            killArgs = {"-KILL", "-f", processName};
        } else {
            termArgs = {"-TERM", "-x", processName};
            killArgs = {"-KILL", "-x", processName};
        }

        if (QProcess::execute("pkill", termArgs) == 0)
            terminatedAny = true;

        if (isProcessRunning({processName}) && QProcess::execute("pkill", killArgs) == 0)
            terminatedAny = true;
    }

    return terminatedAny;
}

QString AppLauncher::commandOutput(const QString &program, const QStringList &arguments, int timeoutMs) const
{
    if (QStandardPaths::findExecutable(program).isEmpty())
        return QStringLiteral("%1 not found\n").arg(program);

    QProcess process;
    process.start(program, arguments);
    if (!process.waitForFinished(timeoutMs)) {
        process.kill();
        process.waitForFinished(300);
        return QStringLiteral("%1 timed out\n").arg(program);
    }

    QString output = QString::fromLocal8Bit(process.readAllStandardOutput());
    output += QString::fromLocal8Bit(process.readAllStandardError());
    if (output.trimmed().isEmpty())
        output = QStringLiteral("%1 produced no output\n").arg(program);
    return output;
}
