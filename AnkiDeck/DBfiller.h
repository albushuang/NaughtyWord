#ifndef DB_FILLER_H
#define DB_FILLER_H

#include <QByteArray>
#include "SQLiteBasic.h"
#include "downloadAgent2Povider.h"

class DBFiller : public SQLiteBasic
{
Q_OBJECT

public:

    DBFiller(); // no parameter is allowed
    ~DBFiller();

public Q_SLOTS:
    void getMediaFullPath(QString, QString);


Q_SIGNALS:
    void fillDone();
    void fillError();

signals:
    void queryOne();
    void oneRecordDone(bool);

private slots:
    void imageDownloaded();
    void speechDownloaded();
    void getOneAndAction();
    void updateRecord(bool);
    void imageErrorReported();
    void speechErrorReported();
private:
    void updateOneRecord();
    DownloadAgent2Provider *pDLer1;
    FileDownloader *pDLer2;
    QNetworkReply *m_pReply;
    QString m_table;
    QRect m_rect;
    QByteArray m_image;
    QByteArray m_speech;
    QString m_imageURL;
    QString m_speechURL;
    bool m_imageOK;
    bool m_speechOK;
    QString m_id;
    int  m_index;
    QString m_rootPath;
    QString m_writeImage;
    QString m_writeSpeech;
};

#endif // DB_FILLER_H


