#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QUrl>

#include "systeminfo.h"
#include "gamemode.h"
#include "applauncher.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    SystemInfo systemInfo;
    GameMode gameMode;
    AppLauncher appLauncher;

    engine.rootContext()->setContextProperty("systemInfo", &systemInfo);
    engine.rootContext()->setContextProperty("gameMode", &gameMode);
    engine.rootContext()->setContextProperty("appLauncher", &appLauncher);

    engine.load(QUrl(QStringLiteral("qrc:/PedShell/qml/Main.qml")));

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}