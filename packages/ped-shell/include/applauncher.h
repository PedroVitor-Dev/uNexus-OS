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
};