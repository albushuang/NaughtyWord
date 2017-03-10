#ifndef UNBZIPPER_H
#define UNBZIPPER_H
#include <QStringList>

class Unbzipper
{

public:

    Unbzipper();
    ~Unbzipper();
    QString GetUnbzippFilePath() const;

    // not implemented yet
    //void setBzippedBufferAndUnbzip(const QByteArray);
    //void setBzippedBuffer(const QByteArray);

    void setBzippedFilePathAndUnbzip(const QString);
    void setBzippedFilePath(const QString);
    void setUnbzippedFilePath(const QString);
    void startUnbzip();

private:
    QString m_bzippedFilePath;
    QString m_unbzippedFilePath;
};

#endif // UNBZIPPER_H
