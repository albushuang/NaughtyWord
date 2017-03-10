#include "filedownloader.h"
#include <QtDebug>
#include <QFile>

FileDownloader::FileDownloader():
    m_downloadedData(0),
    m_fileUrl(0),
    m_pReply(NULL),
    m_status(NONE),
    m_storagePath(""),
    m_fileName(""),
    m_filePath("")
{
    connect(&m_WebCtrl, SIGNAL (finished(QNetworkReply*)),
            this, SLOT (fileDownloaded(QNetworkReply*)));
}

FileDownloader::~FileDownloader() { }

void FileDownloader::progress(qint64 now, qint64 total) {
    emit progressing((double)now/1024/1024, total==-1?0:(double)total/1024/1024);
}

void FileDownloader::saveFile() {
    m_filePath = m_storagePath + (m_fileName != "" ? m_fileName : m_fileUrl.fileName());
    QFile save(m_filePath);
    if (save.open(QIODevice::WriteOnly)!=true) {
        qWarning() << m_filePath << "open failed!";
        return;
    }
    save.write(m_downloadedData);
    save.close();
}

QStringList tryRedirect(FileDownloader *dl, QNetworkReply* pReply) {
    QString org = pReply->url().toString();
    QString red;
    QVariant possibleRedirectUrl =
             pReply->attribute(QNetworkRequest::RedirectionTargetAttribute);
    if (! possibleRedirectUrl.isNull() ) {
        red = possibleRedirectUrl.toString();
        dl->setFileUrl(red);
        return QStringList() << org << red;
    }
    return QStringList();
}

QString extractRedirectUrl(QByteArray & source) {
    QString analysis = source;
    QStringList hList; hList << "<a href=\"" << "url=" << "replace(\"" << "action=\"";
    QString endHeader = "\"";
    for (int i=0;i<hList.count();i++) {
        int b = analysis.indexOf(hList[i]);
        if(b<0) continue;
        analysis.remove(0, b+hList[i].length());
        int e = analysis.indexOf(endHeader);
        return analysis.left(e);
    }
    return "";
}

QStringList downloadRedirected(FileDownloader *dl, QNetworkReply* pReply, QByteArray & data) {
    QString org = pReply->url().toString();
    QString red;
    if(pReply->hasRawHeader("Location")) {
        red = pReply->rawHeader("Location");
        dl->setFileUrl(red);
    } else {
        red = extractRedirectUrl(data);
        dl->setFileUrl(red);
    }
    return QStringList() << org << red;
}

void FileDownloader::fileDownloaded(QNetworkReply* pReply) {
    m_downloadedData = pReply->readAll();
    if(pReply->hasRawHeader("Content-Disposition")) {
        QString disp = pReply->rawHeader("Content-Disposition");
        if(disp.startsWith("attachment;")) {
            int nameInd = disp.indexOf("filename=");
            disp.remove(0,nameInd+9);
            if(disp.startsWith("\"")) { disp.remove(0,1); }
            if(disp.endsWith("\"")) { disp.remove(disp.length()-1, 1); }
            if(m_fileName=="") { m_fileName = disp; }
        }
    }
    if (analyseDownloaded(pReply)) {
        if(m_downloadedData.size() != 0) {
            if(pReply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt() == 301) {
                QStringList sig = downloadRedirected(this, pReply, m_downloadedData);
                redirected(sig[0], sig[1]);
            } else {
                if (m_storagePath!="") { saveFile(); }
                m_status = FINISHED;
                emit downloaded();
            }
        } else {
            QStringList sig = tryRedirect(this, pReply);
            if(!sig.isEmpty()) {
                redirected(sig[0], sig[1]);
            } else { m_status = FAILED; }
        }
    } else {
        emit downloadFailed();
        m_status = FAILED;
    }
    pReply->deleteLater();
}

QString FileDownloader::storagePath() const{
    return m_storagePath;
}

QString FileDownloader::fileName() const{
    return m_fileName;
}

QString FileDownloader::fileFullPath() const {
    return m_filePath;
}

bool FileDownloader::analyseDownloaded(QNetworkReply* pReply) {
    QNetworkReply::NetworkError error =  pReply->error();
    if (error!=QNetworkReply::NoError) {
        m_downloadedData.resize(0);
        qWarning() << "network error!" << error;
        return false;
    }
    return true;
}

QByteArray FileDownloader::downloadedData() const {
    return m_downloadedData;
}

QByteArray FileDownloader::downloadedDataBase64() const {
    return m_downloadedData.toBase64();
}

QUrl FileDownloader::convert(QString url) const {
    return (QUrl) url;
}

void FileDownloader::setFileUrl(const QUrl &arg)
{
    // should check previous download is completed or not...
    if (m_WebCtrl.networkAccessible() != true){
        m_downloadedData.resize(0);
        m_status = NETWORK_ISSUE;
        emit networkUnavailable();
    }
    else if (m_fileUrl == arg) {
        if (m_status == LOADING) { emit waiting(); return; }
        else if (m_status == FINISHED) { emit downloaded(); return; }
        // if failed, try again!
    } else { emit fileUrlChanged(); }

    m_fileUrl = arg;

    if (arg.isEmpty()) {
        m_downloadedData.resize(0);
        m_status = FAILED;
        emit downloadFailed();
        return;
    }
    QNetworkRequest request(m_fileUrl);
    m_pReply = m_WebCtrl.get(request);
    m_status = LOADING;
    connect(m_pReply, SIGNAL (downloadProgress(qint64, qint64)),
                this, SLOT (progress(qint64, qint64)));
    connect(m_pReply, SIGNAL(sslErrors(QList<QSslError>)),
            m_pReply, SLOT(ignoreSslErrors()));

}

void FileDownloader::setStoragePath(const QString path) {
    m_storagePath = path;
    if(m_storagePath != ""){
        if (!path.endsWith("/")) {m_storagePath += "/";}
        if(m_storagePath.startsWith("file://")) {m_storagePath.remove(0, 7);}
    }
}

void FileDownloader::setFileName(const QString fileName) {
    m_fileName = fileName;
}

QUrl FileDownloader::fileUrl() const
{
    return m_fileUrl;
}

QByteArray* FileDownloader::downloadedNetVendor() {
    return &m_downloadedData;
}

QUrl* FileDownloader::downloadedUrlNetVendor() {
    return &m_fileUrl;
}

