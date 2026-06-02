#pragma once

#include <QObject>
#include <QSettings>

class UserSettings : public QObject
{
    Q_OBJECT

    Q_PROPERTY(int themeIndex READ themeIndex WRITE setThemeIndex NOTIFY themeIndexChanged)
    Q_PROPERTY(bool statsOverlayVisible READ statsOverlayVisible WRITE setStatsOverlayVisible NOTIFY statsOverlayVisibleChanged)
    Q_PROPERTY(bool firstSetupCompleted READ firstSetupCompleted WRITE setFirstSetupCompleted NOTIFY firstSetupCompletedChanged)

public:
    explicit UserSettings(QObject *parent = nullptr);

    int themeIndex() const { return m_themeIndex; }
    bool statsOverlayVisible() const { return m_statsOverlayVisible; }
    bool firstSetupCompleted() const { return m_firstSetupCompleted; }

public slots:
    void setThemeIndex(int themeIndex);
    void setStatsOverlayVisible(bool visible);
    void setFirstSetupCompleted(bool completed);

signals:
    void themeIndexChanged();
    void statsOverlayVisibleChanged();
    void firstSetupCompletedChanged();

private:
    QSettings m_settings;
    int m_themeIndex = 0;
    bool m_statsOverlayVisible = false;
    bool m_firstSetupCompleted = false;
};