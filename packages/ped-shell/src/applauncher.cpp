#include "applauncher.h"

#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonValue>
#include <QProcess>
#include <QProcessEnvironment>
#include <QStandardPaths>

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

bool AppLauncher::isMangoHudInstalled()
{
    return !QStandardPaths::findExecutable("mangohud").isEmpty();
}

bool AppLauncher::isGameModeRunInstalled()
{
    return !QStandardPaths::findExecutable("gamemoderun").isEmpty();
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
