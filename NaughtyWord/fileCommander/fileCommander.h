#ifndef FILECOMMANDER_H
#define FILECOMMANDER_H

#include <QObject>
#include <QByteArray>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>

class FileCommander : public QObject
{
    Q_OBJECT
public:

    FileCommander(); // no parameter is allowed
    ~FileCommander();

    typedef enum {
        cmd_rename, cmd_copy, cmd_remove, cmd_removeDir
    } FileCommand;

public Q_SLOTS:
    bool rename(const QString &fullPatn, const QString &targetName);
    bool copy(const QString &fullPatn, const QString &targetName);
    bool remove(const QString &fullPatn);
    bool removeDir(const QString &fullPath);
    bool renameDir(const QString &fullPath, const QString &shortTarget);
    bool copyDir(const QString &sFullPatn, const QString &tFullPath);
    static bool exists(const QString fullPath);
Q_SIGNALS:
    void commandDone();

signals:
    void sigCommand(const FileCommand);

private slots:

private:
    QString m_source;
    QString m_target;
};

#endif // FILECOMMANDER_H


