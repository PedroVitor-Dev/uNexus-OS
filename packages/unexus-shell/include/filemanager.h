#pragma once

#include <QObject>
#include <QVariantList>

class FileManager : public QObject
{
    Q_OBJECT

public:
    explicit FileManager(QObject *parent = nullptr);

    Q_INVOKABLE QString homePath() const;
    Q_INVOKABLE QString parentPath(const QString &path) const;
    Q_INVOKABLE QVariantList places() const;
    Q_INVOKABLE QVariantList listDirectory(const QString &path) const;
    Q_INVOKABLE bool openPath(const QString &path) const;
    Q_INVOKABLE bool createFolder(const QString &parentPath, const QString &name) const;
    Q_INVOKABLE bool renamePath(const QString &path, const QString &newName) const;
    Q_INVOKABLE bool moveToTrash(const QString &path) const;
};
