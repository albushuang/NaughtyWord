#ifndef SYSTEMOPERATION_H
#define SYSTEMOPERATION_H

#include <QObject>

class SystemOperation: public QObject
{
    Q_OBJECT
public:
    SystemOperation();
    ~SystemOperation();
public slots:
    void restartApp();
};

#endif // SYSTEMOPERATION_H
