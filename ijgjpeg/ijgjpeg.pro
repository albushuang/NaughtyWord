#-------------------------------------------------
#
# Project created by QtCreator 2015-12-04T13:36:50
# jpeg encode and decode library
#
#-------------------------------------------------

QT       -= gui

TARGET = ijgjpeg
TEMPLATE = lib
CONFIG += staticlib #this prevents dylib in mac OS version

DEFINES += HAVE_STDLIB_H HAVE_UNSIGNED_CHAR HAVE_UNSIGNED_SHORT BMP_SUPPORTED

SOURCES += \
    jaricom.c \
    jcapimin.c \
    jcapistd.c \
    jcarith.c \
    jccoefct.c \
    jccolor.c \
    jcdctmgr.c \
    jchuff.c \
    jcinit.c \
    jcmainct.c \
    jcmarker.c \
    jcmaster.c \
    jcomapi.c \
    jcparam.c \
    jcprepct.c \
    jcsample.c \
    jctrans.c \
    jdapimin.c \
    jdapistd.c \
    jdarith.c \
    jdatadst.c \
    jdatasrc.c \
    jdcoefct.c \
    jdcolor.c \
    jddctmgr.c \
    jdhuff.c \
    jdinput.c \
    jdmainct.c \
    jdmarker.c \
    jdmaster.c \
    jdmerge.c \
    jdpostct.c \
    jdsample.c \
    jdtrans.c \
    jerror.c \
    jfdctflt.c \
    jfdctfst.c \
    jfdctint.c \
    jidctflt.c \
    jidctfst.c \
    jidctint.c \
    jmemansi.c \
    jmemmgr.c \
    jquant1.c \
    jquant2.c \
    jutils.c \
    jdecode2bmp.cpp \
    cdjpeg.cpp \
    rdcolmap.cpp \
    wrbmp.cpp

HEADERS += \
    cderror.h \
    jdct.h \
    jerror.h \
    jinclude.h \
    jmemsys.h \
    jmorecfg.h \
    jpegint.h \
    jpeglib.h \
    jconfig.h \
    codecJpeg.h \
    jdecode2bmp.h

#unix {
#    target.path = /usr/lib
#    INSTALLS += target
#}

macx {
    QMAKE_MAC_SDK = macosx10.12
    #DEFINES += USE_MAC_MEMMGR
    #SOURCES += jmemmac.c
    #QMAKE_MAC_SDK = macosx10.11
    TARGET = $$join(TARGET,,,Macx)
}

ios {
    QMAKE_MAC_SDK = iphoneos9.3
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

#open one function only.
INC.files = $$PWD/jdecode2bmp.h
INC.path = $$PWD/../library/inc

FILE = $$shadowed($$PWD)
FILE = $$join(FILE,,,/lib)
FILE = $$join(FILE,,,$$TARGET)
FILE = $$join(FILE,,,.a)
LIBRARYA.files = $$FILE
LIBRARYA.path = $$PWD/../library/lib

INSTALLS += INC
INSTALLS += LIBRARYA

export(INSTALLS)

