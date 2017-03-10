#ifndef APP_INIT_H
#define APP_INIT_H

#include <QObject>
#include <QSettings>

class AppInit : public QObject
{
Q_OBJECT


public:

    AppInit(); // no parameter is allowed
    ~AppInit();
    void initPaths();
    QString getDefaultDeckPath();

    #ifdef PLATFORM_ANDROID
    QString prepareQRC();
    #endif

public Q_SLOTS:
    void initDecks(bool forced=false);

Q_SIGNALS:
    void deckReady();

signals:


private slots:


private:

};

#endif // APP_INIT_H


