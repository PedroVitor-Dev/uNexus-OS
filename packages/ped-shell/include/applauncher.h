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
    Q_INVOKABLE bool isMangoHudInstalled();
    Q_INVOKABLE bool isGameModeRunInstalled();
    Q_INVOKABLE bool isWindowOpen(const QStringList &windowClasses);
    Q_INVOKABLE bool isProcessRunning(const QStringList &processNames);
    Q_INVOKABLE void copyToClipboard(const QString &text);

    Q_INVOKABLE bool focusWindow(const QStringList &windowClasses);
    Q_INVOKABLE bool focusOrLaunch(
        const QStringList &windowClasses,
        const QString &command,
        const QStringList &arguments = {},
        const QString &flatpakId = ""
    );
    Q_INVOKABLE bool focusOrLaunchGame(
    const QStringList &windowClasses,
    const QString &command,
    const QStringList &arguments = {},
    const QString &flatpakId = "",
    bool useMangoHud = false,
    bool useGameMode = false);
    
    Q_INVOKABLE bool closeWindow(const QStringList &windowClasses);

private:
    bool focusWithHyprctl(const QStringList &windowClasses);
    bool focusWithWmctrl(const QStringList &windowClasses);
};
