#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include <QTranslator>
#include "DictEngine/dictLookup.h"
#include "DictEngine/tsConvert.h"
#include "searchSpeech/searchSpeech.h"
#include "appSettings/appSettings.h"
#include "appSettings/appInit.h"
#include "appSettings/settingNames.h"
#include "../AnkiDeck/AnkiDeck.h"
#include "imageVendor/dbImage.h"
#include "imageVendor/filedownloader.h"
#include "imageVendor/fileuploader.h"
#include "imageVendor/imageScraper.h"
#include "imageVendor/globalBridgeOfImageProvider.h"
#include "imageVendor/downloadAgent2Povider.h"
#include "wordSpeaker/wordSpeaker.h"
#include "box2dplugin.h"
#include "dictManager/dictManager.h"
#include "sDictLookup/sDictLookup.h"
#include "fileCommander/fileCommander.h"
#include "fileCommander/Unzipper.h"
#include "../dropboxLib/qtDropboxQml.h"
#ifdef QT_WEBVIEW_WEBENGINE_BACKEND
#include <QtWebEngine>
#endif // QT_WEBVIEW_WEBENGINE_BACKEND
#include "../AnkiDeck/DBfiller.h"
#include "../AnkiDeck/AnkiPackage.h"
#include "../AnkiDeck/AnkiTranslator.h"
#include "../AnkiDeck/CardMover.h"
#include "../DefVendor/DefVendor.h"
#include "AudioWorkAround/AudioWorkaround.h"
#include "SystemOperation/systemoperation.h"
#include "QmlAdMob/QmlAdMob.h"


void loadTranslationFile(QApplication *app, QTranslator *translator){
    AppSettings *pSettings = new AppSettings();
    QString key = APP_NAME  "/"  APP_LANGUAGE;
    QString language = pSettings->readSetting(key).toString();
    translator->load(":/translations/NaughtyWord_" + language + ".qm");
    app->installTranslator(translator);
    delete pSettings;
}

#ifdef PLATFORM_ANDROID
QString prepareQRC() {
    AppInit ainit;
    return ainit.prepareQRC();
}

#endif


void initQRC(QApplication * app) {

#ifdef PLATFORM_IOS
    //QString rccPath = QStandardPaths::writableLocation(QStandardPaths::HomeLocation);
    QString rccPath = app->applicationDirPath(); // for Qt 5.7.1
    //qDebug() << rccPath << app->applicationDirPath();
#elif defined PLATFORM_MACX
    QString rccPath = app->applicationDirPath()+"/../.."; // for Qt 5.7.1
    // QString rccPath = "../.."; // before Qt 5.7
#elif defined PLATFORM_ANDROID
    QString rccPath = prepareQRC();
#endif

    QResource::registerResource(rccPath+"/qrc/decks.rcc");
    QResource::registerResource(rccPath+"/qrc/musics.rcc");
    QResource::registerResource(rccPath+"/qrc/dictionaries.rcc");
#ifndef PLATFORM_ANDROID
    QResource::registerResource(rccPath+"/qrc/pic.rcc");
#endif

}

MediaBox *pQQuickImageProvider;

#define RESTART_CODE 1000
int main(int argc, char *argv[])
{
    int return_from_event_loop_code = 0;
    QPointer<QApplication> app;
    QPointer<QQmlApplicationEngine> engine;
    DbImage *pDbImage;

    do
    {
        if(app != NULL) { delete app; }
        app = new QApplication(argc, argv);
        engine = new QQmlApplicationEngine();
        pDbImage = new DbImage();

        initQRC(app);

        AppInit *init = new AppInit();
        init->initPaths();
#ifdef Q_OS_OSX
        // On OS X, correct WebView / QtQuick compositing and stacking requires running
        // Qt in layer-backed mode, which again resuires rendering on the Gui thread.
        qWarning("Setting QT_MAC_WANTS_LAYER=1 and QSG_RENDER_LOOP=basic");
        qputenv("QT_MAC_WANTS_LAYER", "1");
        qputenv("QSG_RENDER_LOOP", "basic");
#endif
#ifdef QT_WEBVIEW_WEBENGINE_BACKEND
        QtWebEngine::initialize();
#endif // QT_WEBVIEW_WEBENGINE_BACKEND

        pQQuickImageProvider = pDbImage;
        pDbImage->setCachedImageNo(16);

        (*AnkiDeck::instance())->setImageVendor(pDbImage);
        (*AnkiDeck::instance())->setPathInfo(init->getDefaultDeckPath());
        (*AnkiDeck::instance())->setWordSpeaker(WordSpeaker::instance());
        qmlRegisterType<DefVendor>("com.glovisdom.DefinitionVendorCpp", 0, 1, "DefinitionVendorCpp");
        qmlRegisterSingletonType<AnkiDeck>("com.glovisdom.AnkiDeck", 0, 1, "AnkiDeck", AnkiDeck::qAnkiDeckProvider);
        qmlRegisterSingletonType<WordSpeaker>("com.glovisdom.WordSpeaker", 0, 1, "WordSpeaker", WordSpeaker::qWordSpeakerProvider);
        qmlRegisterSingletonType( QUrl("qrc:/generalModel/UserSettings.qml"), "com.glovisdom.UserSettings", 0, 1, "UserSettings" );
        qmlRegisterSingletonType( QUrl("qrc:/generalModel/DefinitionVendor.qml"), "com.glovisdom.DefinitionVendor", 0, 1, "DefinitionVendor" );
        qmlRegisterSingletonType( QUrl("qrc:/NWUIControls/NWPleaseWait.qml"), "com.glovisdom.NWPleaseWait", 0, 1, "NWPleaseWait" );
        qmlRegisterType<AppSettings>("AppSettings", 0, 1, "AppSettings");
        qmlRegisterType<AppInit>("AppInit", 0, 1, "AppInit");
        qmlRegisterType<DictLookUp>("DictionaryLookup", 0, 1, "DictLookUp");
        qmlRegisterType<TSConvert>("TSConvert", 0, 1, "TSConvert");
        qmlRegisterType<SearchSpeech>("SearchSpeech", 0, 1, "SearchSpeech");
        qmlRegisterType<FileDownloader>("FileDownloader", 0, 1, "FileDownloader");
        qmlRegisterType<FileUploader>("FileUploader", 0, 1, "FileUploader");
        qmlRegisterType<ImageScraper>("ImageScraper", 0, 1, "ImageScraper");
        qmlRegisterType<GlobalBridgeOfImageProvider>("GlobalBridgeOfImageProvider", 0, 1, "BridgeOfImageProvider");
        qmlRegisterType<DownloadAgent2Provider>("DownloadAgent2Provider", 0, 1, "DownloadAgent2Provider");
        qmlRegisterType<DictManager>("DictManager", 0, 1, "DictManager");
        qmlRegisterType<SDictLookUp>("SDictLookup", 0, 1, "SDictLookUp");
        qmlRegisterType<FileCommander>("FileCommander", 0, 1, "FileCommander");
        qmlRegisterType<QTDropboxQml>("QTDropboxQml", 0, 1, "QTDropboxQml");
        qmlRegisterType<DBFiller>("DBFiller", 0, 1, "DBFiller");
        qmlRegisterType<AnkiPackage>("AnkiPackage", 0, 1, "AnkiPackage");
        qmlRegisterType<AnkiTranslator>("AnkiTranslator", 0, 1, "AnkiTranslator");
        qmlRegisterType<CardMover>("CardMover", 0, 1, "CardMover");
        qmlRegisterType<AudioWorkaround>("AudioWorkaround", 0, 1, "AudioWorkaround");
        qmlRegisterType<SystemOperation>("SystemOperation", 0, 1, "SystemOperation");
        qmlRegisterType<Unzipper>("Unzipper", 0, 1, "Unzipper");
        qmlRegisterType<QmlAdMob>("QmlAdMob", 0, 1, "QmlAdMob");

        delete init;

        Box2DPlugin plugin;
        plugin.registerTypes("Box2D");

        QTranslator translator;
        loadTranslationFile(app, &translator);

        engine->addImageProvider(QLatin1String("download"), pDbImage);
        engine->addImportPath("../UIControls");
        engine->load(QUrl(QStringLiteral("qrc:/main.qml")));
        return_from_event_loop_code = app->exec();
        delete engine;
    }
    while(return_from_event_loop_code==RESTART_CODE);

    delete app;
    return return_from_event_loop_code;
}
