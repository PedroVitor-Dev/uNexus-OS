#include "usersettings.h"

UserSettings::UserSettings(QObject *parent)
    : QObject(parent)
    , m_settings("uNexus", "unexus-shell")
{
    m_themeIndex = m_settings.value("appearance/themeIndex", 0).toInt();
    m_languageCode = m_settings.value("locale/languageCode", "en").toString();
    if (m_languageCode != "pt-BR")
        m_languageCode = "en";
    m_statsOverlayVisible = m_settings.value("appearance/statsOverlayVisible", false).toBool();
    m_firstSetupCompleted = m_settings.value("setup/firstSetupCompleted", false).toBool();
    m_controlCenterSection = m_settings.value("controlCenter/section", "system").toString();
    if (m_controlCenterSection != "system" && m_controlCenterSection != "shortcuts" &&
        m_controlCenterSection != "appearance" &&
        m_controlCenterSection != "language" && m_controlCenterSection != "about")
        m_controlCenterSection = "system";
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

void UserSettings::setControlCenterSection(const QString &section)
{
    QString normalizedSection = section;
    if (normalizedSection != "system" && normalizedSection != "shortcuts" &&
        normalizedSection != "appearance" &&
        normalizedSection != "language" && normalizedSection != "about")
        normalizedSection = "system";

    if (m_controlCenterSection == normalizedSection)
        return;

    m_controlCenterSection = normalizedSection;
    m_settings.setValue("controlCenter/section", m_controlCenterSection);
    emit controlCenterSectionChanged();
}
