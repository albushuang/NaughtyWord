#ifndef MEDIABOX_H
#define MEDIABOX_H

#include <QByteArray>
#include <QUrl>
#include <QDebug>

class MediaBox : public QObject
{
    Q_OBJECT

public:

    MediaBox() {}
    ~MediaBox() {}

    virtual int putInMediaBox(QByteArray&, const QString &)=0;
    virtual bool removeFromMediaBox(const QString &)=0;
    virtual QByteArray* getFromMediaBox(const QString &id)=0;
};

#endif // MEDIABOX_H
