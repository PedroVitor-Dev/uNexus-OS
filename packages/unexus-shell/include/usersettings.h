#pragma once

#include <QObject>
#include <QSettings>

class UserSettings : public QObject
{
    Q_OBJECT

    Q_PROPERTY(int themeIndex READ themeIndex WRITE setThemeIndex NOTIFY themeIndexChanged)
    Q_PROPERTY(QString languageCode READ languageCode WRITE setLanguageCode NOTIFY languageCodeChanged)
    Q_PROPERTY(bool statsOverlayVisible READ statsOverlayVisible WRITE setStatsOverlayVisible NOTIFY statsOverlayVisibleChanged)
    Q_PROPERTY(bool firstSetupCompleted READ firstSetupCompleted WRITE setFirstSetupCompleted NOTIFY firstSetupCompletedChanged)
    Q_PROPERTY(bool notificationsEnabled READ notificationsEnabled WRITE setNotificationsEnabled NOTIFY notificationsEnabledChanged)
    Q_PROPERTY(QString wallpaperId READ wallpaperId WRITE setWallpaperId NOTIFY wallpaperIdChanged)
    Q_PROPERTY(QString launcherShortcut READ launcherShortcut WRITE setLauncherShortcut NOTIFY launcherShortcutChanged)
    Q_PROPERTY(QString settingsShortcut READ settingsShortcut WRITE setSettingsShortcut NOTIFY settingsShortcutChanged)
    Q_PROPERTY(QString gameSettingsShortcut READ gameSettingsShortcut WRITE setGameSettingsShortcut NOTIFY gameSettingsShortcutChanged)
    Q_PROPERTY(QString statsShortcut READ statsShortcut WRITE setStatsShortcut NOTIFY statsShortcutChanged)
    Q_PROPERTY(QString bugReportShortcut READ bugReportShortcut WRITE setBugReportShortcut NOTIFY bugReportShortcutChanged)
    Q_PROPERTY(QString updateChannel READ updateChannel WRITE setUpdateChannel NOTIFY updateChannelChanged)
    Q_PROPERTY(QString controlCenterSection READ controlCenterSection WRITE setControlCenterSection NOTIFY controlCenterSectionChanged)
    Q_PROPERTY(int notificationTimeoutSeconds READ notificationTimeoutSeconds WRITE setNotificationTimeoutSeconds NOTIFY notificationTimeoutSecondsChanged)

public:
    explicit UserSettings(QObject *parent = nullptr);

    int themeIndex() const { return m_themeIndex; }
    QString languageCode() const { return m_languageCode; }
    bool statsOverlayVisible() const { return m_statsOverlayVisible; }
    bool firstSetupCompleted() const { return m_firstSetupCompleted; }
    bool notificationsEnabled() const { return m_notificationsEnabled; }
    QString wallpaperId() const { return m_wallpaperId; }
    QString launcherShortcut() const { return m_launcherShortcut; }
    QString settingsShortcut() const { return m_settingsShortcut; }
    QString gameSettingsShortcut() const { return m_gameSettingsShortcut; }
    QString statsShortcut() const { return m_statsShortcut; }
    QString bugReportShortcut() const { return m_bugReportShortcut; }
    QString updateChannel() const { return m_updateChannel; }
    QString controlCenterSection() const { return m_controlCenterSection; }
    int notificationTimeoutSeconds() const { return m_notificationTimeoutSeconds; }

public slots:
    void setThemeIndex(int themeIndex);
    void setLanguageCode(const QString &languageCode);
    void setStatsOverlayVisible(bool visible);
    void setFirstSetupCompleted(bool completed);
    void setNotificationsEnabled(bool enabled);
    void setWallpaperId(const QString &wallpaperId);
    void setLauncherShortcut(const QString &shortcut);
    void setSettingsShortcut(const QString &shortcut);
    void setGameSettingsShortcut(const QString &shortcut);
    void setStatsShortcut(const QString &shortcut);
    void setBugReportShortcut(const QString &shortcut);
    void setUpdateChannel(const QString &channel);
    void setControlCenterSection(const QString &section);
    void setNotificationTimeoutSeconds(int seconds);

signals:
    void themeIndexChanged();
    void languageCodeChanged();
    void statsOverlayVisibleChanged();
    void firstSetupCompletedChanged();
    void notificationsEnabledChanged();
    void wallpaperIdChanged();
    void launcherShortcutChanged();
    void settingsShortcutChanged();
    void gameSettingsShortcutChanged();
    void statsShortcutChanged();
    void bugReportShortcutChanged();
    void updateChannelChanged();
    void controlCenterSectionChanged();
    void notificationTimeoutSecondsChanged();

private:
    QSettings m_settings;
    int m_themeIndex = 0;
    QString m_languageCode = "en";
    bool m_statsOverlayVisible = false;
    bool m_firstSetupCompleted = false;
    bool m_notificationsEnabled = true;
    QString m_wallpaperId = "unexus-core";
    QString m_launcherShortcut = "Meta+S";
    QString m_settingsShortcut = "Meta+I";
    QString m_gameSettingsShortcut = "Meta+Alt+G";
    QString m_statsShortcut = "Meta+G";
    QString m_bugReportShortcut = "Meta+B";
    QString m_updateChannel = "stable";
    QString m_controlCenterSection = "system";
    int m_notificationTimeoutSeconds = 7;
};
