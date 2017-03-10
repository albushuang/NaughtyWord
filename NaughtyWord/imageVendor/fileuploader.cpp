#include "fileuploader.h"
#include <QtDebug>
#include <QFileInfo>

FileUploader::FileUploader():
    m_uploadUrl(0),
    m_filePath(""),
    m_pReply(NULL)
{
    connect(&m_WebCtrl, SIGNAL (finished(QNetworkReply*)),
            this, SLOT (fileUploaded(QNetworkReply*)));
}

FileUploader::~FileUploader() { }

void FileUploader::progress(qint64 now, qint64 total) {
    emit progressing((double)now/1024/1024, total==-1?0:(double)total/1024/1024);
}

void FileUploader::fileUploaded(QNetworkReply* pReply) {
    m_networkReplyMsg = pReply->readAll();
    pReply->deleteLater();

    if (analyseUploaded(pReply)) {
        emit uploaded();
    } else { emit uploadFailed();    }

}

QString FileUploader::filePath() const {
    return m_filePath;
}

QByteArray FileUploader::networkReplyMsg() const {
    return m_networkReplyMsg;
}


bool FileUploader::analyseUploaded(QNetworkReply* pReply) {
    QNetworkReply::NetworkError error =  pReply->error();
    if (error!=QNetworkReply::NoError) {
        qWarning() << "network error!" << error;
        return false;
    }
    return true;
}

void FileUploader::setUploadUrl(const QUrl &url)
{
    // should check previous upload is completed or not...
    if (m_WebCtrl.networkAccessible() != true){
        emit networkUnavailable();
    }
//    else if (m_uploadUrl == url) { emit uploaded(); }
    else if (url.isEmpty() != true) {
        m_uploadUrl = url;
        m_request.setUrl(m_uploadUrl);

        m_file.open(QIODevice::ReadOnly);
        QByteArray data = m_file.readAll();
        m_file.close();

        m_pReply = m_WebCtrl.post(m_request, data);

        connect(m_pReply, SIGNAL(uploadProgress(qint64, qint64)), this, SLOT(progress(qint64, qint64)));

//        connect(m_pReply, SIGNAL(error(QNetworkReply::NetworkError)),this, SLOT(slotError(QNetworkReply::NetworkError)));
//        connect(m_pReply, SIGNAL(sslErrors(const QList<QSslError>&)),this, SLOT(ignoreSslErrors(const QList<QSslError>&)));

        emit uploadUrlChanged();
    }
}

void FileUploader::setFilePath(const QString path) {
    m_filePath = path;
    m_file.setFileName(path);

    setRowHeaders();
}

void FileUploader::setRowHeaders() {
    QFileInfo fileInfo(m_file.fileName());
    QString ext = fileInfo.suffix().toLower();
    QString contentType = getContentTypeByExtension(ext);

    qlonglong fileSize = fileInfo.size();

    m_request.setRawHeader("Content-Type", contentType.toLatin1());
    m_request.setRawHeader("Content-Length", (QString("%1").arg(fileSize)).toLatin1());

}

//void FileUploader::setStoragePath(const QString path) {
//    m_storagePath = path;
//    if(m_storagePath != ""){
//        if (!path.endsWith("/")) {m_storagePath += "/";}
//        if(m_storagePath.startsWith("file://")) {m_storagePath.remove(0, 7);}
//    }
//}

//void FileUploader::setFileName(const QString fileName) {
//    m_fileName = fileName;
//}

QUrl FileUploader::uploadUrl() const
{
    return m_uploadUrl;
}

QString FileUploader::getContentTypeByExtension(const QString &extension)
{
    QString contentType;

    if(extension == "doc" || extension == "docx") contentType = "application/msword";
    if(extension == "xls") contentType = "application/vnd.ms-excel";
    if(extension == "ppt" || extension == "pptx") contentType = "application/vnd.ms-powerpoint";
    if(extension == "pdf") contentType = "application/pdf";
    if(extension == "exe") contentType = "application/x-msdos-program";
    if(extension == "rar") contentType = "application/rar";
    if(extension == "png") contentType = "image/png";
    if(extension == "png") contentType = "application/rtf";
    if(extension == "tar") contentType = "application/x-tar";
    if(extension == "zip") contentType = "application/zip";
    if(extension == "") contentType = "";
    if(extension == "jpeg" || extension == "jpg" || extension == "jpe") contentType = "image/jpeg";
    if(extension == "gif") contentType = "image/gif";
    if(extension == "wav") contentType = "application/x-wav";
    if(extension == "tiff" || extension == "tif") contentType = "image/tiff";
    if(extension == "txt" || extension == "cpp" || extension == "h" || extension == "c") contentType = "text/plain";
    if(extension == "mpeg" || extension == "mpg" || extension == "mpe" ) contentType = "video/mpeg";
    if(extension == "qt" || extension == "mov") contentType = "video/quicktime";
    if(extension == "qvi") contentType = "video/x-msvideo";
    if(extension == "video/x-sgi-movie") contentType = "movie";
    if(extension == "exe") contentType = "application/x-msdos-program";
    if(extension == "kmr") contentType = "application/octet-stream";

    return contentType;
}
