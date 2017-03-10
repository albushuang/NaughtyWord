
#include <QtDebug>
#include <assert.h>
#include <QDir>
#include "DBfiller.h"

#define WARNING_MSG "error while executing sql command. Err Msg:"

DBFiller::DBFiller(): m_table(""), m_rect() {
    connect(this, SIGNAL (queryOne()), this, SLOT (getOneAndAction()));
    connect(this, SIGNAL (oneRecordDone(bool)), this, SLOT (updateRecord(bool)));
    m_speech.clear();
    m_image.clear();
    pDLer1 = new DownloadAgent2Provider();
    pDLer2 = new FileDownloader();
    connect(pDLer1, SIGNAL(downloaded()), this, SLOT (imageDownloaded()));
    connect(pDLer2, SIGNAL(downloaded()), this, SLOT (speechDownloaded()));
    connect(pDLer1, SIGNAL(networkUnavailable()), this, SLOT (imageErrorReported()));
    connect(pDLer2, SIGNAL(networkUnavailable()), this, SLOT (speechErrorReported()));
    connect(pDLer1, SIGNAL(downloadFailed()), this, SLOT (imageErrorReported()));
    connect(pDLer2, SIGNAL(downloadFailed()), this, SLOT (speechErrorReported()));
}

DBFiller::~DBFiller() {
    delete pDLer1;
    delete pDLer2;
}


void DBFiller::imageErrorReported() {
    m_imageOK = true;
    m_image.clear();
    emit fillError();
    if(m_speechOK && m_imageOK) { emit oneRecordDone(true);}
}
void DBFiller::speechErrorReported() {
    m_speechOK = true;
    m_speech.clear();
    emit fillError();
    if(m_speechOK && m_imageOK) { emit oneRecordDone(true);}
}

void DBFiller::imageDownloaded() {
    if(m_rect.width()!=0 && m_rect.height()!=0) {
        pDLer1->cropResizeImage(m_rect.x(), m_rect.y(), m_rect.width(), m_rect.height(), 512, 512);
    } else {
        pDLer1->resizeImage(512, 512);
    }
    m_image = pDLer1->downloadedData();
    m_imageOK = true;
    if(m_speechOK && m_imageOK) { emit oneRecordDone(true);}
}

void DBFiller::speechDownloaded() {
    m_speech = pDLer2->downloadedData();
    m_speechOK = true;
    if(m_speechOK && m_imageOK) { emit oneRecordDone(true);}
}

void DBFiller::getMediaFullPath(QString fullPath, QString table) {
    openDBFullPath(fullPath);
    m_rootPath = fullPath.left(fullPath.lastIndexOf("/")+1);
    m_table = table;
    m_index = 0;
    emit queryOne();
}

void DBFiller::getOneAndAction() {
    QString fields = "id, image, imageURL, speech, speechURL, orgX, orgY, Width, Height";
    QString sqs = "SELECT " + fields + " FROM " + m_table + " limit %1,1;";
    QString qs = sqs.arg(m_index);
    QSqlQuery query(*m_pdb);
    while (query.exec(qs)) {
        if(query.next()) {
            m_id = query.value("id").toString();
            m_writeImage = query.value("image").toString();
            m_imageOK = QFile::exists(m_rootPath+m_writeImage);
            m_imageURL = m_imageOK ? "" : query.value("imageURL").toString();

            m_writeSpeech = query.value("speech").toString();
            m_speechOK = QFile::exists(m_rootPath+m_writeSpeech);
            m_speechURL = m_speechOK ? "" : query.value("speechURL").toString();
            m_rect = QRect(query.value("orgX").toInt(),
                           query.value("orgY").toInt(),
                           query.value("Width").toInt(),
                           query.value("Height").toInt());
            if (m_speechOK && m_imageOK) {
                m_index++;
                qs = sqs.arg(m_index);
            } else {
                if (!m_imageOK) { pDLer1->setFileUrl(m_imageURL); }
                if (!m_speechOK) { pDLer2->setFileUrl(m_speechURL); }
                break;
            }
        } else {
            query.exec("PRAGMA integrity_check;");
            query.exec("VACUUM;");
            emit fillDone();
            break;
        }
    }

    // ignore sql query error!
    //{ qDebug()<< "Access database error: " << query.lastError(); emit fillError(); }

    query.finish();
}


void DBFiller::updateRecord(bool update) {
    if(update) { updateOneRecord(); }
    m_index++;
    emit queryOne();
}


void DBFiller::updateOneRecord() {
    if(m_imageURL!="") {
        QFile i(m_rootPath+m_writeImage);
        i.open(QIODevice::WriteOnly);
        i.write(m_image);
        i.close();
    }
    if(m_speechURL!="") {
        QFile s(m_rootPath+m_writeSpeech);
        s.open(QIODevice::WriteOnly);
        s.write(m_speech);
        s.close();
    }
}
