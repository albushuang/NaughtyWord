#ifndef IMAGE_DOWNLOAD_AND_PROVIDER_H
#define IMAGE_DOWNLOAD_AND_PROVIDER_H

#include <QQuickImageProvider>
#include <QQuickItem>
#include "filedownloader.h"
#include "mediaBox.h"

class DownloadAgent2Provider: public FileDownloader {

Q_OBJECT

public:
    DownloadAgent2Provider();
    ~DownloadAgent2Provider();

//PRAGMA: NetVendor protocol
//    virtual QByteArray* downloadedNetVendor();
//    virtual QUrl* downloadedUrlNetVendor();

public Q_SLOTS:
    static QString convertLocal(QString url);

    bool resizeImage(int, int);
    bool cropResizeImage(int x, int y, int w, int h, int nw, int nh);
    QString cropResizeImageWithReference(float, float, float, float, float, float, float, float, int, int);
    void setMediaBox(MediaBox*);
    DownloadAgent2Provider* self() { return this; }

    // QML object id can be passed here and passed to QML again
    // void setFileUrl(const QUrl &arg, QQuickItem *item);
    void setFileUrl(const QUrl &arg);

private slots:
    void transferMedia(QNetworkReply*);

Q_SIGNALS:
//signals:
    void imageReady(QString source);
    void imageInvalid(QString source);

private:
    bool getFromMediaBox(QString);
    QImage getImage();
    void saveImage(QImage&);
    QImage transcodeImage();
    MediaBox *m_pbox;
    QQuickItem *m_pItem;
};


#endif // IMAGE_DOWNLOAD_AND_PROVIDER_H

