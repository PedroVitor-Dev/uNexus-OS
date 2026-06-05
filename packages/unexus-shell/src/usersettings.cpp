#include "usersettings.h"

UserSettings::UserSettings(QObject *parent)
    : QObject(parent)
    , m_settings("uNexus", "unexus-shell")
{
    m_themeIndex = m_settings.value("appearance/themeIndex", 0).toInt();
    if (m_themeIndex < 0 || m_themeIndex > 5)
        m_themeIndex = 0;
    m_languageCode = m_settings.value("locale/languageCode", "en").toString();
    if (m_languageCode != "pt-BR")
        m_languageCode = "en";
    m_statsOverlayVisible = m_settings.value("appearance/statsOverlayVisible", false).toBool();
    m_firstSetupCompleted = m_settings.value("setup/firstSetupCompleted", false).toBool();
    m_notificationsEnabled = m_settings.value("notifications/enabled", true).toBool();
    m_wallpaperId = m_settings.value("appearance/wallpaperId", "unexus-core").toString();
    if (m_wallpaperId != "unexus-core" && m_wallpaperId != "particle-drift" &&
        m_wallpaperId != "aurora-ice" && m_wallpaperId != "ember-circuit")
        m_wallpaperId = "unexus-core";
    m_launcherShortcut = m_settings.value("shortcuts/launcher", "Meta+S").toString();
    m_settingsShortcut = m_settings.value("shortcuts/settings", "Meta+I").toString();
    m_gameSettingsShortcut = m_settings.value("shortcuts/gameSettings", "Meta+Alt+G").toString();
    m_statsShortcut = m_settings.value("shortcuts/stats", "Meta+G").toString();
    if (m_launcherShortcut.trimmed().isEmpty() || m_launcherShortcut == "Meta+Space")
        m_launcherShortcut = "Meta+S";
    if (m_settingsShortcut.trimmed().isEmpty())
        m_settingsShortcut = "Meta+I";
    if (m_gameSettingsShortcut.trimmed().isEmpty())
        m_gameSettingsShortcut = "Meta+Alt+G";
    if (m_gameSettingsShortcut == "Meta+G" && m_statsShortcut == "Meta+Alt+G") {
        m_gameSettingsShortcut = "Meta+Alt+G";
        m_statsShortcut = "Meta+G";
    }
    if (m_statsShortcut.trimmed().isEmpty())
        m_statsShortcut = "Meta+G";
    m_settings.setValue("shortcuts/launcher", m_launcherShortcut);
    m_settings.setValue("shortcuts/settings", m_settingsShortcut);
    m_settings.setValue("shortcuts/gameSettings", m_gameSettingsShortcut);
    m_settings.setValue("shortcuts/stats", m_statsShortcut);
    m_controlCenterSection = m_settings.value("controlCenter/section", "system").toString();
    if (m_controlCenterSection != "system" && m_controlCenterSection != "shortcuts" && m_controlCenterSection != "help" &&
        m_controlCenterSection != "appearance" &&
        m_controlCenterSection != "language" && m_controlCenterSection != "about")
        m_controlCenterSection = "system";
}

void UserSettings::setThemeIndex(int themeIndex)
{
    if (themeIndex < 0)
        themeIndex = 0;

    if (themeIndex > 5)
        themeIndex = 5;

    if (m_themeIndex == themeIndex)
        return;

    m_themeIndex = themeIndex;
    m_settings.setValue("appearance/themeIndex", m_themeIndex);
    emit themeIndexChanged();
}

void UserSettings::setLanguageCode(const QString &languageCode)
{
    const QString normalizedLanguage = languageCode == "pt-BR" ? "pt-BR" : "en";

    if (m_languageCode == normalizedLanguage)
        return;

    m_languageCode = normalizedLanguage;
    m_settings.setValue("locale/languageCode", m_languageCode);
    emit languageCodeChanged();
}

void UserSettings::setStatsOverlayVisible(bool visible)
{
    if (m_statsOverlayVisible == visible)
        return;

    m_statsOverlayVisible = visible;
    m_settings.setValue("appearance/statsOverlayVisible", m_statsOverlayVisible);
    emit statsOverlayVisibleChanged();
}

void UserSettings::setFirstSetupCompleted(bool completed)
{
    if (m_firstSetupCompleted == completed)
        return;

    m_firstSetupCompleted = completed;
    m_settings.setValue("setup/firstSetupCompleted", m_firstSetupCompleted);
    emit firstSetupCompletedChanged();
}

void UserSettings::setNotificationsEnabled(bool enabled)
{
    if (m_notificationsEnabled == enabled)
        return;

    m_notificationsEnabled = enabled;
    m_settings.setValue("notifications/enabled", m_notificationsEnabled);
    emit notificationsEnabledChanged();
}

void UserSettings::setWallpaperId(const QString &wallpaperId)
{
    QString normalizedWallpaper = wallpaperId.trimmed();
    if (normalizedWallpaper != "unexus-core" && normalizedWallpaper != "particle-drift" &&
        normalizedWallpaper != "aurora-ice" && normalizedWallpaper != "ember-circuit")
        normalizedWallpaper = "unexus-core";

    if (m_wallpaperId == normalizedWallpaper)
        return;

    m_wallpaperId = normalizedWallpaper;
    m_settings.setValue("appearance/wallpaperId", m_wallpaperId);
    emit wallpaperIdChanged();
}
void UserSettings::setLauncherShortcut(const QString &shortcut)
{
    const QString normalizedShortcut = shortcut.trimmed().isEmpty() ? QStringLiteral("Meta+S") : shortcut.trimmed();
    if (m_launcherShortcut == normalizedShortcut)
        return;

    m_launcherShortcut = normalizedShortcut;
    m_settings.setValue("shortcuts/launcher", m_launcherShortcut);
    emit launcherShortcutChanged();
}

void UserSettings::setSettingsShortcut(const QString &shortcut)
{
    const QString normalizedShortcut = shortcut.trimmed().isEmpty() ? QStringLiteral("Meta+I") : shortcut.trimmed();
    if (m_settingsShortcut == normalizedShortcut)
        return;

    m_settingsShortcut = normalizedShortcut;
    m_settings.setValue("shortcuts/settings", m_settingsShortcut);
    emit settingsShortcutChanged();
}

void UserSettings::setGameSettingsShortcut(const QString &shortcut)
{
    const QString normalizedShortcut = shortcut.trimmed().isEmpty() ? QStringLiteral("Meta+Alt+G") : shortcut.trimmed();
    if (m_gameSettingsShortcut == normalizedShortcut)
        return;

    m_gameSettingsShortcut = normalizedShortcut;
    m_settings.setValue("shortcuts/gameSettings", m_gameSettingsShortcut);
    emit gameSettingsShortcutChanged();
}

void UserSettings::setStatsShortcut(const QString &shortcut)
{
    const QString normalizedShortcut = shortcut.trimmed().isEmpty() ? QStringLiteral("Meta+G") : shortcut.trimmed();
    if (m_statsShortcut == normalizedShortcut)
        return;

    m_statsShortcut = normalizedShortcut;
    m_settings.setValue("shortcuts/stats", m_statsShortcut);
    emit statsShortcutChanged();
}

void UserSettings::setControlCenterSection(const QString &section)
{
    QString normalizedSection = section;
    if (normalizedSection != "system" && normalizedSection != "shortcuts" && normalizedSection != "help" &&
        normalizedSection != "appearance" &&
        normalizedSection != "language" && normalizedSection != "about")
        normalizedSection = "system";

    if (m_controlCenterSection == normalizedSection)
        return;

    m_controlCenterSection = normalizedSection;
    m_settings.setValue("controlCenter/section", m_controlCenterSection);
    emit controlCenterSectionChanged();
}
