#-------------------------------------------------
#
# Project created by QtCreator 2015-06-10T23:28:49
#
#-------------------------------------------------

# For android target in main project assign
# ANDROID_PACKAGE_SOURCE_DIR variable to your
# manifest location

SOURCES += \
    $$PWD/GvQtRewardVideoAdAndroid.cpp \
    $$PWD/GvQtRewardVideoAdDummy.cpp

OBJECTIVE_SOURCES += \
    $$PWD/GvQtAppLovinRewardVideoIos.mm \
    #$$PWD/GvQtRewardVideoAdIos.mm   \


HEADERS  += \
    $$PWD/GvQtRewardVideoAd.h \
    $$PWD/GvQtRewardVideoAdAndroid.h \
    $$PWD/GvQtRewardVideoAdDummy.h \
    $$PWD/GvQtRewardVideoAdIos.h \
    $$PWD/IGvQtRewardVideoAd.h  \
    $$PWD/GADMAdapterAppLovinRewardBasedVideoAd.h

ios {
    ios:QMAKE_CXXFLAGS += -fobjc-arc
    ios:QMAKE_LFLAGS += -ObjC #-all_load
    ios:QT += gui_private
    ios:LIBS += -F $$IOS_FRAMEWORKS/GoogleMobileAds -framework GoogleMobileAds \
                -framework AVFoundation \
                -framework AudioToolbox \
                -framework CoreTelephony \
                -framework MessageUI \
                -framework SystemConfiguration \
                -framework CoreGraphics \
                -framework AdSupport \
                -framework StoreKit \
                -framework EventKit \
                -framework EventKitUI \
                -framework CoreMedia  \
                -framework MediaPlayer \
                -framework SafariServices  \
                -framework CoreBluetooth \
                -framework Security \
                -framework UIKit    \
                -L$$APPLOVINPATH \
                -lAppLovinSdk   \
                #-lGADMAdapterAppLovinRewardBasedVideoAd

    INCLUDEPATH += $$APPLOVINPATH/headers $$IOS_FRAMEWORKS/GoogleMobileAds/Mediation_Adapters
}

android {
    android:QT += androidextras gui-private

    !exists($$ANDROID_PACKAGE_SOURCE_DIR/src/com/glovisdom/GvQtRewardVideoAd)
    {
        #copydata.commands += $(COPY_DIR) $$shell_path($$PWD/platform/android/src) $$shell_path($$ANDROID_PACKAGE_SOURCE_DIR)
    }

    first.depends = $(first) copydata
    export(first.depends)
    export(copydata.commands)
    android:QMAKE_EXTRA_TARGETS += first copydata
}
