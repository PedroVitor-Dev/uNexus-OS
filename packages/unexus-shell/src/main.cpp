#include <QGuiApplication>
#include <QIcon>
#include <QStringList>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QUrl>
#include "systeminfo.h"
#include "gamemode.h"
#include "applauncher.h"
#include "systemstats.h"
#include "usersettings.h"
#include "filemanager.h"
#include "globalshortcuts.h"

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);
    QIcon::setThemeName(QStringLiteral("Papirus-Dark"));
    QIcon::setFallbackThemeName(QStringLiteral("hicolor"));

    const QStringList args = app.arguments();
    const int shortcutIndex = args.indexOf("--shortcut");
    if (shortcutIndex >= 0 && shortcutIndex + 1 < args.size())
        return GlobalShortcuts::sendShortcutCommand(args.at(shortcutIndex + 1)) ? 0 : 1;

    QQmlApplicationEngine engine;

    SystemInfo systemInfo;
    GameMode gameMode;
    AppLauncher appLauncher;
    SystemStats systemStats;
    UserSettings userSettings;
    FileManager fileManager;
    GlobalShortcuts globalShortcuts;

    engine.rootContext()->setContextProperty("systemInfo", &systemInfo);
    engine.rootContext()->setContextProperty("gameMode", &gameMode);
    engine.rootContext()->setContextProperty("appLauncher", &appLauncher);
    engine.rootContext()->setContextProperty("systemStats", &systemStats);
    engine.rootContext()->setContextProperty("userSettings", &userSettings);
    engine.rootContext()->setContextProperty("fileManager", &fileManager);
    engine.rootContext()->setContextProperty("globalShortcuts", &globalShortcuts);

    engine.load(QUrl(QStringLiteral("qrc:/UNexusShell/qml/Main.qml")));

    if (engine.rootObjects().isEmpty())
        return -1;

    globalShortcuts.start();

    return app.exec();
}
