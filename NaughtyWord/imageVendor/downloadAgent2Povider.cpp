#include "downloadAgent2Povider.h"
#include <QtDebug>
#include <Qbuffer>
#include <QPainter>
#include "jdecode2bmp.h"


DownloadAgent2Provider::DownloadAgent2Provider(): m_pbox(NULL), m_pItem(NULL) {
    connect(&m_WebCtrl, SIGNAL (finished(QNetworkReply*)),
            this, SLOT (transferMedia(QNetworkReply*)));
}

DownloadAgent2Provider::~DownloadAgent2Provider(){ }

bool DownloadAgent2Provider::getFromMediaBox(QString url) {
    if(m_pbox!=NULL) {
        QByteArray *pb = m_pbox->getFromMediaBox(url);
        if(pb!=NULL) {
            m_downloadedData = *pb;
            return true;
        }
    }
    return false;
}


void DownloadAgent2Provider::setFileUrl(const QUrl &arg)
{
    if (m_WebCtrl.networkAccessible() != true){
        m_downloadedData.resize(0);
        m_status = NETWORK_ISSUE;
        emit networkUnavailable();
    }
    else if (m_fileUrl == arg) {
        if (m_status == LOADING) { emit waiting(); return; }
        else if (m_status == FINISHED) { emit downloaded(); return; }
    } else { emit fileUrlChanged(); }

    if (arg.isEmpty()) {
        m_downloadedData.resize(0);
        m_status = FAILED;
        emit downloadFailed();
        return;
    }

    m_fileUrl = arg;
    if(getFromMediaBox(arg.toString())) {
        m_status = FINISHED;
        emit downloaded();
        emit imageReady(arg.toString());
        return;
    } else if(m_status==LOADING) { m_pReply->abort(); }

    QNetworkRequest request(m_fileUrl);
    request.setRawHeader("User-Agent", "Naughty Word");
    request.setRawHeader("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8");

    m_pReply = m_WebCtrl.get(request);
    m_status = LOADING;
    connect(m_pReply, SIGNAL (downloadProgress(qint64, qint64)),
                this, SLOT (progress(qint64, qint64)));
    connect(m_pReply, SIGNAL(sslErrors(QList<QSslError>)),
            m_pReply, SLOT(ignoreSslErrors()));

}

void DownloadAgent2Provider::transferMedia(QNetworkReply* pReply) {
    if(pReply->error()!=QNetworkReply::NoError) { return; }
    int statusCode = pReply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    if(statusCode == 301) { return; }

    if(m_pbox) {
        m_fileUrl = pReply->url();
        if(m_pbox->putInMediaBox(m_downloadedData, pReply->url().toString())>=0) {
            emit imageReady(pReply->url().toString());
        } else {
            emit imageInvalid(pReply->url().toString());
        }
    }
}

void DownloadAgent2Provider::setMediaBox(MediaBox *box) {
    m_pbox = box;
}

QImage DownloadAgent2Provider::getImage(){
    QImage image = QImage::fromData(m_downloadedData, 0);
    if(image.format()==QImage::Format_Invalid) {
        image = transcodeImage();
    }
    if (image.hasAlphaChannel())
    {
        QImage bk = QImage(image.width(), image.height(), QImage::Format_RGB32);
        bk.fill(Qt::white);
        QPainter painter(&bk);
        painter.drawImage(QPoint(0,0), image);
        painter.end();
        image = bk;
    }
    return image;
}

void DownloadAgent2Provider::saveImage(QImage& image){
    m_downloadedData.clear();
    QBuffer buffer;
    buffer.setBuffer(&m_downloadedData);
    buffer.open( QIODevice::WriteOnly);
    image.save( &buffer,"JPG", 70);
}


bool DownloadAgent2Provider::cropResizeImage(int x, int y, int w, int h,
                                             int width, int height) {
    QImage image = getImage();
    if (image.isNull()) { return false; }
    image = image.copy(QRect(x, y, w, h));
    image = image.scaled(width,height,Qt::IgnoreAspectRatio);
    saveImage(image);
    return true;
}

bool DownloadAgent2Provider::resizeImage(int width, int height) {
    QImage image = getImage();
    if (image.isNull()) { return false; }
    image = image.scaled(width,height,Qt::IgnoreAspectRatio);
    saveImage(image);
    return true;
}

QString DownloadAgent2Provider::convertLocal(QString url) {
    if(url.startsWith("file://")) { url.remove(0,7); }
    else if (url.startsWith("http", Qt::CaseInsensitive)) { return ""; }
    QFile file(url);
    file.open(QIODevice::ReadWrite);
    QByteArray org = file.readAll();
    QByteArray newImage;
    if (decodeJpeg2Bmp(org, newImage)==0){
        file.write(newImage);
        file.close();
    } else { url = ""; }
    file.close();
    return url;
}

#define NATURE(x) ((x)<0 ? 0 : (x))
QString DownloadAgent2Provider::cropResizeImageWithReference(
        float cx, float cy, float cw, float ch,
        float ix, float iy, float iw, float ih, int width, int height) {
    QString ret = "%1,%2,%3,%4,%5";
    QImage image = getImage();
    if (image.isNull()) { return ret.arg(-1); }
    int cropY = image.height()*NATURE(cy-iy)/ih;
    int cropX = image.width()*NATURE(cx-ix)/iw;
    int cropW = image.width()*cw/iw;
    int cropH = image.height()*ch/ih;
    image = image.copy(QRect(cropX, cropY, cropW, cropH));
    image = image.scaled(width,height,Qt::IgnoreAspectRatio);
    saveImage(image);
    return ret.arg(0).arg(cropX).arg(cropY).arg(cropW).arg(cropH);
}

QImage DownloadAgent2Provider::transcodeImage() {
    QByteArray newImage;
    if (decodeJpeg2Bmp(m_downloadedData, newImage)==0)
        return QImage::fromData(newImage, "BMP");
    else
        return QImage();
}
