#pragma once

#include <QObject>
#include <QNetworkAccessManager>
#include <QString>
#include <QStringList>

#include "aiengine.h"

class GameMode;
class SystemInfo;
class SystemStats;
class UserSettings;

class AIAssistant : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool ready READ isReady NOTIFY readyChanged)
    Q_PROPERTY(bool busy READ isBusy NOTIFY busyChanged)
    Q_PROPERTY(bool networkLocked READ networkLocked CONSTANT)

public:
    explicit AIAssistant(SystemInfo *systemInfo, SystemStats *stats, GameMode *gameMode, UserSettings *settings, QObject *parent = nullptr);

    bool isReady() const { return m_ready; }
    bool isBusy() const { return m_busy; }
    bool networkLocked() const { return true; }

    Q_INVOKABLE void startEngine(const QString &modelPath);
    Q_INVOKABLE void stopEngine();
    Q_INVOKABLE void sendMessage(const QString &userText);
    Q_INVOKABLE void clearHistory();
    Q_INVOKABLE QString defaultModelDirectory() const;
    Q_INVOKABLE QStringList installedModelPaths() const;

signals:
    void readyChanged();
    void busyChanged();
    void tokenReceived(const QString &partialText);
    void responseFinished();
    void errorOccurred(const QString &message);
    void historyCleared();

private:
    void setReady(bool ready);
    void setBusy(bool busy);
    QString buildSystemPrompt() const;
    QString gatherLocalSystemContext() const;
    void processSseChunk(const QByteArray &chunk);
    void loadHistoryIfEnabled();
    void persistHistoryIfEnabled() const;
    void removePersistedHistory() const;
    QString historyFilePath() const;

    AIEngine *m_engine = nullptr;
    QNetworkAccessManager *m_net = nullptr;
    SystemInfo *m_systemInfo = nullptr;
    SystemStats *m_stats = nullptr;
    GameMode *m_gameMode = nullptr;
    UserSettings *m_settings = nullptr;
    QStringList m_history;
    QString m_sseBuffer;
    QString m_currentAssistantResponse;
    bool m_ready = false;
    bool m_busy = false;
};
