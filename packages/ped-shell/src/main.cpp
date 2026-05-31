#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "systeminfo.h"
#include "gamemode.h"

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);

    SystemInfo systemInfo;
    GameMode gameMode;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("systemInfo", &systemInfo);
    engine.rootContext()->setContextProperty("gameMode", &gameMode);
    engine.load(QUrl(QStringLiteral("qrc:/PedShell/qml/Main.qml")));

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}