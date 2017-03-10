#ifndef Unzipper_H
#define Unzipper_H

#include <QObject>
#include "quazip.h"
#include <QStringList>

class Unzipper : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString dirJSONInfo READ dirJSONInfo)

public:

    Unzipper(); // no parameter is allowed
    ~Unzipper();
    QString dirJSONInfo();

public Q_SLOTS:

  int setZippedBufferAndUnzip(const QByteArray, QString targetPath="./");
  int setZippedFileAndUnzip(const QString, QString targetPath="");
  int setZippedFileAndUnzipSkip(const QString, QString targetPath="");
  int setFileAndUnZipFile(const QString zipPath, QString unzipPath, QString fileName);
  int setFileAndSkipFile(const QString zipPath, QString unzipPath, QString fileName);
  int setFileAndSkipOneSkipExists(const QString zipPath, QString unzipPath, QString fileName);

  QString setPathAndZip(const QString sFullPath, QString tFullPath="");
  QString setFilesAndZip(const QStringList fileList, QString tFullPath="");


Q_SIGNALS:

  void unzipped(int);

  private slots:


private:
  void getDirInfo();
  void extractFiles(QString, bool);
  int fileUnzip(const QString, QString, bool);
  QuaZip *m_pZippedFile;
  QString m_ZippedJSONInfo;
  QString m_single;
  bool    m_oneOrOthers;
};

#endif // Unzipper_H


