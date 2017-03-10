#ifndef APP_SETTINGS_H
#define APP_SETTINGS_H

#include <QObject>
#include <QSettings>

typedef struct _n_v_ {
    const char * name;
    const char * value;
} NameValue;

typedef struct init_settings {
    const char *group;
    const NameValue *pairs;
} InitSettings;

class AppSettings : public QObject
{
Q_OBJECT


public:

    AppSettings(); // no parameter is allowed
    ~AppSettings();

public Q_SLOTS:
    const QVariant readSetting(QString);
    void writeSetting(const QString, const QVariant);

Q_SIGNALS:


signals:


private slots:


private:
    void initSettingsWith(QString, QStringList, QStringList);
    void initSettings(QString, const NameValue*);
    QSettings m_appSettings;
};

#endif // APP_SETTINGS_H


