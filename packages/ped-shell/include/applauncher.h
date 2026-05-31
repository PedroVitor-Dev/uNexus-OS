#pragma once

#include <QObject>
#include <QString>
#include <QStringList>

class AppLauncher : public QObject
{
    Q_OBJECT

public:
    explicit AppLauncher(QObject *parent = nullptr);

    Q_INVOKABLE bool launch(const QString &command, const QStringList &arguments = {});
    Q_INVOKABLE bool launchFirstAvailable(const QStringList &commands, const QStringList &arguments = {});
    Q_INVOKABLE bool isInstalled(const QString &command);
    Q_INVOKABLE bool isFlatpakInstalled(const QString &flatpakId);
    Q_INVOKABLE bool isProcessRunning(const QStringList &processNames);

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
    

    Q_INVOKABLE bool focusWindow(const QStringList &windowClasses);
    Q_INVOKABLE bool focusOrLaunch(
        const QStringList &windowClasses,
        const QString &command,
        const QStringList &arguments = {},
        const QString &flatpakId = ""
    );
    Q_INVOKABLE bool isWindowOpen(const QStringList &windowClasses);

private:
    bool focusWithHyprctl(const QStringList &windowClasses);
    bool focusWithWmctrl(const QStringList &windowClasses);
};