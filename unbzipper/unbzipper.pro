#-------------------------------------------------
#
# Project created by QtCreator 2015-08-31T13:43:29
#
#-------------------------------------------------

QT       -= gui

macx {
    QMAKE_MAC_SDK = macosx10.12
    TARGET = $$join(TARGET,,,Macx)
    DEFINES += BZ_UNIX
}

ios {
    QMAKE_MAC_SDK = iphoneos9.3
    TARGET = $$join(TARGET,,,iOS)
    DEFINES += BZ_UNIX
}

android {
    DEFINES += BZ_UNIX
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
    DEFINES += BZ_LCCWIN32
    TARGET = $$join(TARGET,,,Win32)
}

CONFIG(debug, debug|release) {
    TARGET = $$join(TARGET,,,Debug)
}

CONFIG(release, debug|release) {
    TARGET = $$join(TARGET,,,Release)
}

INCLUDEPATH += $$PWD/bzip2-1.0.6

TEMPLATE = lib
CONFIG += staticlib

SOURCES += unbzipper.cpp \
    bzip2-1.0.6/blocksort.c \
    bzip2-1.0.6/bzlib.c \
    bzip2-1.0.6/compress.c \
    bzip2-1.0.6/crctable.c \
    bzip2-1.0.6/decompress.c \
    bzip2-1.0.6/huffman.c \
    bzip2-1.0.6/randtable.c \
    unbzip2.cpp

HEADERS += unbzipper.h \
    bzip2-1.0.6/bzlib_private.h \
    bzip2-1.0.6/bzlib.h


INC.files = $$PWD/unbzipper.h
INC.path = $$PWD/../library/inc

FILE = $$shadowed($$PWD)
FILE = $$join(FILE,,,/lib)
FILE = $$join(FILE,,,$$TARGET)
FILE = $$join(FILE,,,.a)
LIBRARY.files = $$FILE
LIBRARY.path = $$PWD/../library/lib

INSTALLS += INC LIBRARY

