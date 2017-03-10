#ifndef FILEDOWNLOADER_H
#define FILEDOWNLOADER_H

#include <QObject>
#include <QByteArray>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include "internetvendor.h"

class FileDownloader : public NetVendor
{
    Q_OBJECT

    Q_PROPERTY(QUrl fileUrl READ fileUrl WRITE setFileUrl NOTIFY fileUrlChanged)
    Q_PROPERTY(QString storagePath READ storagePath WRITE setStoragePath)
    Q_PROPERTY(QString fileName READ fileName WRITE setFileName)
    Q_PROPERTY(QString fileFullPath READ fileFullPath)
    Q_PROPERTY(QString downloadedDataString READ downloadedData)
    Q_PROPERTY(QByteArray downloadedData READ downloadedData)

public:

    enum STATUS{
        NONE,
        LOADING,
        FINISHED,
        FAILED,
        NETWORK_ISSUE,
    };

    FileDownloader(); // no parameter is allowed
    ~FileDownloader();
    QUrl fileUrl() const;
    QByteArray downloadedData() const;
    QByteArray downloadedDataBase64() const;
    virtual bool analyseDownloaded(QNetworkReply* pReply);
    QString storagePath() const;
    QString fileName() const;
    QString fileFullPath() const;

public Q_SLOTS:
    FileDownloader* self() { return this; }
    void setFileUrl(const QUrl &arg);
    void setStoragePath(const QString path);
    void setFileName(const QString fileName);
    //PRAGMA: NetVendor protocol
    virtual QByteArray* downloadedNetVendor();
    virtual QUrl* downloadedUrlNetVendor();
    QUrl convert(QString url) const;

Q_SIGNALS:
//signals:
    void downloaded();
    void downloadFailed();
    void waiting();
    void fileUrlChanged();
    void networkUnavailable();
    void redirected(QString original, QString redirect);
    void progressing(double received, double total);

public slots:
    void progress(qint64, qint64);

private slots:
    void fileDownloaded(QNetworkReply* pReply);

protected:
    QByteArray m_downloadedData;
    QNetworkAccessManager m_WebCtrl;
    QUrl m_fileUrl;
    QNetworkReply *m_pReply;
    STATUS m_status;

private:
    void saveFile();


    QString m_storagePath;
    QString m_fileName;
    QString m_filePath;

};

#endif // FILEDOWNLOADER_H


