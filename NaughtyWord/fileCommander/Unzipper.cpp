#include "Unzipper.h"
#include <QtDebug>
#include <QBuffer>
#include "quazipfile.h"
#include "JlCompress.h"


Unzipper::Unzipper()
{
    m_pZippedFile = NULL;
    m_ZippedJSONInfo = "";
    m_single = "";
    m_oneOrOthers = true;
}

Unzipper::~Unzipper() { }

QString subdirName(const QString filePath) {
    QStringList names = filePath.split("/");
    QString fileName = names[names.length()-1];
    return fileName.left(fileName.lastIndexOf("."));
}

void makeFromSourcePath(const QString filePath, QString &targetPath) {
    if(targetPath=="") {
        QStringList names = filePath.split("/");
        targetPath = filePath.left(filePath.lastIndexOf("/")+1);
        QDir dir(targetPath);
        targetPath += subdirName(filePath) + "/";
        dir.mkdir(subdirName(filePath));
    } else {
        QDir dir(targetPath);
        dir.mkpath(targetPath);
        if(!targetPath.endsWith("/")) { targetPath += "/"; }
    }
}

int Unzipper::fileUnzip(const QString filePath, QString targetPath, bool skip) {
    m_pZippedFile = new QuaZip(filePath);
    if(! m_pZippedFile->open(QuaZip::mdUnzip) ) {
        qWarning() << m_pZippedFile->getZipError();
        return -1;
    }
    makeFromSourcePath(filePath, targetPath);
    extractFiles(targetPath, skip);
    m_pZippedFile->close();
    delete m_pZippedFile;
    emit unzipped(0);
    return 0;
}

int Unzipper::setFileAndSkipFile(const QString zipPath, QString unzipPath, QString fileName) {
    m_single = fileName;
    m_oneOrOthers = true;
    int ret = fileUnzip(zipPath, unzipPath, false);
    m_single = "";
    return ret;
}

int Unzipper::setFileAndSkipOneSkipExists(const QString zipPath, QString unzipPath, QString fileName) {
    m_single = fileName;
    m_oneOrOthers = true;
    int ret = fileUnzip(zipPath, unzipPath, true);
    m_single = "";
    return ret;
}

int Unzipper::setFileAndUnZipFile(const QString zipPath, QString unzipPath, QString fileName) {
    m_single = fileName;
    m_oneOrOthers = false;
    int ret = fileUnzip(zipPath, unzipPath, false);
    m_single = "";
    return ret;
}

int Unzipper::setZippedFileAndUnzip(const QString filePath, QString targetPath)
{
    return fileUnzip(filePath, targetPath, false);
}

int Unzipper::setZippedFileAndUnzipSkip(const QString filePath, QString targetPath)
{
    return fileUnzip(filePath, targetPath, true);
}

QString prepareZipPath(QString sourcePath) {
    if(sourcePath.endsWith("/")) { sourcePath.remove(sourcePath.length()-1, 1); }
    int i=-1;
    do {
        QString zip;
        if(i<0) { zip = sourcePath+".zip"; }
        else { zip = sourcePath+QString("%1").arg(i++, 4, QChar('0'))+".zip"; }
        QFile file(zip);
        if(!file.exists()) {
            return zip;
        }
    } while(i<10000);
    return "";
}


QString Unzipper::setPathAndZip(const QString sFullPath, QString tFullPath) {
    if(tFullPath=="") { tFullPath = prepareZipPath(sFullPath); }
    else if(QFile::exists(tFullPath)) { return ""; }

    return JlCompress::compressDir(tFullPath, sFullPath, true) ? tFullPath : "";
}

QString Unzipper::setFilesAndZip(const QStringList fileList, QString tFullPath) {
    if(QFile::exists(tFullPath)) { return ""; }

    return JlCompress::compressFiles(tFullPath, fileList) ? tFullPath : "";
}

void prepareTargetPath(QString &targetPath) {
    QDir dir(targetPath);
    if(!dir.exists()) { dir.mkpath(targetPath); }
    if(!targetPath.endsWith("/")) { targetPath += "/"; }
}

int Unzipper::setZippedBufferAndUnzip(const QByteArray byteArray, QString targetPath)
{
    QBuffer *buffer = new QBuffer((QByteArray*) &byteArray, NULL);
    m_pZippedFile = new QuaZip(buffer);
    if (!m_pZippedFile->open(QuaZip::mdUnzip)) {
        qWarning() << m_pZippedFile->getZipError();
        return -1;
    }
    prepareTargetPath(targetPath);
    extractFiles(targetPath, false);

    m_pZippedFile->close();
    delete m_pZippedFile;
    emit unzipped(0);
    return 0;
}

QString Unzipper::dirJSONInfo() {
    return m_ZippedJSONInfo;
}

void Unzipper::getDirInfo() {
    QuaZipFile zipfile(m_pZippedFile);
    QTextStream(&m_ZippedJSONInfo) << "{ \"files\" : [ ";
    for (bool more = m_pZippedFile->goToFirstFile(); more; ) {
        QTextStream(&m_ZippedJSONInfo) << "{";
        QTextStream(&m_ZippedJSONInfo) << "\"name\": " << "\"" << zipfile.getActualFileName() << "\",";
        QTextStream(&m_ZippedJSONInfo) << "\"size\": " << "\"" << zipfile.csize() << "\"";
        QTextStream(&m_ZippedJSONInfo) << "}";
        more = m_pZippedFile->goToNextFile();
        if (more) QTextStream(&m_ZippedJSONInfo) << ",";
        else { QTextStream(&m_ZippedJSONInfo) << "]"; break; }
    }
    QTextStream(&m_ZippedJSONInfo) << "}";
}

#define WRITE_BUFFER_SIZE 100000
void Unzipper::extractFiles(QString targetPath, bool skip) {
    QuaZipFile zipfile(m_pZippedFile);

    bool all = m_single=="";
    for (bool more = m_pZippedFile->goToFirstFile(); more; more = m_pZippedFile->goToNextFile()) {
        zipfile.open(QIODevice::ReadOnly);
        QString fn = targetPath+zipfile.getActualFileName();
        if (fn.endsWith("/")) {
            if(all || (fn.startsWith(m_single) ^ m_oneOrOthers)) {
                QDir dir(fn);
                dir.mkpath(fn);
            }
        } else {
            if(all || (fn.startsWith(m_single) ^ m_oneOrOthers)) {
                QFile file(fn);
                if (file.exists() && skip) { continue; }
                file.open(QIODevice::WriteOnly|QIODevice::Truncate);
                for (int i=0; i < zipfile.usize(); i+= WRITE_BUFFER_SIZE) {
                    file.write(zipfile.read(WRITE_BUFFER_SIZE));
                }
                file.close();
            }
        }
        zipfile.close();
    }
}
