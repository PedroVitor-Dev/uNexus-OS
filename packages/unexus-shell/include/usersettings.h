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
    Q_PROPERTY(QString launcherShortcut READ launcherShortcut WRITE setLauncherShortcut NOTIFY launcherShortcutChanged)
    Q_PROPERTY(QString settingsShortcut READ settingsShortcut WRITE setSettingsShortcut NOTIFY settingsShortcutChanged)
    Q_PROPERTY(QString gameSettingsShortcut READ gameSettingsShortcut WRITE setGameSettingsShortcut NOTIFY gameSettingsShortcutChanged)
    Q_PROPERTY(QString statsShortcut READ statsShortcut WRITE setStatsShortcut NOTIFY statsShortcutChanged)
    Q_PROPERTY(QString controlCenterSection READ controlCenterSection WRITE setControlCenterSection NOTIFY controlCenterSectionChanged)

public:
    explicit UserSettings(QObject *parent = nullptr);

    int themeIndex() const { return m_themeIndex; }
    QString languageCode() const { return m_languageCode; }
    bool statsOverlayVisible() const { return m_statsOverlayVisible; }
    bool firstSetupCompleted() const { return m_firstSetupCompleted; }
    bool notificationsEnabled() const { return m_notificationsEnabled; }
    QString launcherShortcut() const { return m_launcherShortcut; }
    QString settingsShortcut() const { return m_settingsShortcut; }
    QString gameSettingsShortcut() const { return m_gameSettingsShortcut; }
    QString statsShortcut() const { return m_statsShortcut; }
    QString controlCenterSection() const { return m_controlCenterSection; }

public slots:
    void setThemeIndex(int themeIndex);
    void setLanguageCode(const QString &languageCode);
    void setStatsOverlayVisible(bool visible);
    void setFirstSetupCompleted(bool completed);
    void setNotificationsEnabled(bool enabled);
    void setLauncherShortcut(const QString &shortcut);
    void setSettingsShortcut(const QString &shortcut);
    void setGameSettingsShortcut(const QString &shortcut);
    void setStatsShortcut(const QString &shortcut);
    void setControlCenterSection(const QString &section);

signals:
    void themeIndexChanged();
    void languageCodeChanged();
    void statsOverlayVisibleChanged();
    void firstSetupCompletedChanged();
    void notificationsEnabledChanged();
    void launcherShortcutChanged();
    void settingsShortcutChanged();
    void gameSettingsShortcutChanged();
    void statsShortcutChanged();
    void controlCenterSectionChanged();

private:
    QSettings m_settings;
    int m_themeIndex = 0;
    QString m_languageCode = "en";
    bool m_statsOverlayVisible = false;
    bool m_firstSetupCompleted = false;
    bool m_notificationsEnabled = true;
    QString m_launcherShortcut = "Meta+Space";
    QString m_settingsShortcut = "Meta+I";
    QString m_gameSettingsShortcut = "Meta+G";
    QString m_statsShortcut = "Meta+Alt+G";
    QString m_controlCenterSection = "system";
};
