
#include <QtDebug>
#include <assert.h>
#include <QFile>
#include "CardMover.h"


CardMover::CardMover() : SQLiteBasic() {
}

CardMover::~CardMover() { }


QString CardMover::basePath() const {
    //return m_dirInfo.toUtf8().toBase64();
    return m_dirInfo;
}

void CardMover::setPathInfo(QString path) {
    SQLiteBasic::setPathInfo(path);
    m_dirInfo = path;
}

QString targetDB(QString base, QString target) {
    if(!base.endsWith("/")) base += "/";
    if(!target.endsWith("/")) target += "/";
    return base + target + "cards.sqlite3";
}


bool moveFile(QString s, QString t)
{
    QFile file(s);
    if(!file.exists()) return false;
    bool result = file.rename(t);
    return result;
}

bool moveMedia(QString base, QString source, QString target, QString speech, QString image) {
    if(!base.endsWith("/")) base += "/";
    if(!source.endsWith("/")) source += "/";
    if(!target.endsWith("/")) target += "/";
    bool result = moveFile(base+source+speech, base+target+speech);
    result &= moveFile(base+source+image, base+target+image);
    return result;
}

#define CHECK_SQL_EXEC(command) \
if (!query.exec( (command) )) {    \
    qDebug() << "sql err msg:" << query.lastError();    \
    return -1;  \
}

int handleMedia(QSqlQuery& query, QString& image, QString& speech, qint64 id) {
    QString command = QString("SELECT image, speech from cardTable where id=%1").arg(id);
    CHECK_SQL_EXEC(command)
    if (query.next()) {
        image = query.value("image").toString();
        speech = query.value("speech").toString();
        return 0;
    }
    return -1;
}


int CardMover::moveCard(QString source, QString target, qint64 id){
    if(openDBFile(source+"/cards.sqlite3")) {
        QSqlQuery query(*m_pdb);

        QString command = QString("ATTACH \"%1\" as target").arg(targetDB(m_dirInfo, target));
        CHECK_SQL_EXEC(command)

        QString image, speech;
        if (handleMedia(query, image, speech, id)!=0) { return -1; }
        moveMedia(m_dirInfo, source, target, speech, image);

        command = QString("INSERT into target.cardTable select * from cardTable where id=%1").arg(id);
        CHECK_SQL_EXEC(command)

        command = QString("DELETE from cardTable where id=%1").arg(id);
        CHECK_SQL_EXEC(command)

        vacuum(m_pdb);
        query.finish();
        closeDB();
        return 0;
    }
    return -1;
}


void CardMover::vacuum(QSqlDatabase *m_pdb) {
    QSqlQuery* p_query1 = new QSqlQuery(*m_pdb);
    p_query1->exec("PRAGMA integrity_check;");
    p_query1->exec("VACUUM;");
    p_query1->finish();
}

void CardMover::releaseDeck(){
    if (m_pdb != NULL) {
        vacuum(m_pdb);
        closeDB();
    }
}

int CardMover::getRowCounts(QString database) {
    int ret=0;
    if(openDBFile(database+"/cards.sqlite3")) {
        QSqlQuery query(*m_pdb);
        QString command = "SELECT Count(*) FROM cardTable";
        if (!query.exec(command)) {
            qDebug() << "SQL err Msg:" << query.lastError();
        }
        if (query.next()) { ret = query.value(0).toInt(); }
        query.finish();
        closeDB();
    }
    if(ret == -1){ret = 0;}
    return ret;
}

