#include "settings.h"
#include "settingNames.h"
#include "appSettings.h"
#include <QtDebug>

#define MAKE_UTF8_INT(a) ((unsigned char)(a)[0] << 16) | ((unsigned char)(a)[1] << 8) | ((unsigned char)(a)[2])

AppSettings::AppSettings() :
    m_appSettings(QSettings::NativeFormat, QSettings::UserScope, ORG_NAME, APP_NAME) {
    int i=0;
    do {
        QString lastSettings = settings[i].group;
        lastSettings += "/";
        int j=0;
        do {
            QString groupSetting = lastSettings + settings[i].pairs[j].name;
            QString v2 = settings[i].pairs[j].value;
            if(m_appSettings.value(groupSetting).toString()=="") {
                m_appSettings.setValue(groupSetting, v2);
            }
        } while(settings[i].pairs[++j].name!=0);
    } while (settings[++i].group!=0);
}

AppSettings::~AppSettings() { }

const QVariant AppSettings::readSetting(const QString key) {
    return m_appSettings.value(key);
}

void AppSettings::writeSetting(const QString key, const QVariant value) {
    m_appSettings.setValue(key, value);
}

void AppSettings::initSettingsWith(QString group, QStringList settingList, QStringList defaultList) {
    for (int i = 0; i<settingList.size(); i++){
        QString setting = group + "/" + settingList[i];
        m_appSettings.setValue(setting, defaultList[i]);
    }
}

void AppSettings::initSettings(QString group, const NameValue *pair) {
    int i=0;
    while (pair[i].name!=0) {
        QString setting = group + "/" + pair[i].name;
        m_appSettings.setValue(setting, pair[i].value);
        i++;
    }
}

