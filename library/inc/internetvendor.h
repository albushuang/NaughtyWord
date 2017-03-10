#ifndef INTERNETVENDOR_H
#define INTERNETVENDOR_H

#include <QByteArray>
#include <QUrl>
#include <QDebug>

class NetVendor : public QObject
{
    Q_OBJECT

public:

    NetVendor() {}
    ~NetVendor() {}

    virtual QByteArray * downloadedNetVendor()=0;
    virtual QUrl * downloadedUrlNetVendor()=0;
};

#endif // INTERNETVENDOR_H
