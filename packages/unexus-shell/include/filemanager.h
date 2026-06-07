#pragma once

#include <QObject>
#include <QHash>
#include <QStringList>
#include <QVariantList>
#include <QVariantMap>

class FileManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList operationQueue READ operationQueue NOTIFY operationQueueChanged)

public:
    explicit FileManager(QObject *parent = nullptr);

    QVariantList operationQueue() const { return m_operationQueue; }

    Q_INVOKABLE QString homePath() const;
    Q_INVOKABLE QString parentPath(const QString &path) const;
    Q_INVOKABLE QVariantList places() const;
    Q_INVOKABLE QVariantList listDirectory(const QString &path) const;
    Q_INVOKABLE bool openPath(const QString &path) const;
    Q_INVOKABLE bool createFolder(const QString &parentPath, const QString &name) const;
    Q_INVOKABLE bool renamePath(const QString &path, const QString &newName) const;
    Q_INVOKABLE bool moveToTrash(const QString &path) const;
    Q_INVOKABLE bool movePathsToTrash(const QStringList &paths) const;
    Q_INVOKABLE bool copyPaths(const QStringList &paths, const QString &targetDirectory) const;
    Q_INVOKABLE bool movePaths(const QStringList &paths, const QString &targetDirectory) const;
    Q_INVOKABLE int copyPathsAsync(const QStringList &paths, const QString &targetDirectory);
    Q_INVOKABLE int movePathsAsync(const QStringList &paths, const QString &targetDirectory);
    Q_INVOKABLE int movePathsToTrashAsync(const QStringList &paths);
    Q_INVOKABLE QVariantMap previewInfo(const QString &path) const;
    Q_INVOKABLE QVariantList childDirectories(const QString &path) const;
    Q_INVOKABLE QVariantList searchIndexed(const QString &rootPath, const QString &query, const QString &typeFilter, const QString &dateFilter, const QString &sizeFilter) const;

signals:
    void operationQueueChanged();
    void operationFinished(int id, bool ok, const QString &kind);

private:
    int enqueueOperation(const QString &kind, const QStringList &paths, const QString &targetDirectory = QString());
    void updateOperation(int id, int current, int total, const QString &label, bool done = false, bool ok = true);

    QVariantList m_operationQueue;
    mutable QHash<QString, QVariantList> m_indexCache;
    int m_nextOperationId = 1;
};
