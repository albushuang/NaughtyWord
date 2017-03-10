#include <QFile>
#include <QDir>
#include <QFileInfo>
#include "dictManager.h"
#include "unbzipper.h"
#include "untar.h"
#include "quazip.h"
#include "quagzipfile.h"
#include <QDebug>

DictManager::DictManager(): m_packagePath("") {

}

DictManager::~DictManager() { }


QString DictManager::dictPackage() const {
    return m_packagePath;
}

void DictManager::setDictPackage(QString const packagePath){
    m_packagePath = packagePath;
}

inline QString unbzip(QString path) {
    Unbzipper unbzip;
    unbzip.setBzippedFilePath(path);
    unbzip.setUnbzippedFilePath(path+".tmp");
    unbzip.startUnbzip();
    return path+".tmp";
}

QString unTarPackage(QString package, const char *path) {
    FILE *tar = fopen(package.toStdString().c_str(),  "rb");
    if (tar == NULL) return "";
    QString unTarPath = untar(tar, path);
    qDebug() << "untarred:" << unTarPath;
    fclose(tar);
    return unTarPath;
}

QString removeExt(QString path) {
    int index = path.lastIndexOf(".");
    return path.mid(0, index);
}

inline bool ungzip(QString filePath) {
    QuaGzipFile gzipfile(filePath, NULL);
    if (gzipfile.open(QIODevice::ReadOnly)!=true) return false;

    QFile fo(removeExt(filePath));
    if(fo.open(QIODevice::WriteOnly)!=true) return false;

    int readSize=0;
    do {
        QByteArray read = gzipfile.read(102400);
        readSize = read.size();
        fo.write(read);
    } while(readSize!=0);
    fo.close();
    gzipfile.close();

    QFile gzipped(filePath);
    return gzipped.remove();
}

bool checkDZ(QString path) {
    QFileInfoList files = QDir(path).entryInfoList(QDir::Files);
    bool result = true;

    for (int i=0;i<files.length();i++) {
        qDebug()<<files[i].fileName();
        if (files[i].fileName().endsWith(".dz") ) {
            result &= ungzip(files[i].absoluteFilePath());
        }
    }
    return result;
}

bool unpack(QString package){
    if(package =="") return false;

    QStringList dirs = package.split("/");
    int pathLength = package.length()-dirs[dirs.length()-1].length();
    QString path = package.mid(0, pathLength);

    QString tarFilePath = unbzip(package);

    // tar may have multiple path, ignored now....
    QString unTarPath = unTarPackage(tarFilePath, path.toStdString().c_str());
    if (unTarPath=="") return false;
    if (checkDZ(unTarPath)==false) return false;

    QFile rmTmp(tarFilePath);
    rmTmp.remove();

    return true;
}

bool DictManager::startUnpack(){
    return unpack(m_packagePath);
}


bool DictManager::unPackRemovePackage(QString package){
    return unpack(package) && removePackage(package);
}

bool DictManager::removePackage(QString package){
    QFile rmTmp(package);
    return rmTmp.remove();
}


bool DictManager::removeDictionary(QString path){
    QDir dir(path);
    QFileInfoList files = dir.entryInfoList(QDir::Files);
    bool result = true;

    for (int i=0;i<files.length();i++) {
        result &= dir.remove(files[i].fileName());
    }

    QString name = dir.dirName();
    dir.cdUp();
    return result && dir.rmdir(name);
}
