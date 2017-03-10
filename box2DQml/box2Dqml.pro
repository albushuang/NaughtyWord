#-------------------------------------------------
#
# Project created by QtCreator 2015-09-18T14:46:29
#
#-------------------------------------------------

QT -= gui
QT += qml quick

TARGET = box2Dqml
TEMPLATE = lib
CONFIG += staticlib

SOURCES +=

HEADERS +=

macx {
    TARGET = $$join(TARGET,,,Macx)
    QMAKE_MAC_SDK = macosx10.12
}

ios {
    QMAKE_MAC_SDK = iphoneos
    TARGET = $$join(TARGET,,,iOS)
}

android {
    TARGET = $$join(TARGET,,,Android)
    equals(ANDROID_TARGET_ARCH, x86) {
        TARGET = $$join(TARGET,,,x86)
    }
    equals(ANDROID_TARGET_ARCH, armeabi-v7a) {
        TARGET = $$join(TARGET,,,eabi-v7a)
    }
    equals(ANDROID_TARGET_ARCH, armeabi) {
        TARGET = $$join(TARGET,,,eabi)
    }
}

win32 {
    TARGET = $$join(TARGET,,,Win32)
}


CONFIG(debug, debug|release) {
    TARGET = $$join(TARGET,,,Debug)
}
CONFIG(release, debug|release) {
    TARGET = $$join(TARGET,,,Release)
}


INC.files = $$PWD/box2dplugin.h
INC.path = $$PWD/../library/inc

FILE = $$shadowed($$PWD)
FILE = $$join(FILE,,,/lib)
FILE = $$join(FILE,,,$$TARGET)
FILE = $$join(FILE,,,.a)
LIBRARY.files = $$FILE
LIBRARY.path = $$PWD/../library/lib

INSTALLS += LIBRARY INC

include(box2d_lib.pri)

DEFINES += STATIC_PLUGIN_BOX2D

DISTFILES += \
    box2d_lib.pri
