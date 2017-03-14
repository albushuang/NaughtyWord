TEMPLATE = app

QT += qml quick core gui xml svg network multimedia sql
CONFIG -= bitcode
DEFINES += SYNONYMKEY1=\\\"$(ENV_SYN_KEY1)\\\"
DEFINES += SYNONYMKEY2=\\\"$(ENV_SYN_KEY2)\\\"
DEFINES += SYNONYMKEY3=\\\"$(ENV_SYN_KEY3)\\\"
DEFINES += SYNONYMKEY4=\\\"$(ENV_SYN_KEY4)\\\"
DEFINES += GGCLIENTID=\\\"$(ENV_GGCLIENTID)\\\"
DEFINES += GGSECRET=\\\"$(ENV_GGSECRET)\\\"
DEFINES += FIREBASEURL=\\\"$(ENV_FIREBASEURL)\\\"

#DEFINES ''= QMLJSDEBUGGER
#DEFINES''= QT_DECLARATIVE_DEBUG

!osx:qtHaveModule(webengine) {
        QT += webengine
        DEFINES += QT_WEBVIEW_WEBENGINE_BACKEND
}

QTPLUGIN += qsvg

LIBS += -L$$OUT_PWD/../mp3Player/ -L$$OUT_PWD/../ijgjpeg/ -L$$OUT_PWD/../unbzipper/ -L$$OUT_PWD/../quazip/ \
    -L$$OUT_PWD/../box2Dqml/

INCLUDEPATH += $$PWD/../library/inc $$PWD/imageVendor
RCCC_RESOURCE += $$PWD/qrc/decks.qrc $$PWD/musics/musics.qrc $$PWD/dictionary/dictionaries.qrc

ADV = REWARDED #BANNER_INTERSTITIAL

android {
    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
}

ios {
    IOS_FRAMEWORKS = $$PWD/../../iOSFramework
    APPLOVINPATH = $$PWD/../../iOSFramework/applovin-ios-sdk-3.3.1
}

equals(ANDROID_TARGET_ARCH, x86)

contains(ADV, BANNER_INTERSTITIAL) {
    include(QtAdMob/QtAdMob.pri)
    DEFINES += ADMOB_BANNER_INTERSTITIAL
}

contains(ADV, REWARDED) {
    include(GvQtRewardVideoAd/GvQtRewardVideoAd.pri)
    DEFINES += NATIVE_REWARDED
}


#QMAKE_EXTRA_COMPILERS += RCCC
#RCCC.input    = RCCC_RESOURCE
#RCCC.output   = ${QMAKE_FILE_NAME}.rcc
##RCCC.depends  = $$RCCC_RESOURCE
##RCCC.variable_out = HEADERS
#RCCC.commands = $$[QT_INSTALL_BINS]/rcc -binary ${QMAKE_FILE_NAME} -o ${QMAKE_FILE_OUT}


BZLIB = unbzipper
QUAZIPLIB=quazip
BOX2DLIB = box2Dqml
MP3LIB = mp3Player
JPEGCODEC = ijgjpeg

SOURCES += main.cpp \
    DictEngine/dictLookup.cpp   \
    appSettings/appSettings.cpp \
    appSettings/settings.cpp \
    searchSpeech/searchSpeech.cpp \
    $$PWD/../AnkiDeck/AnkiDeck.cpp \
    $$PWD/../AnkiDeck/DBfiller.cpp \
    $$PWD/../AnkiDeck/DBfilter.cpp \
    $$PWD/../AnkiDeck/SQLiteBasic.cpp \
    $$PWD/../AnkiDeck/AnkiPackage.cpp \
    $$PWD/../AnkiDeck/AnkiTranslator.cpp \
    $$PWD/../AnkiDeck/CardMover.cpp \
    imageVendor/dbImage.cpp \
    imageVendor/filedownloader.cpp \
    imageVendor/fileuploader.cpp \
    wordSpeaker/wordSpeaker.cpp \
    imageVendor/imageScraper.cpp \
    imageVendor/globalBridgeOfImageProvider.cpp \
    imageVendor/downloadAgent2Povider.cpp \
    dictManager/dictManager.cpp \
    dictManager/untar.cpp \
    sDictLookup/sDictLookup.cpp \
    fileCommander/fileCommander.cpp \
    ../dropboxLib/qdropbox.cpp \
    ../dropboxLib/qdropboxaccount.cpp \
    ../dropboxLib/qdropboxdeltaresponse.cpp \
    ../dropboxLib/qdropboxfile.cpp \
    ../dropboxLib/qdropboxfileinfo.cpp \
    ../dropboxLib/qdropboxjson.cpp \
    ../dropboxLib/qtDropboxQml.cpp \
    SystemOperation/systemoperation.cpp \
    AudioWorkAround/AudioWorkaround.cpp \
    fileCommander/Unzipper.cpp \
    appSettings/appInit.cpp \
    DictEngine/tsConvert.cpp \
    QmlAdMob/QmlAdMob.cpp \
    ../DefVendor/DefVendor.cpp


RESOURCES += qml.qrc \
    GameSelect.qrc \
    translations.qrc \
    ../JSONListModel/jsonLibrary.qrc \
    insanity.qrc \
    directmatchgame.qrc \
    ScoreView/ScoreView.qrc \
    Dialogue/Dialogue.qrc \
    dictManager/DictionaryManager.qrc \
    DirectoryView/DirectoryView.qrc \
    deckManagement/DeckManagement.qrc \
    NWUIControls/nwuicontrols.qrc \
    cloudDrive/clouddrive.qrc \
    GamePractice/gamepractice.qrc \
    DictLookup/DictLookup.qrc \
    MainPage/MainPage.qrc \
    qrc/UIControls.qrc \
    pic/pic2.qrc \
    NWDialog/NWDialog.qrc \
    ../serverAPI/firebaseapi.qrc \
    ../gvComponent/gvComponents.qrc \
    NWComponents/nwComponents.qrc \
    deckDownloader/deckdownloader.qrc \
    deckManagement/moveDeck.qrc \
    fireBase_recover/firebaserecover.qrc \

#    GameTOEICBattle/gamestage.qrc \
#    GameTOEICBattle/gametoeicbattle.qrc \
#    GameFlipMatch/gameflipmatch.qrc\
#    wordShuffle/wordshuffle.qrc \
#    achievement/achievement.qrc \

# Additional import path used to resolve QML modules in Qt Creator's code model
# Order: Submodule in order of the first letter goes first,
# then, Main module in order of the first letter, without file "translation"
QML_IMPORT_PATH += $$PWD/../box2DQml $$PWD/../dropboxLib $$PWD/../JSONListModel $$PWD/../library/qml/UIControls \
                   $$PWD/../mp3Player $$PWD/../quazip $$PWD/../UIControls $$PWD/../unbzipper \
                   $$PWD/android $$PWD/../AnkiDeck $$PWD/appSettings $$PWD/cloudDrive $$PWD/controllers \
                   $$PWD/deckManagement $$PWD/Dialogue $$PWD/DictEngine $$PWD/dictionary $$PWD/DictLookup \
                   $$PWD/dictManager $$PWD/directMatchGame $$PWD/DirectoryView $$PWD/fileCommander \
                   $$PWD/GameInsanity $$PWD/GamePractice $$PWD/GameSelect \
                   $$PWD/generalJS $$PWD/generalModel $$PWD/headers $$PWD/imageVendor $$PWD/ios $$PWD/macx \
                   $$PWD/MainPage $$PWD/musics $$PWD/NWUIControls $$PWD/pic $$PWD/ScoreView $$PWD/NWDialog/com \
                   $$PWD/sDictLookup $$PWD/searchSpeech $$PWD/wordSpeaker \
                   $$PWD/deckDownloader

#$$PWD/GameTOEICBattle $$PWD/GameFlipMatch $$PWD/wordShuffle

ios {
    QMAKE_MAC_SDK = iphoneos9.3
    QMAKE_INFO_PLIST = ios/Info.plist
    ios_icon.files = $$files($$PWD/ios/icons/iconNaughtyWord_*.png)
    QMAKE_BUNDLE_DATA += ios_icon

    #app_launch_images.files += $$PWD/ios/Launch.xib
    app_launch_images.files += $$files($$PWD/ios/launch/LaunchImage*.png)
    QMAKE_BUNDLE_DATA += app_launch_images

    rccfiles.files = $$PWD/rcc/decks.rcc $$PWD/rcc/musics.rcc $$PWD/rcc/dictionaries.rcc $$PWD/rcc/pic.rcc
    rccfiles.path = qrc
    QMAKE_BUNDLE_DATA += rccfiles

    BZLIB = $$join(BZLIB,,,iOS)
    QUAZIPLIB = $$join(QUAZIPLIB,,,iOS)
    BOX2DLIB = $$join(BOX2DLIB,,,iOS)
    MP3LIB = $$join(MP3LIB,,,iOS)
    JPEGCODEC = $$join(JPEGCODEC,,,iOS)
    LIBS += -lz
    DEFINES += PLATFORM_IOS EG_NOSTDLIB
}

macx {
# if any library is not found, execute:
#    install_name_tool -change libmp3PlayerMacxRelease.1.dylib "@loader_path/libmp3PlayerMacxRelease.1.dylib" NaughtyWord
    QMAKE_MAC_SDK = macosx10.12
    rccfiles.files = $$PWD/rcc/decks.rcc $$PWD/rcc/musics.rcc $$PWD/rcc/dictionaries.rcc $$PWD/rcc/pic.rcc
    rccfiles.path = qrc
    QMAKE_BUNDLE_DATA += rccfiles
    QMAKE_INFO_PLIST = macx/Info.plist
    BZLIB = $$join(BZLIB,,,Macx)
    QUAZIPLIB = $$join(QUAZIPLIB,,,Macx)
    BOX2DLIB = $$join(BOX2DLIB,,,Macx)
    MP3LIB = $$join(MP3LIB,,,Macx)
    JPEGCODEC = $$join(JPEGCODEC,,,Macx)
    LIBS += -lz
    DEFINES += PLATFORM_MACX EG_NOSTDLIB
    ICON = macx/NaughtyWord.icns
}

android {
    #resource file under obb will be rename to *.obb, ex: main.1134007001.com.glovisdom.NaughtyWord after uploaded,
    # it becomes main.1134007001.com.glovisdom.NaughtyWord.obb. This is important for doing local obb test.
    QT += androidextras
    RESOURCES += pic/pic.qrc
    LIBS += -lz
    BZLIB = $$join(BZLIB,,,Android)
    QUAZIPLIB = $$join(QUAZIPLIB,,,Android)
    BOX2DLIB = $$join(BOX2DLIB,,,Android)
    MP3LIB = $$join(MP3LIB,,,Android)
    JPEGCODEC = $$join(JPEGCODEC,,,Android)
    DEFINES += PLATFORM_ANDROID
#reserve for correct library names
    equals(ANDROID_TARGET_ARCH, x86)  {
        BZLIB = $$join(BZLIB,,,x86)
        QUAZIPLIB = $$join(QUAZIPLIB,,,x86)
        BOX2DLIB = $$join(BOX2DLIB,,,x86)
        MP3LIB = $$join(MP3LIB,,,x86)
        JPEGCODEC = $$join(JPEGCODEC,,,x86)
    }
    equals(ANDROID_TARGET_ARCH, armeabi-v7a)  {
        BZLIB = $$join(BZLIB,,,eabi-v7a)
        QUAZIPLIB = $$join(QUAZIPLIB,,,eabi-v7a)
        BOX2DLIB = $$join(BOX2DLIB,,,eabi-v7a)
        MP3LIB = $$join(MP3LIB,,,eabi-v7a)
        JPEGCODEC = $$join(JPEGCODEC,,,eabi-v7a)
    }
    equals(ANDROID_TARGET_ARCH, armeabi) {
        BZLIB = $$join(BZLIB,,,eabi)
        QUAZIPLIB = $$join(QUAZIPLIB,,,eabi)
        BOX2DLIB = $$join(BOX2DLIB,,,eabi)
        MP3LIB = $$join(MP3LIB,,,eabi)
        JPEGCODEC = $$join(JPEGCODEC,,,eabi)
    }

    ANDROIDLIB = $$PWD/android/libs/armeabi/
    ANDROIDLIB =  $$join(ANDROIDLIB,,,libImmEndpointWarpJ.so)
    #ANDROIDLIB =  $$join(ANDROIDLIB,,,.so)
    #EXTRA_QUAZIP_LIB = $$ANDROIDLIB
    #ANDROID_EXTRA_LIBS = $$ANDROIDLIB

    DISTFILES += \
        android/AndroidManifest.xml \
        android/gradle/wrapper/gradle-wrapper.jar \
        android/gradlew \
        android/res/values/libs.xml \
        android/build.gradle \
        android/gradle/wrapper/gradle-wrapper.properties \
        android/gradlew.bat \
        $$ANDROID_PACKAGE_SOURCE_DIR/src/com/glovisdom/NaughtyWord/GvQtRewardVideoAdActivity.java # this is a window, so ...

#        GameSelect/viewConsts.js \
#        GameSelect/StudyInfoModel.qml \
#        GameTOEICBattle/SettingValues.java
}

#win32 {
#    BZLIB = $$join(BZLIB,,,Win32)
#    QUAZIPLIB = $$join(QUAZIPLIB,,,Win32)
#    BOX2DLIB = $$join(BOX2DLIB,,,Win32)
#    MP3LIB = $$join(MP3LIB,,,Win32)
#    LIBS += -lzlib -L$$PWD/../library/win32/lib -llibmpg123-0
#    INCLUDEPATH += $$PWD/../library/win32/inc
#    DEF_FILE = $$PWD/../library/win32/lib/libmpg123-0.def
#    QMAKE_LFLAGS += /DEF:$$DEF_FILE
#    RESOURCES += decks.qrc
#}


CONFIG(debug, debug|release) {
    BZLIB = $$join(BZLIB,,,Debug)
    BOX2DLIB = $$join(BOX2DLIB,,,Debug)
    QUAZIPLIB = $$join(QUAZIPLIB,,,Debug)
    MP3LIB = $$join(MP3LIB,,,Debug)
    JPEGCODEC = $$join(JPEGCODEC,,,Debug)
    CONFIG += qml_debug #declarative_debug
}

CONFIG(release, debug|release) {
    BZLIB = $$join(BZLIB,,,Release)
    BOX2DLIB = $$join(BOX2DLIB,,,Release)
    QUAZIPLIB = $$join(QUAZIPLIB,,,Release)
    MP3LIB = $$join(MP3LIB,,,Release)
    JPEGCODEC = $$join(JPEGCODEC,,,Release)
    #macx: DEFINES += MAC_OS_RELEASE
}
DEP = lib
DEP = $$join(DEP,,,$$MP3LIB)
DEP = $$join(DEP,,,.a)
#PRE_TARGETDEPS += $$OUT_PWD/../mp3Player/$$DEP
LIBS += -l$$MP3LIB -l$$BOX2DLIB -l$$JPEGCODEC -l$$BZLIB -l$$QUAZIPLIB
#_______________translation start___________________________
# step 1: lupdate this ".pro" file (-noobsolete)
# step 2: modify *.ts by Linguist
# step 3: lrelease this ".pro" file

#Make sure "en","tc","sc" etc.... are matching to the definition in settingNames.h
TRANSLATIONS    = translations/NaughtyWord_en.ts \
                  translations/NaughtyWord_tc.ts \  #trandiactional chinese
                  translations/NaughtyWord_sc.ts    #simplied chinese
lupdate_only {
SOURCES = *.qml \
          *.js
for(path, QML_IMPORT_PATH): SOURCES += $$path/*.qml \
    $$path/*.js
}
#_________________translation end____________________________


# Default rules for deployment.
include(deployment.pri)

# remaked since PCH is invoked as PCH++, thus errors caused
PRECOMPILED_HEADER += \
    DictEngine/dictLookup.h \
    appSettings/appSettings.h \
    appSettings/settingNames.h \
    appSettings/settings.h \
    searchSpeech/searchSpeech.h \
    ../library/inc/internetvendor.h \
    $$PWD/../AnkiDeck/AnkiDeck.h \
    $$PWD/../AnkiDeck/DBfiller.h \
    $$PWD/../AnkiDeck/DBfilter.h \
    $$PWD/../AnkiDeck/SQLiteBasic.h \
    $$PWD/../AnkiDeck/AnkiPackage.h \
    $$PWD/../AnkiDeck/AnkiTranslator.h \
    $$PWD/../AnkiDeck/CardMover.h \
    headers/vendors.h \
    imageVendor/dbImage.h \
    imageVendor/filedownloader.h \
    imageVendor/fileuploader.h \
    wordSpeaker/wordSpeaker.h \
    ../library/inc/mediaBox.h \
    imageVendor/imageScraper.h \
    imageVendor/globalBridgeOfImageProvider.h \
    imageVendor/downloadAgent2Povider.h \
    dictManager/dictManager.h \
    dictManager/untar.h \
    sDictLookup/sDictLookup.h \
    sDictLookup/sDictLookupTool.h \
    fileCommander/fileCommander.h \
    ../dropboxLib/qdropbox.h \
    ../dropboxLib/qdropboxaccount.h \
    ../dropboxLib/qdropboxdeltaresponse.h \
    ../dropboxLib/qdropboxfile.h \
    ../dropboxLib/qdropboxfileinfo.h \
    ../dropboxLib/qdropboxjson.h \
    ../dropboxLib/qtdropbox_global.h \
    ../dropboxLib/qtdropbox.h \
    ../dropboxLib/qtDropboxQml.h \
    SystemOperation/systemoperation.h \
    AudioWorkAround/AudioWorkaround.h \
    fileCommander/Unzipper.h \
    appSettings/appInit.h \
    DictEngine/tsConvert.h \

    QmlAdMob/QmlAdMob.h

HEADERS += \
    DictEngine/dictLookup.h \
    appSettings/appSettings.h \
    appSettings/settingNames.h \
    appSettings/settings.h \
    searchSpeech/searchSpeech.h \
    ../library/inc/internetvendor.h \
    $$PWD/../AnkiDeck/AnkiDeck.h \
    $$PWD/../AnkiDeck/DBfiller.h \
    $$PWD/../AnkiDeck/DBfilter.h \
    $$PWD/../AnkiDeck/SQLiteBasic.h \
    $$PWD/../AnkiDeck/AnkiPackage.h \
    $$PWD/../AnkiDeck/AnkiTranslator.h \
    $$PWD/../AnkiDeck/CardMover.h \
    headers/vendors.h \
    imageVendor/dbImage.h \
    imageVendor/filedownloader.h \
    imageVendor/fileuploader.h \
    wordSpeaker/wordSpeaker.h \
    ../library/inc/mediaBox.h \
    imageVendor/imageScraper.h \
    imageVendor/globalBridgeOfImageProvider.h \
    imageVendor/downloadAgent2Povider.h \
    dictManager/dictManager.h \
    dictManager/untar.h \
    sDictLookup/sDictLookup.h \
    sDictLookup/sDictLookupTool.h \
    fileCommander/fileCommander.h \
    ../dropboxLib/qdropbox.h \
    ../dropboxLib/qdropboxaccount.h \
    ../dropboxLib/qdropboxdeltaresponse.h \
    ../dropboxLib/qdropboxfile.h \
    ../dropboxLib/qdropboxfileinfo.h \
    ../dropboxLib/qdropboxjson.h \
    ../dropboxLib/qtdropbox_global.h \
    ../dropboxLib/qtdropbox.h \
    ../dropboxLib/qtDropboxQml.h \
    SystemOperation/systemoperation.h \
    AudioWorkAround/AudioWorkaround.h \
    fileCommander/Unzipper.h \
    appSettings/appInit.h \
    DictEngine/tsConvert.h \
    QmlAdMob/QmlAdMob.h \
    ../DefVendor/DefVendor.h


#DEPENDPATH += $$PWD/../mp3Player

