#-------------------------------------------------
#
# Project created by QtCreator 2015-08-28T17:48:32
#
#-------------------------------------------------

QT -= gui
QT += multimedia

TARGET = mp3Player
TEMPLATE = lib
#CONFIG += staticlib

SOURCES += mp3player.cpp    \
    audioout.cpp

!win32: {
SOURCES += \
    libmpg123/libmpg123.c \
    libmpg123/compat.c \
    libmpg123/dither.c \
    libmpg123/equalizer.c \
    libmpg123/feature.c \
    libmpg123/format.c \
    libmpg123/frame.c \
    libmpg123/icy.c \
    libmpg123/icy2utf8.c \
    libmpg123/id3.c \
    libmpg123/index.c \
    libmpg123/layer1.c \
    libmpg123/layer2.c \
    libmpg123/layer3.c \
    libmpg123/lfs_alias.c \
    libmpg123/ntom.c \
    libmpg123/optimize.c \
    libmpg123/parse.c \
    libmpg123/readers.c \
    libmpg123/stringbuf.c \
    libmpg123/synth_8bit.c \
    libmpg123/synth_real.c \
    libmpg123/synth_s32.c \
    libmpg123/synth.c \
    libmpg123/tabinit.c \
    libmpg123/dct64.c
}

HEADERS += mp3player.h \
    mpg123.h \
    audioout.h

macx {
    QMAKE_MAC_SDK = macosx10.12
    TARGET = $$join(TARGET,,,Macx)
    DEFINES += TARGET_OS_MAC OPT_MULTI OPT_X86_64 OPT_GENERIC OPT_GENERIC_DITHER REAL_IS_FLOAT OPT_AVX NOXFERMEM
    SOURCES += \
    libmpg123/dct36_avx.S   \
    libmpg123/dct36_x86_64.S   \
    libmpg123/dct64_avx.S   \
    libmpg123/dct64_avx_float.S   \
    libmpg123/dct64_x86_64.S   \
    libmpg123/dct64_x86_64_float.S   \
    libmpg123/getcpuflags_x86_64.S   \
    libmpg123/synth_stereo_avx.S   \
    libmpg123/synth_stereo_avx_float.S   \
    libmpg123/synth_stereo_avx_s32.S   \
    libmpg123/synth_stereo_x86_64.S   \
    libmpg123/synth_stereo_x86_64_float.S   \
    libmpg123/synth_stereo_x86_64_s32.S   \
    libmpg123/synth_x86_64.S   \
    libmpg123/synth_x86_64_float.S   \
    libmpg123/synth_x86_64_s32.S
}

ios {
    QMAKE_MAC_SDK = iphoneos9.3
    TARGET = $$join(TARGET,,,iOS)
    #problem with OPT_ARM: INT123_synth_1to1_arm_asm not found, make file will ignore synth_arm.S...why?
    DEFINES += TARGET_OS_IPHONE OPT_MULTI OPT_GENERIC OPT_GENERIC_DITHER REAL_IS_FLOAT NOXFERMEM
    #compiler does not know the syntax of this file, remarked by using pure C.
    #SOURCES += libmpg123/synth_arm.S

}

android {
    TARGET = $$join(TARGET,,,Android)
    DEFINES += OPT_MULTI OPT_GENERIC OPT_GENERIC_DITHER REAL_IS_FLOAT NOXFERMEM
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
    DEFINES += TARGET_OS_WIN
#    #OPT_X86_64
#    DEFINES +=  OPT_MULTI OPT_3DNOW OPT_MMX OPT_SSE OPT_GENERIC OPT_GENERIC_DITHER OPT_AVX \
#                REAL_IS_FLOAT NOXFERMEM \
#                TARGET_OS_WIN   \
#                WANT_WIN32_UNICODE

#    SOURCES += \
#    libmpg123/dct36_avx.S   \
#    libmpg123/dct64_avx.S   \
#    libmpg123/dct64_avx_float.S   \
#    libmpg123/synth_stereo_avx.S   \
#    libmpg123/synth_stereo_avx_float.S   \
#    libmpg123/synth_stereo_avx_s32.S   \
#    libmpg123/dct36_3dnow.S \
#    libmpg123/dct36_sse.S   \
#    libmpg123/dct64_3dnow.S \
#    libmpg123/dct64_mmx.S   \
#    libmpg123/dct64_sse.S   \
#    libmpg123/dct64_sse_float.S \
#    libmpg123/equalizer_3dnow.S \
#    libmpg123/getcpuflags.S \
#    libmpg123/synth_3dnow.S \
#    libmpg123/synth_i586.S  \
#    libmpg123/synth_mmx.S   \
#    libmpg123/synth_sse.S   \
#    libmpg123/synth_sse_float.S \
#    libmpg123/synth_sse_s32.S   \
#    libmpg123/synth_stereo_sse_accurate.S   \
#    libmpg123/synth_stereo_sse_float.S  \
#    libmpg123/synth_stereo_sse_s32.S    \
#    libmpg123/tabinit_mmx.S

}

CONFIG(debug, debug|release) {
    TARGET = $$join(TARGET,,,Debug)
}

CONFIG(release, debug|release) {
    TARGET = $$join(TARGET,,,Release)
}


INCLUDEPATH += $$PWD/libmpg123

INC.files = $$PWD/mpg123.h $$PWD/mp3player.h $$PWD/audioout.h
INC.path = $$PWD/../library/inc

FILE = $$shadowed($$PWD)
FILE = $$join(FILE,,,/lib)
FILE = $$join(FILE,,,$$TARGET)
FILE = $$join(FILE,,,.a)
LIBRARY.files = $$FILE
LIBRARY.path = $$PWD/../library/lib

INSTALLS += INC LIBRARY

export(INSTALLS)
