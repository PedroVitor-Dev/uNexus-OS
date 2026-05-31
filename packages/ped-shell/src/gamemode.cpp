#include "gamemode.h"
#include <QProcess>

GameMode::GameMode(QObject *parent) : QObject(parent) {}

void GameMode::enable() {
    QProcess::startDetached("gamemoded", {});
    m_active = true;
    emit activeChanged();
}

void GameMode::disable() {
    QProcess::execute("pkill", {"gamemoded"});
    m_active = false;
    emit activeChanged();
}

void GameMode::toggle() {
    if (m_active) {
        disable();
    } else {
        enable();
    }
}