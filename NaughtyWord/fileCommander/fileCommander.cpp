#include <QFile>
#include <QDir>
#include "fileCommander.h"
#include <QtDebug>

FileCommander::FileCommander(){ }

FileCommander::~FileCommander() { }

bool FileCommander::rename(const QString &path, const QString &targetName)
{
    m_source = path;
    m_target = targetName;
    QFile file(m_source);
    if(!file.exists()) return false;
    bool result = file.rename(m_target);
    emit commandDone();
    return result;
}

bool FileCommander::copy(const QString &path, const QString &targetName)
{
    m_source = path;
    m_target = targetName;
    QFile file(m_source);
    if(!file.exists()) return false;
    QFile file2(m_target);
    if(file2.exists()) return false;
    bool result = QFile::copy(m_source, m_target);
    emit commandDone();
    return result;
}

bool FileCommander::remove(const QString &path)
{
    m_source = path;
    QFileInfo fi(path);
    bool result;
    if (fi.isDir()) {
        result = removeDir(path);
    } else {
        QFile file(m_source);
        if(!file.exists()) return false;
        result = file.remove();
    }
    emit commandDone();
    return result;
}

bool FileCommander::removeDir(const QString &path)
{
    QDir dir(path);
    if(!dir.exists()) return false;
    return dir.removeRecursively();
}

bool FileCommander::renameDir(const QString &fullPath, const QString &shortTarget)
{
    QDir dir(fullPath);
    dir.cdUp();
    QStringList pathList = fullPath.split("/");
    QString shortName = pathList[pathList.length()-1];
    return dir.rename(shortName, shortTarget);
}

bool FileCommander::copyDir(const QString &sFullPatn, const QString &tFullPath) {
    QDir sDir(sFullPatn), tDir(tFullPath);
    if(!sDir.exists() || tDir.exists()) { return false; }
    tDir.mkpath(tFullPath);
    QString tBase = tFullPath;
    if (!tBase.endsWith("/")) { tBase += "/"; }

    QFileInfoList ls = sDir.entryInfoList(QDir::NoDotAndDotDot|QDir::AllEntries);
    bool result = true;
    for(int i=0;i<ls.count(); i++) {
        if(ls[i].isFile()) { result &= copy(ls[i].absoluteFilePath(), tBase+ls[i].fileName());}
        else if(ls[i].isDir()){ result &= copyDir(ls[i].absoluteFilePath(), tBase+ls[i].fileName());}
    }
    return result;
}

bool FileCommander::exists(const QString fullPath) {
    QString path = fullPath;
    if(path.startsWith("file://")) path.remove(0,7);
    QFile file(path);
    return file.exists();
}
