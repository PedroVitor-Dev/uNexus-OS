#include "gamemode.h"

GameMode::GameMode(QObject *parent) : QObject(parent) {}

void GameMode::enable() {
    if (m_active)
        return;

    m_active = true;
    emit activeChanged();
}

void GameMode::disable() {
    if (!m_active)
        return;

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
