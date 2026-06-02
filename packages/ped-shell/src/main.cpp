#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QUrl>
#include "systeminfo.h"
#include "gamemode.h"
#include "applauncher.h"
#include "systemstats.h"
#include "usersettings.h"

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    SystemInfo systemInfo;
    GameMode gameMode;
    AppLauncher appLauncher;
    SystemStats systemStats;
    UserSettings userSettings;

    engine.rootContext()->setContextProperty("systemInfo", &systemInfo);
    engine.rootContext()->setContextProperty("gameMode", &gameMode);
    engine.rootContext()->setContextProperty("appLauncher", &appLauncher);
    engine.rootContext()->setContextProperty("systemStats", &systemStats);
    engine.rootContext()->setContextProperty("userSettings", &userSettings);

    engine.load(QUrl(QStringLiteral("qrc:/PedShell/qml/Main.qml")));

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}