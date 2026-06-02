#include "usersettings.h"

UserSettings::UserSettings(QObject *parent)
    : QObject(parent)
    , m_settings("PED OS", "ped-shell")
{
    m_themeIndex = m_settings.value("appearance/themeIndex", 0).toInt();
    m_statsOverlayVisible = m_settings.value("appearance/statsOverlayVisible", false).toBool();
}

void UserSettings::setThemeIndex(int themeIndex)
{
    if (themeIndex < 0)
        themeIndex = 0;

    if (themeIndex > 3)
        themeIndex = 3;

    if (m_themeIndex == themeIndex)
        return;

    m_themeIndex = themeIndex;
    m_settings.setValue("appearance/themeIndex", m_themeIndex);
    emit themeIndexChanged();
}

void UserSettings::setStatsOverlayVisible(bool visible)
{
    if (m_statsOverlayVisible == visible)
        return;

    m_statsOverlayVisible = visible;
    m_settings.setValue("appearance/statsOverlayVisible", m_statsOverlayVisible);
    emit statsOverlayVisibleChanged();
}