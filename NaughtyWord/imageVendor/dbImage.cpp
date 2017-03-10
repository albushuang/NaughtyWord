#include "dbImage.h"
#include <QtDebug>
#include <Qbuffer>
#include <QFile>
#include "jdecode2bmp.h"

extern DbImage * pQQuickImageProvider;

DbImage::DbImage():
    QQuickImageProvider(QQuickImageProvider::Image), m_imageNoLimit(10) {
}

DbImage::~DbImage(){
    m_imageList.clear();
}

int DbImage::setCachedImageNo(int no) {
    m_imageNoLimit = no;
    if(m_imageNoLimit > 30) m_imageNoLimit=30;
    return m_imageNoLimit;
}

QImage transcodeImage(QByteArray *source) {
    QByteArray newImage;
    if (decodeJpeg2Bmp(*source, newImage)==0)
        return QImage::fromData(newImage, "BMP");
    else
        return QImage();
}

bool checkAndValidate(QByteArray &data) {
    QImage image = QImage::fromData(data, 0);
    if(image.format()==QImage::Format_Invalid) {
        image = transcodeImage(&data);
        if(image.isNull()) { return false; }
        else {
            data.clear();
            QBuffer buffer;
            buffer.setBuffer(&data);
            buffer.open( QIODevice::WriteOnly );
            image.save( &buffer,"JPG", 70);
            return true;
        }
    }
    return true;
}

// TODO: who should filter unsupported image format???
QImage DbImage::requestImage(const QString &id, QSize *size, const QSize &requestedSize){
    Q_UNUSED(size);
    Q_UNUSED(requestedSize);
    QByteArray *pImage = requestRawData(id);
    if (pImage != NULL) {
        QImage image = QImage::fromData(*pImage, 0);
        if(image.format()==QImage::Format_Invalid) {
            image = transcodeImage(pImage);
            if(image.isNull()) {
                image = QImage(":/pic/notSupported.png");
            }
        }
        return image;
    }
    return QImage();
}


QByteArray * DbImage::requestRawData(const QString &id){
    QByteArray *pImage = NULL;
    if (id.isEmpty() != true) {
        for (int i=0;i<m_imageList.count();i++) {
            if (m_imageList[i].id == id) {
                pImage = &m_imageList[i].data;
                break;
            }
        }
    }
    return pImage;
}

void DbImage::receiveImage(QByteArray &fileData, QString id) {
    putInMediaBox(fileData, id);
}


void DbImage::releaseImage(const QString &id) {
    removeFromMediaBox(id);
}


int DbImage::putInMediaBox(QByteArray &fileData, const QString &id){
    for (int i=0;i<m_imageList.count(); i++) {
        if (m_imageList[i].id == id) return 1;
    }
    QByteArray image = fileData;
    if (checkAndValidate(image)) {
        DataMapping map = {id, image};
        m_imageList.append(map);
        while(m_imageList.count() >m_imageNoLimit) { m_imageList.removeAt(0); }
        return 0;
    } else { return -1; }
}

QByteArray* DbImage::getFromMediaBox(const QString &id){
    for (int i=0;i<m_imageList.count(); i++) {
        if (m_imageList[i].id == id) { return &m_imageList[i].data; }
    }
    return NULL;
}

bool DbImage::removeFromMediaBox(const QString& id){
    bool found = false;
    for (int i=0;i<m_imageList.count(); i++) {
        if (m_imageList[i].id == id) {
            m_imageList.removeAt(i);
            found = true;
        }
    }
    return found;
}
