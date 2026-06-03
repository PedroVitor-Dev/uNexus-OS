#include "filemanager.h"

#include <QDateTime>
#include <QDesktopServices>
#include <QDir>
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
