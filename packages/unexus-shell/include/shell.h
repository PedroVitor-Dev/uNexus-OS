#pragma once

#include <QObject>

class Shell : public QObject {
    Q_OBJECT

public:
    explicit Shell(QObject *parent = nullptr);

signals:
    void ready();
};