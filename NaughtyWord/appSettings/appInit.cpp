#include "settings.h"
#include "settingNames.h"
#include "appSettings.h"
#include "appInit.h"
#include "fileCommander/Unzipper.h"
#include <QStandardPaths>
#include <QDir>
#include <QString>
#include <QtDebug>

#ifdef PLATFORM_ANDROID
#include <QtAndroidExtras/QAndroidJniEnvironment>
#include <QtAndroidExtras/QAndroidJniObject>
#include <QResource>
#endif


#define MAKE_UTF8_INT(a) ((unsigned char)(a)[0] << 16) | ((unsigned char)(a)[1] << 8) | ((unsigned char)(a)[2])

AppInit::AppInit() { }

AppInit::~AppInit() { }


QString getDefaultPath() {
    return QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
}

QString getDefaultDeckPathLocal() {
    QString targetPath = getDefaultPath();
    if (!targetPath.endsWith('/')) targetPath += "/";
    targetPath += DEFAULT_DECK_PATH_NAME "/";
    return targetPath;
}


QString AppInit::getDefaultDeckPath() {
    return getDefaultDeckPathLocal();
}

void makeAnkiPath(AppSettings *pSettings) {
    QString targetPath = getDefaultPath();
    if (!targetPath.endsWith('/')) targetPath += "/";
    targetPath += ANKI_DEFAULT_PATH_NAME "/";
    QString key = ANKI_GROUPE "/" ANKI_DEFAULT_PATH;
    pSettings->writeSetting(key, targetPath);

    if (!QDir(targetPath).exists()) {
        QDir().mkpath(targetPath);
    }
}

QString initDefaultDeckPath() {
    QString targetPath = getDefaultDeckPathLocal();
    AppSettings *pSettings = new AppSettings();
    QString key = DECK_GROUPE "/" DEFAULT_DECK_PATH;
    pSettings->writeSetting(key, targetPath);
    makeAnkiPath(pSettings);

    delete pSettings;

    if (!QDir(targetPath).exists()) {
        QDir().mkpath(targetPath);
    }

    return targetPath;
}

bool exists(QFileInfoList& list, QString fileName) {
    for (int i = 0; i<list.length(); i++){
        QString name = list[i].fileName().split(".")[0];
        QString mainName = fileName.split(".")[0];
        if (name==mainName) return true;
    }
    return false;
}

void initDefaultDatabase(bool forced) {
    QString targetPath = getDefaultDeckPathLocal();

    QFileInfoList checkingList = QDir(targetPath).entryInfoList();
    QFileInfoList fileList = QDir(":/decks/").entryInfoList();
    for (int i = 0; i<fileList.length(); i++){
        QString fileName = fileList[i].fileName();
        if(fileName.contains(".kmr")){
            QString target = targetPath + fileName;
            if(!exists(checkingList, fileName+"j") || forced) {
                QFile::copy(":/decks/" + fileName , target);
                QFile::setPermissions(target,QFile::WriteOwner | QFile::ReadOwner);
                Unzipper unzip;
                unzip.setZippedFileAndUnzip(target, target+"j");
                QFile::remove(target);
            }
        }
    }
}

void initDefaultDictionaryPath() {
    QString targetPath = getDefaultPath();
    if (!targetPath.endsWith('/')) targetPath += "/";
    targetPath += DICT_DEFAULT_PATH_NAME "/";

    AppSettings *pSettings = new AppSettings();
    QString key = DICT_GROUPE "/" DICT_DEFAULT_PATH;
    pSettings->writeSetting(key, targetPath);
    delete pSettings;

    if (!QDir(targetPath).exists()) {
        QDir().mkdir(targetPath);
    }
}

void AppInit::initPaths() {
    initDefaultDeckPath();
    initDefaultDictionaryPath();
}

#ifdef PLATFORM_ANDROID
QString getObbFile(QString path) {
    QString fileName;
    int version=0;
    QFileInfoList checkingList = QDir(path).entryInfoList();
    for(int i=0;i<checkingList.count();i++) {
        if(checkingList[i].fileName().contains("com.glovisdom.NaughtyWord.obb")) {
            int cv = checkingList[i].fileName().split(".")[1].toInt();
            if(cv>version) {
                fileName = checkingList[i].fileName();
                version = cv;
            }
        }
    }
    return fileName;
}

void unzipQrc(QString source, QString dest) {
    Unzipper uz;
    uz.setFileAndSkipOneSkipExists(source, dest, "decks.rcc");
}

void getAndroidPaths(QString &source, QString &target) {
    QAndroidJniObject mediaDir = QAndroidJniObject::callStaticObjectMethod("android/os/Environment", "getExternalStorageDirectory", "()Ljava/io/File;");
    QAndroidJniObject mediaPath = mediaDir.callObjectMethod( "getAbsolutePath", "()Ljava/lang/String;" );
    QAndroidJniObject activity = QAndroidJniObject::callStaticObjectMethod("org/qtproject/qt5/android/QtNative", "activity", "()Landroid/app/Activity;");
    QAndroidJniObject package = activity.callObjectMethod("getPackageName", "()Ljava/lang/String;");

    target = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    source = mediaPath.toString()+"/Android/obb/"+package.toString();

    QAndroidJniEnvironment env; // Don't know what this is for ?
    if (env->ExceptionCheck()) { env->ExceptionClear(); } // Or this...?
}

QString AppInit::prepareQRC() {
    QString path, destPath;
    getAndroidPaths(path, destPath);

    QString obb = getObbFile(path);

    if(!obb.isEmpty()) {
        unzipQrc(path+"/"+obb, destPath+"/qrc");
    }
    return destPath;
}


void unzipDecksQrc(QString source, QString dest) {
    Unzipper uz;
    uz.setFileAndUnZipFile(source, dest, "decks.rcc");
}

QString decksQrc() {
    QString path, destPath;
    getAndroidPaths(path, destPath);

    QString obb = getObbFile(path);

    if(!obb.isEmpty()) {
        unzipDecksQrc(path+"/"+obb, destPath+"/qrc");
    }
    QString deckQrc = destPath+"/qrc/decks.rcc";
    //QResource::registerResource(deckQrc);
    return deckQrc;
}

void removeDecksQrc(QString path) {
    QFile file(path);
    file.remove();
}

#endif

void AppInit::initDecks(bool forced) {
#ifdef PLATFORM_ANDROID
    QString decks = decksQrc();
#endif

    initDefaultDatabase(forced);
    deckReady();

#ifdef PLATFORM_ANDROID
    removeDecksQrc(decks);
#endif
}
