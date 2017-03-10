#ifndef GLOBAL_BRIDGE_H
#define GLOBAL_BRIDGE_H

#include <QObject>
#include "dbImage.h"

class GlobalBridgeOfImageProvider : public MediaBox
{
    Q_OBJECT

public:
    GlobalBridgeOfImageProvider(); // no parameter is allowed
    ~GlobalBridgeOfImageProvider();

public Q_SLOTS:
    virtual int putInMediaBox(QByteArray&, const QString &);
    virtual bool removeFromMediaBox(const QString &);
    virtual QByteArray* getFromMediaBox(const QString &);
    GlobalBridgeOfImageProvider * self() { return this; }

Q_SIGNALS:
//signals:

private slots:

private:
};

#endif // GLOBAL_BRIDGE_H


