#ifndef FILEUPLOADER_H
#define FILEUPLOADER_H

#include <QObject>
#include <QByteArray>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QFile>

class FileUploader : public QObject
{
        Q_OBJECT
    Q_PROPERTY(QUrl uploadUrl READ uploadUrl WRITE setUploadUrl NOTIFY uploadUrlChanged)
//    Q_PROPERTY(QString storagePath READ storagePath WRITE setStoragePath)
//    Q_PROPERTY(QString fileName READ fileName WRITE setFileName)
    Q_PROPERTY(QString filePath READ filePath WRITE setFilePath)
    Q_PROPERTY(QString networkReplyMsg READ networkReplyMsg)

public:

    FileUploader(); // no parameter is allowed
    ~FileUploader();

    virtual bool analyseUploaded(QNetworkReply* pReply);
    QUrl uploadUrl() const;
//    QString storagePath() const;
//    QString fileName() const;
    QString filePath() const;
    QByteArray networkReplyMsg() const;

public Q_SLOTS:
    void setUploadUrl(const QUrl &arg);
//    void setStoragePath(const QString path);
//    void setFileName(const QString fileName);
    void setFilePath(const QString filePath);

Q_SIGNALS:
//signals:
    void uploaded();
    void uploadFailed();
    void uploadUrlChanged();
    void networkUnavailable();
    void progressing(double received, double total);

private slots:
    void fileUploaded(QNetworkReply* pReply);
    void progress(qint64, qint64);

protected:
//    QByteArray m_downloadedData;
    QNetworkAccessManager m_WebCtrl;
    QNetworkRequest m_request;
    QUrl m_uploadUrl;

private:
    void saveFile();
    void setRowHeaders();
    QString getContentTypeByExtension(const QString &extension);

    QFile m_file;
//    QString m_storagePath;
//    QString m_fileName;
    QString m_filePath;
    QByteArray m_networkReplyMsg;
    QNetworkReply *m_pReply;
};

#endif // FILEUPLOADER_H
