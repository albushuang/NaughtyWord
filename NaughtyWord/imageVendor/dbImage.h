#ifndef DB_IMAGE_PROVIDER_H
#define DB_IMAGE_PROVIDER_H

#include <QObject>
#include <QQuickImageProvider>
#include "../headers/vendors.h"
#include "mediaBox.h"

#define IMAGE_VENDOR_DOWNLOAD "CurrentDownload"

class DbImage: public MediaBox, public QQuickImageProvider {

    Q_OBJECT

public:
    DbImage();
    ~DbImage();

    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize);
    QByteArray *requestRawData(const QString &id);
    //QUrl requestDownloadedUrl() const;
    void receiveImage(QByteArray &fileData, QString id);
    void releaseImage(const QString &);

    //PRAGMA: protocol MediaBox
    virtual int putInMediaBox(QByteArray&, const QString &);
    virtual bool removeFromMediaBox(const QString &);
    virtual QByteArray* getFromMediaBox(const QString &);

    int setCachedImageNo(int);
public Q_SLOTS:

public slots:
//    void getReadyImage(QByteArray*, QUrl);

private:
    QList<DataMapping> m_imageList;
    int m_imageNoLimit;
};


#endif // DB_IMAGE_PROVIDER_H

