# Install script for directory: /Users/albus/Desktop/projects/quazip/quazip-0.7.1/quazip

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/usr/local")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

if(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified")
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/quazip" TYPE FILE FILES
    "/Users/albus/Desktop/projects/quazip/quazip-0.7.1/quazip/crypt.h"
    "/Users/albus/Desktop/projects/quazip/quazip-0.7.1/quazip/ioapi.h"
    "/Users/albus/Desktop/projects/quazip/quazip-0.7.1/quazip/JlCompress.h"
    "/Users/albus/Desktop/projects/quazip/quazip-0.7.1/quazip/quaadler32.h"
    "/Users/albus/Desktop/projects/quazip/quazip-0.7.1/quazip/quachecksum32.h"
    "/Users/albus/Desktop/projects/quazip/quazip-0.7.1/quazip/quacrc32.h"
    "/Users/albus/Desktop/projects/quazip/quazip-0.7.1/quazip/quagzipfile.h"
    "/Users/albus/Desktop/projects/quazip/quazip-0.7.1/quazip/quaziodevice.h"
    "/Users/albus/Desktop/projects/quazip/quazip-0.7.1/quazip/quazip.h"
    "/Users/albus/Desktop/projects/quazip/quazip-0.7.1/quazip/quazip_global.h"
    "/Users/albus/Desktop/projects/quazip/quazip-0.7.1/quazip/quazipdir.h"
    "/Users/albus/Desktop/projects/quazip/quazip-0.7.1/quazip/quazipfile.h"
    "/Users/albus/Desktop/projects/quazip/quazip-0.7.1/quazip/quazipfileinfo.h"
    "/Users/albus/Desktop/projects/quazip/quazip-0.7.1/quazip/quazipnewinfo.h"
    "/Users/albus/Desktop/projects/quazip/quazip-0.7.1/quazip/unzip.h"
    "/Users/albus/Desktop/projects/quazip/quazip-0.7.1/quazip/zip.h"
    )
endif()

if(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified")
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/usr/local/lib/libquazip.1.0.0.dylib;/usr/local/lib/libquazip.1.dylib;/usr/local/lib/libquazip.dylib")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
file(INSTALL DESTINATION "/usr/local/lib" TYPE SHARED_LIBRARY FILES
    "/Users/albus/Desktop/projects/quazip/quazip-0.7.1/libquazip.1.0.0.dylib"
    "/Users/albus/Desktop/projects/quazip/quazip-0.7.1/libquazip.1.dylib"
    "/Users/albus/Desktop/projects/quazip/quazip-0.7.1/libquazip.dylib"
    )
  foreach(file
      "$ENV{DESTDIR}/usr/local/lib/libquazip.1.0.0.dylib"
      "$ENV{DESTDIR}/usr/local/lib/libquazip.1.dylib"
      "$ENV{DESTDIR}/usr/local/lib/libquazip.dylib"
      )
    if(EXISTS "${file}" AND
       NOT IS_SYMLINK "${file}")
      execute_process(COMMAND "/usr/bin/install_name_tool"
        -id "libquazip.1.dylib"
        "${file}")
      if(CMAKE_INSTALL_DO_STRIP)
        execute_process(COMMAND "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/strip" "${file}")
      endif()
    endif()
  endforeach()
endif()

