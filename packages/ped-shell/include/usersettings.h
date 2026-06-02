#pragma once

#include <QObject>
#include <QSettings>

class UserSettings : public QObject
{
    Q_OBJECT

    Q_PROPERTY(int themeIndex READ themeIndex WRITE setThemeIndex NOTIFY themeIndexChanged)
    Q_PROPERTY(bool statsOverlayVisible READ statsOverlayVisible WRITE setStatsOverlayVisible NOTIFY statsOverlayVisibleChanged)

public:
    explicit UserSettings(QObject *parent = nullptr);

    int themeIndex() const { return m_themeIndex; }
    bool statsOverlayVisible() const { return m_statsOverlayVisible; }

public slots:
    void setThemeIndex(int themeIndex);
    void setStatsOverlayVisible(bool visible);

signals:
    void themeIndexChanged();
    void statsOverlayVisibleChanged();

private:
    QSettings m_settings;
    int m_themeIndex = 0;
    bool m_statsOverlayVisible = false;
};