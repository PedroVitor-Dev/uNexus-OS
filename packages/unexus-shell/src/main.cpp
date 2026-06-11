#include <QGuiApplication>
#include <QBuffer>
#include <QDataStream>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QIcon>
#include <QImage>
#include <QMetaObject>
#include <QQuickWindow>
#include <QStringList>
#include <QTimer>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QUrl>
#include <QVariant>
#include <functional>
#include <memory>
#include <vector>
#include "systeminfo.h"
#include "gamemode.h"
#include "applauncher.h"
#include "systemstats.h"
#include "usersettings.h"
#include "filemanager.h"
#include "globalshortcuts.h"

namespace {

void writeFourCc(QFile &file, const char *code) {
    file.write(code, 4);
}

void writeU16(QFile &file, quint16 value) {
    char data[2] = { static_cast<char>(value & 0xff), static_cast<char>((value >> 8) & 0xff) };
    file.write(data, 2);
}

void writeU32(QFile &file, quint32 value) {
    char data[4] = {
        static_cast<char>(value & 0xff),
        static_cast<char>((value >> 8) & 0xff),
        static_cast<char>((value >> 16) & 0xff),
        static_cast<char>((value >> 24) & 0xff)
    };
    file.write(data, 4);
}

void patchU32(QFile &file, qint64 offset, quint32 value) {
    const qint64 current = file.pos();
    file.seek(offset);
    writeU32(file, value);
    file.seek(current);
}

qint64 beginChunk(QFile &file, const char *id) {
    writeFourCc(file, id);
    const qint64 sizeOffset = file.pos();
    writeU32(file, 0);
    return sizeOffset;
}

void endChunk(QFile &file, qint64 sizeOffset) {
    const qint64 end = file.pos();
    patchU32(file, sizeOffset, static_cast<quint32>(end - sizeOffset - 4));
    if ((end - sizeOffset - 4) & 1)
        file.putChar('\0');
}

qint64 beginList(QFile &file, const char *type) {
    const qint64 sizeOffset = beginChunk(file, "LIST");
    writeFourCc(file, type);
    return sizeOffset;
}

struct AviIndexEntry {
    quint32 offset;
    quint32 size;
};

bool writeMjpegAvi(const QString &path, const QVector<QImage> &frames, int fps) {
    if (frames.isEmpty())
        return false;

    QFile file(path);
    if (!file.open(QIODevice::WriteOnly))
        return false;

    const int width = frames.first().width();
    const int height = frames.first().height();
    const quint32 frameCount = static_cast<quint32>(frames.size());
    const quint32 usecPerFrame = static_cast<quint32>(1000000 / qMax(1, fps));
    const quint32 maxBytesPerSec = static_cast<quint32>(width * height * 3 * qMax(1, fps));

    const qint64 riffSizeOffset = beginChunk(file, "RIFF");
    writeFourCc(file, "AVI ");

    const qint64 hdrlSizeOffset = beginList(file, "hdrl");
    const qint64 avihSizeOffset = beginChunk(file, "avih");
    writeU32(file, usecPerFrame);
    writeU32(file, maxBytesPerSec);
    writeU32(file, 0);
    writeU32(file, 0x10);
    writeU32(file, frameCount);
    writeU32(file, 0);
    writeU32(file, 1);
    writeU32(file, static_cast<quint32>(width * height * 3));
    writeU32(file, static_cast<quint32>(width));
    writeU32(file, static_cast<quint32>(height));
    for (int i = 0; i < 4; ++i)
        writeU32(file, 0);
    endChunk(file, avihSizeOffset);

    const qint64 strlSizeOffset = beginList(file, "strl");
    const qint64 strhSizeOffset = beginChunk(file, "strh");
    writeFourCc(file, "vids");
    writeFourCc(file, "MJPG");
    writeU32(file, 0);
    writeU16(file, 0);
    writeU16(file, 0);
    writeU32(file, 0);
    writeU32(file, 1);
    writeU32(file, static_cast<quint32>(qMax(1, fps)));
    writeU32(file, 0);
    writeU32(file, frameCount);
    writeU32(file, static_cast<quint32>(width * height * 3));
    writeU32(file, 0xffffffff);
    writeU32(file, 0);
    writeU16(file, 0);
    writeU16(file, 0);
    writeU16(file, static_cast<quint16>(width));
    writeU16(file, static_cast<quint16>(height));
    endChunk(file, strhSizeOffset);

    const qint64 strfSizeOffset = beginChunk(file, "strf");
    writeU32(file, 40);
    writeU32(file, static_cast<quint32>(width));
    writeU32(file, static_cast<quint32>(height));
    writeU16(file, 1);
    writeU16(file, 24);
    writeFourCc(file, "MJPG");
    writeU32(file, static_cast<quint32>(width * height * 3));
    writeU32(file, 0);
    writeU32(file, 0);
    writeU32(file, 0);
    writeU32(file, 0);
    endChunk(file, strfSizeOffset);
    endChunk(file, strlSizeOffset);
    endChunk(file, hdrlSizeOffset);

    const qint64 moviSizeOffset = beginList(file, "movi");
    const qint64 moviDataStart = file.pos();
    QVector<AviIndexEntry> index;
    index.reserve(frames.size());

    for (const QImage &frame : frames) {
        QByteArray jpeg;
        QBuffer buffer(&jpeg);
        buffer.open(QIODevice::WriteOnly);
        frame.save(&buffer, "JPG", 92);

        const quint32 offset = static_cast<quint32>(file.pos() - moviDataStart);
        writeFourCc(file, "00dc");
        writeU32(file, static_cast<quint32>(jpeg.size()));
        file.write(jpeg);
        if (jpeg.size() & 1)
            file.putChar('\0');
        index.push_back({ offset, static_cast<quint32>(jpeg.size()) });
    }
    endChunk(file, moviSizeOffset);

    const qint64 idxSizeOffset = beginChunk(file, "idx1");
    for (const AviIndexEntry &entry : index) {
        writeFourCc(file, "00dc");
        writeU32(file, 0x10);
        writeU32(file, entry.offset);
        writeU32(file, entry.size);
    }
    endChunk(file, idxSizeOffset);

    patchU32(file, riffSizeOffset, static_cast<quint32>(file.size() - 8));
    return true;
}

void captureScene(QObject *root, QQuickWindow *window, const QString &scene, const QString &path, int delayMs, std::function<void()> next) {
    QMetaObject::invokeMethod(root, "captureSetScene", Q_ARG(QVariant, scene));
    QTimer::singleShot(delayMs, window, [window, path, next = std::move(next)]() mutable {
        QDir().mkpath(QFileInfo(path).absolutePath());
        window->grabWindow().save(path);
        next();
    });
}

void captureVideo(QObject *root, QQuickWindow *window, const QStringList &scenes, const QString &path, int fps, int framesPerScene, std::function<void()> done) {
    auto frames = std::make_shared<QVector<QImage>>();
    auto sceneIndex = std::make_shared<int>(0);
    auto frameIndex = std::make_shared<int>(0);
    auto tick = std::make_shared<std::function<void()>>();

    *tick = [=]() mutable {
        if (*sceneIndex >= scenes.size()) {
            QDir().mkpath(QFileInfo(path).absolutePath());
            writeMjpegAvi(path, *frames, fps);
            done();
            return;
        }

        if (*frameIndex == 0)
            QMetaObject::invokeMethod(root, "captureSetScene", Q_ARG(QVariant, scenes.at(*sceneIndex)));

        frames->push_back(window->grabWindow());
        ++(*frameIndex);

        if (*frameIndex >= framesPerScene) {
            *frameIndex = 0;
            ++(*sceneIndex);
        }

        QTimer::singleShot(1000 / qMax(1, fps), window, *tick);
    };

    QTimer::singleShot(300, window, *tick);
}

void runAssetCapture(QGuiApplication &app, QObject *root, QQuickWindow *window, const QString &outputDir) {
    window->setVisibility(QWindow::Windowed);
    window->resize(1920, 1080);
    window->show();

    const QVector<QPair<QString, QString>> scenes = {
        { "login", "01-login.png" },
        { "desktop", "02-desktop.png" },
        { "launcher", "03-launcher.png" },
        { "files", "04-file-manager.png" },
        { "settings", "05-settings.png" },
        { "game-settings", "06-game-settings.png" },
        { "first-setup", "07-first-setup.png" },
        { "settings-appearance", "08-settings-appearance.png" },
        { "desktop-particle-drift", "09-desktop-particle-drift.png" },
        { "desktop-aurora-ice", "10-desktop-aurora-ice.png" },
        { "desktop-ember-circuit", "11-desktop-ember-circuit.png" }
    };

    auto index = std::make_shared<int>(0);
    auto captureNext = std::make_shared<std::function<void()>>();
    *captureNext = [=, &app]() mutable {
        if (*index >= scenes.size()) {
            captureVideo(root, window, { "desktop", "launcher", "files", "settings", "game-settings" },
                         QDir(outputDir).filePath("videos/unexus-shell-tour.avi"), 12, 12, [=, &app]() {
                captureVideo(root, window, { "desktop", "files", "settings", "first-setup" },
                             QDir(outputDir).filePath("videos/unexus-panels.avi"), 12, 14, [&app]() {
                    app.quit();
                });
            });
            return;
        }

        const auto scene = scenes.at(*index);
        ++(*index);
        captureScene(root, window, scene.first, QDir(outputDir).filePath("screenshots/" + scene.second), 900, *captureNext);
    };

    QTimer::singleShot(500, window, *captureNext);
}

}

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);
    QIcon::setThemeName(QStringLiteral("Papirus-Dark"));
    QIcon::setFallbackThemeName(QStringLiteral("hicolor"));

    const QStringList args = app.arguments();
    const int shortcutIndex = args.indexOf("--shortcut");
    if (shortcutIndex >= 0 && shortcutIndex + 1 < args.size())
        return GlobalShortcuts::sendShortcutCommand(args.at(shortcutIndex + 1)) ? 0 : 1;
    const int captureIndex = args.indexOf("--capture-assets");
    const bool captureAssets = captureIndex >= 0 && captureIndex + 1 < args.size();

    QQmlApplicationEngine engine;

    SystemInfo systemInfo;
    GameMode gameMode;
    AppLauncher appLauncher;
    SystemStats systemStats;
    UserSettings userSettings;
    FileManager fileManager;
    GlobalShortcuts globalShortcuts;

    engine.rootContext()->setContextProperty("systemInfo", &systemInfo);
    engine.rootContext()->setContextProperty("gameMode", &gameMode);
    engine.rootContext()->setContextProperty("appLauncher", &appLauncher);
    engine.rootContext()->setContextProperty("systemStats", &systemStats);
    engine.rootContext()->setContextProperty("userSettings", &userSettings);
    engine.rootContext()->setContextProperty("fileManager", &fileManager);
    engine.rootContext()->setContextProperty("globalShortcuts", &globalShortcuts);

    engine.load(QUrl(QStringLiteral("qrc:/UNexusShell/qml/Main.qml")));

    if (engine.rootObjects().isEmpty())
        return -1;

    if (captureAssets) {
        auto *window = qobject_cast<QQuickWindow *>(engine.rootObjects().first());
        if (!window)
            return -1;

        runAssetCapture(app, window, window, args.at(captureIndex + 1));
        return app.exec();
    }

    globalShortcuts.start();

    return app.exec();
}
