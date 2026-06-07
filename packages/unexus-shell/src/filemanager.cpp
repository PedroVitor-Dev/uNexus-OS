#include "filemanager.h"

#include <QDate>
#include <QDateTime>
#include <QDesktopServices>
#include <QDir>
#include <QDirIterator>
#include <QFile>
#include <QFileInfo>
#include <QMetaObject>
#include <QProcess>
#include <QStandardPaths>
#include <QStringList>
#include <QThread>
#include <QUrl>
#include <QtGlobal>
#include <QVariantMap>

namespace {
constexpr int kMaxIndexedEntries = 5000;
const QString kGameDataPath = QStringLiteral("unexus://game-data");

QString cleanPath(const QString &path)
{
    if (path.trimmed().isEmpty())
        return QDir::homePath();

    if (path == kGameDataPath)
        return path;

    return QDir::cleanPath(path);
}

QString formatSize(qint64 bytes)
{
    if (bytes < 0)
        return QStringLiteral("-");

    const QStringList units = {
        QStringLiteral("B"),
        QStringLiteral("KB"),
        QStringLiteral("MB"),
        QStringLiteral("GB"),
        QStringLiteral("TB")
    };

    double size = static_cast<double>(bytes);
    int unitIndex = 0;

    while (size >= 1024.0 && unitIndex < units.size() - 1) {
        size /= 1024.0;
        ++unitIndex;
    }

    if (unitIndex == 0)
        return QString::number(bytes) + QStringLiteral(" B");

    return QString::number(size, 'f', size >= 10.0 ? 1 : 2) + QStringLiteral(" ") + units.at(unitIndex);
}

QString kindForFile(const QFileInfo &info)
{
    if (info.isDir())
        return QStringLiteral("Folder");

    const QString suffix = info.suffix().toLower();

    if (QStringList{QStringLiteral("png"), QStringLiteral("jpg"), QStringLiteral("jpeg"), QStringLiteral("webp"), QStringLiteral("gif"), QStringLiteral("svg")}.contains(suffix))
        return QStringLiteral("Image");

    if (QStringList{QStringLiteral("mp4"), QStringLiteral("mkv"), QStringLiteral("webm"), QStringLiteral("mov")}.contains(suffix))
        return QStringLiteral("Video");

    if (QStringList{QStringLiteral("mp3"), QStringLiteral("flac"), QStringLiteral("ogg"), QStringLiteral("wav")}.contains(suffix))
        return QStringLiteral("Audio");

    if (QStringList{QStringLiteral("txt"), QStringLiteral("md"), QStringLiteral("log"), QStringLiteral("json"), QStringLiteral("qml"), QStringLiteral("cpp"), QStringLiteral("h"), QStringLiteral("ini"), QStringLiteral("cfg"), QStringLiteral("conf"), QStringLiteral("xml"), QStringLiteral("csv")}.contains(suffix))
        return QStringLiteral("Text");

    if (suffix == QStringLiteral("pdf"))
        return QStringLiteral("PDF");

    if (QStringList{QStringLiteral("zip"), QStringLiteral("tar"), QStringLiteral("gz"), QStringLiteral("7z"), QStringLiteral("rar")}.contains(suffix))
        return QStringLiteral("Archive");

    if (QStringList{QStringLiteral("desktop"), QStringLiteral("sh"), QStringLiteral("appimage")}.contains(suffix) || info.isExecutable())
        return QStringLiteral("Executable");

    return suffix.isEmpty() ? QStringLiteral("File") : suffix.toUpper();
}

QString iconForKind(const QString &kind)
{
    if (kind == QStringLiteral("Folder"))
        return QStringLiteral("DIR");
    if (kind == QStringLiteral("Image"))
        return QStringLiteral("IMG");
    if (kind == QStringLiteral("Video"))
        return QStringLiteral("VID");
    if (kind == QStringLiteral("Audio"))
        return QStringLiteral("AUD");
    if (kind == QStringLiteral("Text"))
        return QStringLiteral("TXT");
    if (kind == QStringLiteral("PDF"))
        return QStringLiteral("PDF");
    if (kind == QStringLiteral("Archive"))
        return QStringLiteral("ZIP");
    if (kind == QStringLiteral("Executable"))
        return QStringLiteral("RUN");

    return QStringLiteral("DOC");
}

QVariantMap place(const QString &label, const QString &path, const QString &icon)
{
    QVariantMap result;
    result.insert(QStringLiteral("label"), label);
    result.insert(QStringLiteral("path"), path);
    result.insert(QStringLiteral("icon"), icon);
    return result;
}

QVariantMap entryForInfo(const QFileInfo &info, const QString &displayName = QString(), const QString &displayPath = QString())
{
    const QString kind = kindForFile(info);
    QVariantMap item;
    item.insert(QStringLiteral("name"), displayName.isEmpty() ? info.fileName() : displayName);
    item.insert(QStringLiteral("path"), displayPath.isEmpty() ? info.absoluteFilePath() : displayPath);
    item.insert(QStringLiteral("realPath"), info.absoluteFilePath());
    item.insert(QStringLiteral("isDir"), info.isDir());
    item.insert(QStringLiteral("size"), info.isDir() ? QStringLiteral("-") : formatSize(info.size()));
    item.insert(QStringLiteral("sizeBytes"), info.isDir() ? 0 : info.size());
    item.insert(QStringLiteral("kind"), kind);
    item.insert(QStringLiteral("icon"), iconForKind(kind));
    item.insert(QStringLiteral("modified"), info.lastModified().toString(QStringLiteral("yyyy-MM-dd hh:mm")));
    item.insert(QStringLiteral("modifiedEpoch"), info.lastModified().toSecsSinceEpoch());
    item.insert(QStringLiteral("hidden"), info.isHidden());
    return item;
}

QVariantList knownGameDataFolders()
{
    QVariantList result;
    const QString home = QDir::homePath();
    const QList<QPair<QString, QString>> candidates = {
        {QStringLiteral("Steam userdata"), home + QStringLiteral("/.local/share/Steam/userdata")},
        {QStringLiteral("Steam compatdata"), home + QStringLiteral("/.local/share/Steam/steamapps/compatdata")},
        {QStringLiteral("Lutris"), home + QStringLiteral("/.local/share/lutris")},
        {QStringLiteral("Heroic Games"), home + QStringLiteral("/.config/heroic")},
        {QStringLiteral("Bottles"), home + QStringLiteral("/.local/share/bottles")},
        {QStringLiteral("Wine prefix"), home + QStringLiteral("/.wine")},
        {QStringLiteral("Games"), home + QStringLiteral("/Games")},
        {QStringLiteral("Saved Games"), home + QStringLiteral("/Saved Games")},
        {QStringLiteral("Proton saves"), home + QStringLiteral("/.steam/steam/steamapps/compatdata")}
    };

    for (const auto &candidate : candidates) {
        const QFileInfo info(candidate.second);
        if (info.exists() && info.isDir())
            result << entryForInfo(info, candidate.first);
    }

    return result;
}

QString previewModeForKind(const QString &kind)
{
    if (kind == QStringLiteral("Image"))
        return QStringLiteral("image");
    if (kind == QStringLiteral("Video"))
        return QStringLiteral("video");
    if (kind == QStringLiteral("Text"))
        return QStringLiteral("text");
    if (kind == QStringLiteral("PDF"))
        return QStringLiteral("pdf");
    if (kind == QStringLiteral("Folder"))
        return QStringLiteral("folder");

    return QStringLiteral("generic");
}

QString readTextPreview(const QString &path)
{
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return QString();

    QByteArray bytes = file.read(4096);
    QString text = QString::fromUtf8(bytes);
    if (text.contains(QChar::ReplacementCharacter))
        text = QString::fromLocal8Bit(bytes);

    text.replace(QLatin1Char('\t'), QStringLiteral("    "));
    return text.trimmed();
}

bool matchesTypeFilter(const QFileInfo &info, const QString &filter)
{
    if (filter.isEmpty() || filter == QStringLiteral("any"))
        return true;

    const QString kind = kindForFile(info).toLower();
    if (filter == QStringLiteral("folder"))
        return info.isDir();

    return kind == filter;
}

bool matchesDateFilter(const QFileInfo &info, const QString &filter)
{
    if (filter.isEmpty() || filter == QStringLiteral("any"))
        return true;

    const QDate modified = info.lastModified().date();
    const QDate today = QDate::currentDate();
    if (filter == QStringLiteral("today"))
        return modified == today;
    if (filter == QStringLiteral("week"))
        return modified >= today.addDays(-7);
    if (filter == QStringLiteral("month"))
        return modified >= today.addMonths(-1);

    return true;
}

bool matchesSizeFilter(const QFileInfo &info, const QString &filter)
{
    if (info.isDir() || filter.isEmpty() || filter == QStringLiteral("any"))
        return true;

    const qint64 size = info.size();
    if (filter == QStringLiteral("small"))
        return size < 1 * 1024 * 1024;
    if (filter == QStringLiteral("medium"))
        return size >= 1 * 1024 * 1024 && size < 100 * 1024 * 1024;
    if (filter == QStringLiteral("large"))
        return size >= 100 * 1024 * 1024;

    return true;
}

QString uniqueTargetPath(const QString &targetDirectory, const QString &baseName)
{
    QDir targetDir(targetDirectory);
    QString candidate = targetDir.absoluteFilePath(baseName);

    if (!QFileInfo::exists(candidate))
        return candidate;

    const QFileInfo baseInfo(baseName);
    const QString stem = baseInfo.completeBaseName().isEmpty() ? baseName : baseInfo.completeBaseName();
    const QString suffix = baseInfo.suffix();

    for (int i = 1; i < 1000; ++i) {
        const QString numberedName = suffix.isEmpty()
            ? QStringLiteral("%1 copy %2").arg(stem).arg(i)
            : QStringLiteral("%1 copy %2.%3").arg(stem).arg(i).arg(suffix);
        candidate = targetDir.absoluteFilePath(numberedName);

        if (!QFileInfo::exists(candidate))
            return candidate;
    }

    return QString();
}

bool copyRecursively(const QString &sourcePath, const QString &targetPath)
{
    const QFileInfo sourceInfo(sourcePath);

    if (!sourceInfo.exists())
        return false;

    if (sourceInfo.isDir()) {
        QDir targetDir;
        if (!targetDir.mkpath(targetPath))
            return false;

        const QDir sourceDir(sourcePath);
        const QFileInfoList children = sourceDir.entryInfoList(
            QDir::AllEntries | QDir::NoDotAndDotDot | QDir::Hidden | QDir::System,
            QDir::DirsFirst | QDir::Name
        );

        for (const QFileInfo &child : children) {
            if (!copyRecursively(child.absoluteFilePath(), QDir(targetPath).absoluteFilePath(child.fileName())))
                return false;
        }

        return true;
    }

    return QFile::copy(sourceInfo.absoluteFilePath(), targetPath);
}

bool isInsideDirectory(const QString &path, const QString &directory)
{
    const QString cleanSource = QDir::cleanPath(path);
    const QString cleanDirectory = QDir::cleanPath(directory);

    return cleanDirectory == cleanSource ||
           cleanDirectory.startsWith(cleanSource + QLatin1Char('/'));
}
}

FileManager::FileManager(QObject *parent)
    : QObject(parent)
{
}

QString FileManager::homePath() const
{
    return QDir::homePath();
}

QString FileManager::parentPath(const QString &path) const
{
    if (path == kGameDataPath)
        return QDir::homePath();

    const QDir dir(cleanPath(path));

    if (dir.isRoot())
        return dir.absolutePath();

    QDir parent(dir);
    parent.cdUp();
    return parent.absolutePath();
}

QVariantList FileManager::places() const
{
    QVariantList result;
    const QString home = QDir::homePath();

    result << place(QStringLiteral("Home"), home, QStringLiteral("HOME"));
    result << place(QStringLiteral("Game Data"), kGameDataPath, QStringLiteral("SAVE"));

    const QList<QPair<QString, QStandardPaths::StandardLocation>> standardPlaces = {
        {QStringLiteral("Desktop"), QStandardPaths::DesktopLocation},
        {QStringLiteral("Documents"), QStandardPaths::DocumentsLocation},
        {QStringLiteral("Downloads"), QStandardPaths::DownloadLocation},
        {QStringLiteral("Pictures"), QStandardPaths::PicturesLocation},
        {QStringLiteral("Music"), QStandardPaths::MusicLocation},
        {QStringLiteral("Videos"), QStandardPaths::MoviesLocation}
    };

    for (const auto &standardPlace : standardPlaces) {
        const QString path = QStandardPaths::writableLocation(standardPlace.second);
        if (!path.isEmpty() && QFileInfo::exists(path))
            result << place(standardPlace.first, path, standardPlace.first.left(3).toUpper());
    }

    const QString gamesPath = home + QStringLiteral("/Games");
    if (QFileInfo::exists(gamesPath))
        result << place(QStringLiteral("Games"), gamesPath, QStringLiteral("GAME"));

    const QString steamCommonPath = home + QStringLiteral("/.local/share/Steam/steamapps/common");
    if (QFileInfo::exists(steamCommonPath))
        result << place(QStringLiteral("Steam Library"), steamCommonPath, QStringLiteral("ST"));

    return result;
}

QVariantList FileManager::listDirectory(const QString &path) const
{
    QVariantList result;

    if (path == kGameDataPath)
        return knownGameDataFolders();

    const QDir dir(cleanPath(path));

    if (!dir.exists())
        return result;

    const QFileInfoList entries = dir.entryInfoList(
        QDir::AllEntries | QDir::NoDotAndDotDot | QDir::Readable,
        QDir::DirsFirst | QDir::IgnoreCase | QDir::Name
    );

    for (const QFileInfo &info : entries) {
        result << entryForInfo(info);
    }

    return result;
}

bool FileManager::openPath(const QString &path) const
{
    const QFileInfo info(cleanPath(path));

    if (!info.exists())
        return false;

    return QDesktopServices::openUrl(QUrl::fromLocalFile(info.absoluteFilePath()));
}

bool FileManager::createFolder(const QString &parentPath, const QString &name) const
{
    const QString trimmedName = name.trimmed();
    if (trimmedName.isEmpty() || trimmedName.contains(QLatin1Char('/')) || trimmedName.contains(QLatin1Char('\\')))
        return false;

    QDir dir(cleanPath(parentPath));
    if (!dir.exists())
        return false;

    const bool ok = dir.mkdir(trimmedName);
    if (ok)
        m_indexCache.clear();
    return ok;
}

bool FileManager::renamePath(const QString &path, const QString &newName) const
{
    const QString trimmedName = newName.trimmed();
    if (trimmedName.isEmpty() || trimmedName.contains(QLatin1Char('/')) || trimmedName.contains(QLatin1Char('\\')))
        return false;

    const QFileInfo info(cleanPath(path));
    if (!info.exists())
        return false;

    QDir parent(info.absolutePath());
    const bool ok = parent.rename(info.fileName(), trimmedName);
    if (ok)
        m_indexCache.clear();
    return ok;
}

bool FileManager::moveToTrash(const QString &path) const
{
    const QFileInfo info(cleanPath(path));
    if (!info.exists())
        return false;

    if (QStandardPaths::findExecutable(QStringLiteral("gio")).isEmpty())
        return false;

    const int result = QProcess::execute(QStringLiteral("gio"), {QStringLiteral("trash"), info.absoluteFilePath()});
    const bool ok = result == 0;
    if (ok)
        m_indexCache.clear();
    return ok;
}

bool FileManager::movePathsToTrash(const QStringList &paths) const
{
    if (paths.isEmpty())
        return false;

    bool movedAny = false;

    for (const QString &path : paths) {
        if (moveToTrash(path))
            movedAny = true;
    }

    return movedAny;
}

bool FileManager::copyPaths(const QStringList &paths, const QString &targetDirectory) const
{
    const QFileInfo targetInfo(cleanPath(targetDirectory));
    if (!targetInfo.exists() || !targetInfo.isDir() || paths.isEmpty())
        return false;

    for (const QString &path : paths) {
        const QFileInfo sourceInfo(cleanPath(path));
        if (!sourceInfo.exists())
            return false;

        if (sourceInfo.isDir() && isInsideDirectory(sourceInfo.absoluteFilePath(), targetInfo.absoluteFilePath()))
            return false;

        const QString targetPath = uniqueTargetPath(targetInfo.absoluteFilePath(), sourceInfo.fileName());
        if (targetPath.isEmpty() || !copyRecursively(sourceInfo.absoluteFilePath(), targetPath))
            return false;
    }

    m_indexCache.clear();
    return true;
}

bool FileManager::movePaths(const QStringList &paths, const QString &targetDirectory) const
{
    const QFileInfo targetInfo(cleanPath(targetDirectory));
    if (!targetInfo.exists() || !targetInfo.isDir() || paths.isEmpty())
        return false;

    for (const QString &path : paths) {
        const QFileInfo sourceInfo(cleanPath(path));
        if (!sourceInfo.exists())
            return false;

        if (sourceInfo.absolutePath() == targetInfo.absoluteFilePath())
            continue;

        if (sourceInfo.isDir() && isInsideDirectory(sourceInfo.absoluteFilePath(), targetInfo.absoluteFilePath()))
            return false;

        const QString targetPath = uniqueTargetPath(targetInfo.absoluteFilePath(), sourceInfo.fileName());
        if (targetPath.isEmpty())
            return false;

        if (!QFile::rename(sourceInfo.absoluteFilePath(), targetPath)) {
            if (!copyRecursively(sourceInfo.absoluteFilePath(), targetPath))
                return false;

            if (sourceInfo.isDir()) {
                QDir sourceDir(sourceInfo.absoluteFilePath());
                if (!sourceDir.removeRecursively())
                    return false;
            } else if (!QFile::remove(sourceInfo.absoluteFilePath())) {
                return false;
            }
        }
    }

    m_indexCache.clear();
    return true;
}

QVariantMap FileManager::previewInfo(const QString &path) const
{
    QVariantMap result;
    const QFileInfo info(cleanPath(path));

    if (!info.exists())
        return result;

    const QString kind = kindForFile(info);
    result.insert(QStringLiteral("name"), info.fileName());
    result.insert(QStringLiteral("path"), info.absoluteFilePath());
    result.insert(QStringLiteral("kind"), kind);
    result.insert(QStringLiteral("icon"), iconForKind(kind));
    result.insert(QStringLiteral("isDir"), info.isDir());
    result.insert(QStringLiteral("size"), info.isDir() ? QStringLiteral("-") : formatSize(info.size()));
    result.insert(QStringLiteral("modified"), info.lastModified().toString(QStringLiteral("yyyy-MM-dd hh:mm")));
    result.insert(QStringLiteral("created"), info.birthTime().isValid() ? info.birthTime().toString(QStringLiteral("yyyy-MM-dd hh:mm")) : QStringLiteral("-"));
    result.insert(QStringLiteral("readable"), info.isReadable());
    result.insert(QStringLiteral("writable"), info.isWritable());
    result.insert(QStringLiteral("executable"), info.isExecutable());
    result.insert(QStringLiteral("extension"), info.suffix().isEmpty() ? QStringLiteral("-") : info.suffix().toUpper());
    result.insert(QStringLiteral("parent"), info.absolutePath());
    result.insert(QStringLiteral("previewMode"), previewModeForKind(kind));
    result.insert(QStringLiteral("previewSource"), (kind == QStringLiteral("Image") || kind == QStringLiteral("Video") || kind == QStringLiteral("PDF")) ? QStringLiteral("file://") + info.absoluteFilePath() : QString());

    if (info.isDir()) {
        const QDir dir(info.absoluteFilePath());
        const QFileInfoList children = dir.entryInfoList(QDir::AllEntries | QDir::NoDotAndDotDot | QDir::Readable);
        int folders = 0;
        int files = 0;

        for (const QFileInfo &child : children) {
            if (child.isDir())
                ++folders;
            else
                ++files;
        }

        result.insert(QStringLiteral("childSummary"), QStringLiteral("%1 folders, %2 files").arg(folders).arg(files));
    } else {
        result.insert(QStringLiteral("childSummary"), QString());
    }

    if (kind == QStringLiteral("Text")) {
        result.insert(QStringLiteral("textPreview"), readTextPreview(info.absoluteFilePath()));
    } else if (kind == QStringLiteral("PDF")) {
        result.insert(QStringLiteral("textPreview"), QStringLiteral("PDF document\n%1\n%2").arg(info.fileName(), formatSize(info.size())));
    } else if (kind == QStringLiteral("Video")) {
        result.insert(QStringLiteral("textPreview"), QStringLiteral("Video preview\n%1").arg(info.fileName()));
    } else {
        result.insert(QStringLiteral("textPreview"), QString());
    }

    return result;
}

QVariantList FileManager::childDirectories(const QString &path) const
{
    QVariantList result;

    if (path == kGameDataPath)
        return knownGameDataFolders();

    const QDir dir(cleanPath(path));
    if (!dir.exists())
        return result;

    const QFileInfoList entries = dir.entryInfoList(
        QDir::Dirs | QDir::NoDotAndDotDot | QDir::Readable,
        QDir::IgnoreCase | QDir::Name
    );

    for (const QFileInfo &info : entries)
        result << entryForInfo(info);

    return result;
}

QVariantList FileManager::searchIndexed(const QString &rootPath, const QString &query, const QString &typeFilter, const QString &dateFilter, const QString &sizeFilter) const
{
    const QString cleanRoot = cleanPath(rootPath);
    const QString cacheKey = cleanRoot;
    QVariantList indexed;

    if (cleanRoot == kGameDataPath) {
        indexed = knownGameDataFolders();
        for (const QVariant &folderValue : knownGameDataFolders()) {
            const QVariantMap folder = folderValue.toMap();
            const QString folderPath = folder.value(QStringLiteral("path")).toString();
            const QVariantList childResults = searchIndexed(folderPath, QString(), QStringLiteral("any"), QStringLiteral("any"), QStringLiteral("any"));
            for (const QVariant &child : childResults)
                indexed << child;
        }
    } else if (m_indexCache.contains(cacheKey)) {
        indexed = m_indexCache.value(cacheKey);
    } else {
        const QFileInfo rootInfo(cleanRoot);
        if (!rootInfo.exists() || !rootInfo.isDir())
            return indexed;

        QDirIterator iterator(
            cleanRoot,
            QDir::AllEntries | QDir::NoDotAndDotDot | QDir::Readable,
            QDirIterator::Subdirectories
        );

        int count = 0;
        while (iterator.hasNext() && count < kMaxIndexedEntries) {
            iterator.next();
            const QFileInfo info = iterator.fileInfo();
            indexed << entryForInfo(info);
            ++count;
        }

        m_indexCache.insert(cacheKey, indexed);
    }

    QVariantList result;
    const QString needle = query.trimmed().toLower();

    for (const QVariant &value : indexed) {
        const QVariantMap item = value.toMap();
        const QFileInfo info(item.value(QStringLiteral("realPath"), item.value(QStringLiteral("path"))).toString());
        if (!info.exists())
            continue;

        const QString haystack = (item.value(QStringLiteral("name")).toString() + QStringLiteral(" ") + item.value(QStringLiteral("path")).toString()).toLower();
        if (!needle.isEmpty() && !haystack.contains(needle))
            continue;
        if (!matchesTypeFilter(info, typeFilter))
            continue;
        if (!matchesDateFilter(info, dateFilter))
            continue;
        if (!matchesSizeFilter(info, sizeFilter))
            continue;

        result << item;
        if (result.size() >= 500)
            break;
    }

    return result;
}

int FileManager::enqueueOperation(const QString &kind, const QStringList &paths, const QString &targetDirectory)
{
    if (paths.isEmpty())
        return -1;

    const int id = m_nextOperationId++;
    QVariantMap operation;
    operation.insert(QStringLiteral("id"), id);
    operation.insert(QStringLiteral("kind"), kind);
    operation.insert(QStringLiteral("label"), QFileInfo(paths.first()).fileName());
    operation.insert(QStringLiteral("target"), targetDirectory);
    operation.insert(QStringLiteral("current"), 0);
    operation.insert(QStringLiteral("total"), paths.size());
    operation.insert(QStringLiteral("progress"), 0);
    operation.insert(QStringLiteral("done"), false);
    operation.insert(QStringLiteral("ok"), true);

    m_operationQueue.prepend(operation);
    while (m_operationQueue.size() > 5)
        m_operationQueue.removeLast();

    emit operationQueueChanged();
    return id;
}

void FileManager::updateOperation(int id, int current, int total, const QString &label, bool done, bool ok)
{
    for (int i = 0; i < m_operationQueue.size(); ++i) {
        QVariantMap operation = m_operationQueue.at(i).toMap();
        if (operation.value(QStringLiteral("id")).toInt() != id)
            continue;

        operation.insert(QStringLiteral("current"), current);
        operation.insert(QStringLiteral("total"), total);
        operation.insert(QStringLiteral("label"), label);
        operation.insert(QStringLiteral("progress"), total <= 0 ? 0 : qBound(0, (current * 100) / total, 100));
        operation.insert(QStringLiteral("done"), done);
        operation.insert(QStringLiteral("ok"), ok);
        m_operationQueue[i] = operation;
        if (done && ok)
            m_indexCache.clear();
        emit operationQueueChanged();

        if (done)
            emit operationFinished(id, ok, operation.value(QStringLiteral("kind")).toString());
        return;
    }
}

int FileManager::copyPathsAsync(const QStringList &paths, const QString &targetDirectory)
{
    const QFileInfo targetInfo(cleanPath(targetDirectory));
    if (!targetInfo.exists() || !targetInfo.isDir() || paths.isEmpty())
        return -1;

    const int id = enqueueOperation(QStringLiteral("copy"), paths, targetInfo.absoluteFilePath());
    const QStringList sources = paths;
    const QString target = targetInfo.absoluteFilePath();

    QThread *thread = QThread::create([this, id, sources, target]() {
        bool ok = true;
        int current = 0;

        for (const QString &path : sources) {
            const QFileInfo sourceInfo(cleanPath(path));
            const QString label = sourceInfo.fileName();
            QMetaObject::invokeMethod(this, [this, id, current, sources, label]() {
                updateOperation(id, current, sources.size(), label);
            }, Qt::QueuedConnection);

            if (!sourceInfo.exists() ||
                (sourceInfo.isDir() && isInsideDirectory(sourceInfo.absoluteFilePath(), target))) {
                ok = false;
                break;
            }

            const QString targetPath = uniqueTargetPath(target, sourceInfo.fileName());
            if (targetPath.isEmpty() || !copyRecursively(sourceInfo.absoluteFilePath(), targetPath)) {
                ok = false;
                break;
            }

            ++current;
            QMetaObject::invokeMethod(this, [this, id, current, sources, label]() {
                updateOperation(id, current, sources.size(), label);
            }, Qt::QueuedConnection);
        }

        const QString finalLabel = sources.isEmpty() ? QString() : QFileInfo(sources.last()).fileName();
        QMetaObject::invokeMethod(this, [this, id, current, sources, finalLabel, ok]() {
            updateOperation(id, ok ? sources.size() : current, sources.size(), finalLabel, true, ok);
        }, Qt::QueuedConnection);
    });

    connect(thread, &QThread::finished, thread, &QObject::deleteLater);
    thread->start();
    return id;
}

int FileManager::movePathsAsync(const QStringList &paths, const QString &targetDirectory)
{
    const QFileInfo targetInfo(cleanPath(targetDirectory));
    if (!targetInfo.exists() || !targetInfo.isDir() || paths.isEmpty())
        return -1;

    const int id = enqueueOperation(QStringLiteral("move"), paths, targetInfo.absoluteFilePath());
    const QStringList sources = paths;
    const QString target = targetInfo.absoluteFilePath();

    QThread *thread = QThread::create([this, id, sources, target]() {
        bool ok = true;
        int current = 0;

        for (const QString &path : sources) {
            const QFileInfo sourceInfo(cleanPath(path));
            const QString label = sourceInfo.fileName();
            QMetaObject::invokeMethod(this, [this, id, current, sources, label]() {
                updateOperation(id, current, sources.size(), label);
            }, Qt::QueuedConnection);

            if (!sourceInfo.exists() ||
                sourceInfo.absolutePath() == target ||
                (sourceInfo.isDir() && isInsideDirectory(sourceInfo.absoluteFilePath(), target))) {
                ok = false;
                break;
            }

            const QString targetPath = uniqueTargetPath(target, sourceInfo.fileName());
            if (targetPath.isEmpty()) {
                ok = false;
                break;
            }

            if (!QFile::rename(sourceInfo.absoluteFilePath(), targetPath)) {
                if (!copyRecursively(sourceInfo.absoluteFilePath(), targetPath)) {
                    ok = false;
                    break;
                }

                if (sourceInfo.isDir()) {
                    QDir sourceDir(sourceInfo.absoluteFilePath());
                    if (!sourceDir.removeRecursively()) {
                        ok = false;
                        break;
                    }
                } else if (!QFile::remove(sourceInfo.absoluteFilePath())) {
                    ok = false;
                    break;
                }
            }

            ++current;
            QMetaObject::invokeMethod(this, [this, id, current, sources, label]() {
                updateOperation(id, current, sources.size(), label);
            }, Qt::QueuedConnection);
        }

        const QString finalLabel = sources.isEmpty() ? QString() : QFileInfo(sources.last()).fileName();
        QMetaObject::invokeMethod(this, [this, id, current, sources, finalLabel, ok]() {
            updateOperation(id, ok ? sources.size() : current, sources.size(), finalLabel, true, ok);
        }, Qt::QueuedConnection);
    });

    connect(thread, &QThread::finished, thread, &QObject::deleteLater);
    thread->start();
    return id;
}

int FileManager::movePathsToTrashAsync(const QStringList &paths)
{
    if (paths.isEmpty())
        return -1;

    const int id = enqueueOperation(QStringLiteral("trash"), paths);
    const QStringList sources = paths;

    QThread *thread = QThread::create([this, id, sources]() {
        bool ok = true;
        int current = 0;

        for (const QString &path : sources) {
            const QFileInfo info(cleanPath(path));
            const QString label = info.fileName();
            QMetaObject::invokeMethod(this, [this, id, current, sources, label]() {
                updateOperation(id, current, sources.size(), label);
            }, Qt::QueuedConnection);

            if (!info.exists() || QStandardPaths::findExecutable(QStringLiteral("gio")).isEmpty() ||
                QProcess::execute(QStringLiteral("gio"), {QStringLiteral("trash"), info.absoluteFilePath()}) != 0) {
                ok = false;
                break;
            }

            ++current;
            QMetaObject::invokeMethod(this, [this, id, current, sources, label]() {
                updateOperation(id, current, sources.size(), label);
            }, Qt::QueuedConnection);
        }

        const QString finalLabel = sources.isEmpty() ? QString() : QFileInfo(sources.last()).fileName();
        QMetaObject::invokeMethod(this, [this, id, current, sources, finalLabel, ok]() {
            updateOperation(id, ok ? sources.size() : current, sources.size(), finalLabel, true, ok);
        }, Qt::QueuedConnection);
    });

    connect(thread, &QThread::finished, thread, &QObject::deleteLater);
    thread->start();
    return id;
}
