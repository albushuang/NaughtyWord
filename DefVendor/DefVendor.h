#ifndef DEFINITION_VENDOR_H
#define DEFINITION_VENDOR_H

#include <QObject>

class DefVendor : public QObject
{
Q_OBJECT

    Q_PROPERTY(QString synonymKey1 READ synonymKey1 CONSTANT)
    Q_PROPERTY(QString synonymKey2 READ synonymKey2 CONSTANT)
    Q_PROPERTY(QString synonymKey3 READ synonymKey3 CONSTANT)
    Q_PROPERTY(QString synonymKey4 READ synonymKey4 CONSTANT)
    Q_PROPERTY(QString ggClientID READ ggClientID CONSTANT)
    Q_PROPERTY(QString ggSecret READ ggSecret CONSTANT)
    Q_PROPERTY(QString firebaseUrl READ firebaseUrl CONSTANT)

public:

    DefVendor(); // no parameter is allowed
    ~DefVendor();

    QString synonymKey1() const;
    QString synonymKey2() const;
    QString synonymKey3() const;
    QString synonymKey4() const;
    QString ggClientID() const;
    QString ggSecret() const;
    QString firebaseUrl() const;
public Q_SLOTS:


Q_SIGNALS:


signals:


private slots:

private:

};

#endif // DEFINITION_VENDOR_H


