#pragma once

#include <QObject>
#include <QProcess>
#include <QString>

class CommandRunner : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)
    Q_PROPERTY(QString output READ output NOTIFY outputChanged)
    Q_PROPERTY(QString workingDirectory READ workingDirectory WRITE setWorkingDirectory NOTIFY workingDirectoryChanged)

public:
    explicit CommandRunner(QObject *parent = nullptr);

    bool busy() const { return m_busy; }
    QString output() const { return m_output; }
    QString workingDirectory() const { return m_workingDirectory; }
    void setWorkingDirectory(const QString &directory);

    Q_INVOKABLE void run(const QString &command);
    Q_INVOKABLE void stop();
    Q_INVOKABLE void clear();

signals:
    void busyChanged();
    void outputChanged();
    void workingDirectoryChanged();

private slots:
    void readOutput();
    void processFinished(int exitCode, QProcess::ExitStatus exitStatus);
    void processError(QProcess::ProcessError error);

private:
    void setBusy(bool busy);
    void appendOutput(const QString &text);

    QProcess m_process;
    bool m_busy = false;
    QString m_output;
    QString m_workingDirectory;
};
