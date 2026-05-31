#pragma once

#include <QObject>

class GameMode : public QObject {
    Q_OBJECT

    Q_PROPERTY(bool active READ active NOTIFY activeChanged)

public:
    explicit GameMode(QObject *parent = nullptr);
    ~GameMode() override = default;

    bool active() const { return m_active; }

    Q_INVOKABLE void enable();
    Q_INVOKABLE void disable();
    Q_INVOKABLE void toggle();

signals:
    void activeChanged();

private:
    bool m_active = false;
};