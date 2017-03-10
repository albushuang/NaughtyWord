#ifndef QTDropboxQml_H
#define QTDropboxQml_H

#include <QObject>
#include <QByteArray>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QFile>
#include "../dropboxLib/qtdropbox.h"

class QTDropboxQml : public QDropboxFile
{
    Q_OBJECT

    Q_PROPERTY(QString fileList READ fileList WRITE setFileList NOTIFY fileListChanged)
    Q_PROPERTY(QString fileName READ fileName WRITE setFileName)
    Q_PROPERTY(QString storagePath READ storagePath WRITE setStoragePath)

public:

    QTDropboxQml(); // no parameter is allowed
    ~QTDropboxQml();
    QString fileList() const;
    QString fileName() const;
    QString storagePath() const;

public Q_SLOTS:
    void start();
    void logout();
    void continueUnfinished();
    void setFileList(const QString fileList);
    void setFileName(const QString fileName);
    void setStoragePath(const QString path);
    void download(const QString fileName);
    void upload(const QString localFullFilePath, const QString networkFilePath);
    QString requestSharedLink(QString file);

Q_SIGNALS:
    void requestUserConsent(QString authUrl);
    void dbConnected();
    void fileListChanged();
    void downloaded();
    void uploaded();
    void progressing(double received, double total);
    void logoutFinished();


private slots:
    void fillFileList();
    void saveFile();
    void progress(qint64, qint64);

private:    
    bool connectDropbox(QDropbox::OAuthMethod m);
    QDropbox dropbox;
    QFile tokenFile;
    QString m_storagePath;
    QString m_fileName;
    QString m_fileList;
};

#endif // QTDropboxQml_H


