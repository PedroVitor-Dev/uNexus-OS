#pragma once

#include <QObject>
#include <QProcess>
#include <QString>

class AIEngine : public QObject
{
    Q_OBJECT

public:
    explicit AIEngine(QObject *parent = nullptr);
    ~AIEngine() override;

    bool start(const QString &modelPath);
    void stop();
    bool isRunning() const;
    quint16 port() const { return m_port; }

signals:
    void engineStarted();
    void engineStopped();
    void engineError(const QString &message);

private:
    QString findLlamaServerBinary() const;
    quint16 pickFreeLoopbackPort() const;

    QProcess *m_process = nullptr;
    quint16 m_port = 0;
};
