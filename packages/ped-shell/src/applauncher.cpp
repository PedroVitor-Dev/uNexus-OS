#include "applauncher.h"

#include <QProcess>
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