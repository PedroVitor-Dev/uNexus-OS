#pragma once

#include <QJsonArray>
#include <QJsonObject>
#include <QObject>
#include <QString>
#include <QStringList>
#include <QVariantList>
#include <QVariantMap>

class AppLauncher : public QObject
{
    Q_OBJECT

public:
    explicit AppLauncher(QObject *parent = nullptr);

    Q_INVOKABLE bool launch(const QString &command, const QStringList &arguments = {});
    Q_INVOKABLE bool launchFirstAvailable(const QStringList &commands, const QStringList &arguments = {});
    Q_INVOKABLE bool isInstalled(const QString &command);
    Q_INVOKABLE bool isFlatpakInstalled(const QString &flatpakId);
    Q_INVOKABLE bool installFlatpak(const QString &flatpakId);
    Q_INVOKABLE bool isMangoHudInstalled();
    Q_INVOKABLE bool isGameModeRunInstalled();
    Q_INVOKABLE bool isWindowOpen(const QStringList &windowClasses);
    Q_INVOKABLE bool isWindowHidden(const QStringList &windowClasses);
    Q_INVOKABLE bool isProcessRunning(const QStringList &processNames);
    Q_INVOKABLE void copyToClipboard(const QString &text);
    Q_INVOKABLE QString findIcon(const QStringList &iconNames);
    Q_INVOKABLE QVariantMap prepareBugReport(const QString &updateChannel);

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
    Q_INVOKABLE bool closeApp(const QStringList &windowClasses, const QStringList &processNames);
    Q_INVOKABLE bool maximizeWindow(const QStringList &windowClasses);
    Q_INVOKABLE bool moveWindowToNextWorkspace(const QStringList &windowClasses);
    Q_INVOKABLE bool minimizeWindow(const QStringList &windowClasses);
    Q_INVOKABLE bool restoreWindow(const QStringList &windowClasses);
    Q_INVOKABLE QVariantMap windowPreviewDirection(const QStringList &windowClasses);
    Q_INVOKABLE QVariantList workspaces();
    Q_INVOKABLE QVariantList workspaceWindows();
    Q_INVOKABLE QVariantList minimizedWindows();
    Q_INVOKABLE bool focusWorkspace(int workspaceId);
    Q_INVOKABLE bool focusWindowAddress(const QString &address);
    Q_INVOKABLE bool closeWindowAddress(const QString &address);
    Q_INVOKABLE bool maximizeWindowAddress(const QString &address);
    Q_INVOKABLE bool minimizeWindowAddress(const QString &address);
    Q_INVOKABLE bool restoreWindowAddress(const QString &address);
    Q_INVOKABLE bool moveWindowAddressToWorkspace(const QString &address, int workspaceId);
    Q_INVOKABLE int activeWorkspace();

private:
    QJsonArray hyprctlJsonArray(const QStringList &arguments) const;
    QJsonObject hyprctlJsonObject(const QStringList &arguments) const;
    QJsonObject findHyprlandClient(const QStringList &windowClasses) const;
    bool dispatchHyprctl(const QStringList &arguments) const;
    bool focusWithHyprctl(const QStringList &windowClasses);
    bool focusWithWmctrl(const QStringList &windowClasses);
    bool terminateProcesses(const QStringList &processNames);
    QString commandOutput(const QString &program, const QStringList &arguments, int timeoutMs = 1500) const;
};
