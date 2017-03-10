#include "unbzipper.h"
#include <QtDebug>
#include <QBuffer>
#include <stdio.h>
#include <QFile>

bool uncompressStream ( FILE *zStream, FILE *stream );

Unbzipper::Unbzipper() : m_bzippedFilePath(""), m_unbzippedFilePath("")
{
}

Unbzipper::~Unbzipper() { }

void Unbzipper::setBzippedFilePath(const QString filePath){
    m_bzippedFilePath = filePath;
}

void Unbzipper::setUnbzippedFilePath(const QString unbzippedFilePath){
    m_unbzippedFilePath = unbzippedFilePath;
}

void Unbzipper::startUnbzip(){
    std::string s = m_bzippedFilePath.toLatin1().constData();
    char const *pInFullPath = s.c_str();

    if (m_unbzippedFilePath == "") {  m_unbzippedFilePath=m_bzippedFilePath+".unbzipped"; }
    std::string s2 = m_unbzippedFilePath.toLatin1().constData();
    char const *pOutFullPath = s2.c_str();

    FILE *in = fopen(pInFullPath, "rb");
    FILE *out = fopen(pOutFullPath, "wb");

    if (in != NULL && out != NULL) { uncompressStream(in, out);  }
    else { qWarning() << "file open error!"; }

    fclose(in);
    fclose(out);

//    QFile file(filePath+".unbzipped");
//    file.setPermissions(QFile::ReadOwner|QFile::WriteOwner);
}

void Unbzipper::setBzippedFilePathAndUnbzip(const QString filePath)
{
    m_bzippedFilePath = filePath;
    startUnbzip();
}

QString Unbzipper::GetUnbzippFilePath() const {
    return m_unbzippedFilePath;
}

//void Unbzipper::setBzippedBuffer(const QByteArray) { }
//void Unbzipper::setBzippedBufferAndUnbzip(const QByteArray byteArray){ }

