#include "filemanager.h"

#include <QDateTime>
#include <QDesktopServices>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QProcess>
#include <QStandardPaths>
#include <QStringList>
#include <QUrl>
#include <QVariantMap>

namespace {
QString cleanPath(const QString &path)
{
    if (path.trimmed().isEmpty())
        return QDir::homePath();

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

    if (QStringList{QStringLiteral("txt"), QStringLiteral("md"), QStringLiteral("log"), QStringLiteral("json"), QStringLiteral("qml"), QStringLiteral("cpp"), QStringLiteral("h")}.contains(suffix))
        return QStringLiteral("Text");

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
    const QDir dir(cleanPath(path));

    if (!dir.exists())
        return result;

    const QFileInfoList entries = dir.entryInfoList(
        QDir::AllEntries | QDir::NoDotAndDotDot | QDir::Readable,
        QDir::DirsFirst | QDir::IgnoreCase | QDir::Name
    );

    for (const QFileInfo &info : entries) {
        const QString kind = kindForFile(info);

        QVariantMap item;
        item.insert(QStringLiteral("name"), info.fileName());
        item.insert(QStringLiteral("path"), info.absoluteFilePath());
        item.insert(QStringLiteral("isDir"), info.isDir());
        item.insert(QStringLiteral("size"), info.isDir() ? QStringLiteral("-") : formatSize(info.size()));
        item.insert(QStringLiteral("kind"), kind);
        item.insert(QStringLiteral("icon"), iconForKind(kind));
        item.insert(QStringLiteral("modified"), info.lastModified().toString(QStringLiteral("yyyy-MM-dd hh:mm")));
        item.insert(QStringLiteral("hidden"), info.isHidden());
        result << item;
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

    return dir.mkdir(trimmedName);
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
    return parent.rename(info.fileName(), trimmedName);
}

bool FileManager::moveToTrash(const QString &path) const
{
    const QFileInfo info(cleanPath(path));
    if (!info.exists())
        return false;

    if (QStandardPaths::findExecutable(QStringLiteral("gio")).isEmpty())
        return false;

    const int result = QProcess::execute(QStringLiteral("gio"), {QStringLiteral("trash"), info.absoluteFilePath()});
    return result == 0;
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
    result.insert(QStringLiteral("previewSource"), kind == QStringLiteral("Image") ? QStringLiteral("file://") + info.absoluteFilePath() : QString());

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

    return result;
}
