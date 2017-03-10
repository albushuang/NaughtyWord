
#include <QtDebug>
#include <assert.h>
#include <QDir>
#include "AnkiDeck.h"
#include <math.h>

typedef struct tableItem {
    const char *field;
    const char *type;
} TableItem;

TableItem tableFields[] = {
    {"id", "INT"},
    {"word", "TEXT"},
    {"pa", "TEXT"},
    {"notes", "TEXT"},
    {"ef", "REAL"},
    {"status", "INT"},
    {"learningStep", "INT"},
    {"interval", "INT"},
    {"due", "INT"},
    {"lastStudy", "INT"},
    {"lapseCount", "INT"},
    {"speech", "TEXT"},
    {"speechURL", "TEXT"},
    {"image", "TEXT"},
    {"imageURL", "TEXT"},
    {"category", "TEXT"},
    {"synonym", "TEXT"},
    {"similar", "TEXT"},
    {"related", "TEXT"},
    {"antonym", "TEXT"},
    {"orgX", "INT"},
    {"orgY", "INT"},
    {"Width", "INT"},
    {"Height", "INT"},
    {"ansHistory", "INT"}
};

int fieldNumber = sizeof(tableFields)/sizeof(tableItem);

QObject* AnkiDeck::qAnkiDeckProvider(QQmlEngine *engine, QJSEngine *scriptEngine) {
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    return *AnkiDeck::instance();
}

AnkiDeck** AnkiDeck::instance() {
    static AnkiDeck** ankiDeck = new (AnkiDeck*)();
    if(*ankiDeck == NULL){
        *ankiDeck = new AnkiDeck();
    }
    return ankiDeck;
}

AnkiDeck::AnkiDeck() : SQLiteBasic() {
    connect( this, SIGNAL( results( QSqlQuery*, quint64) ),
             this, SLOT( handleQueryResults(QSqlQuery*, quint64) ) );
}

AnkiDeck::~AnkiDeck() { *AnkiDeck::instance() = NULL; }

void AnkiDeck::handleQueryResults(QSqlQuery* p_query, quint64 cb){
    HandleResultCallback callback = (HandleResultCallback) cb;
    if(callback != NULL){
        callback(p_query, this);
    }
    p_query->finish();
    //p_query->clear();
    delete p_query;
}

void AnkiDeck::newDeck(QString newDeck){
    QString m_deckInfoBackup = m_deckInfo;
    //qDebug() << "deck info" << m_deckInfo;
    setDeckInfo(newDeck);
    if(m_deckInfoBackup != ""){
        setDeckInfo(m_deckInfoBackup);
    }
}

QStringList AnkiDeck::getAllWords() {
    QStringList allID;
    QSqlQuery query(*m_pdb);
    QString command = "SELECT word FROM cardTable";
    query.exec(command);
    while (query.next()) { allID << query.value("word").toString(); }
    return allID;
}


QString AnkiDeck::basePath() const {
    //return m_dirInfo.toUtf8().toBase64();
    return m_dirInfo;
}

QString AnkiDeck::getDeckID(){
    QString ret;
    if(m_pdb!=NULL) {
        QSqlQuery query(*m_pdb);
        // also available in col/deck
        if (!query.exec("select did from deckInfo limit 1")) {
            qDebug() << "error while executing sql. Err Msg:" << query.lastError();
        }
        else if (query.next()) { ret = query.value("did").toString(); }
        query.finish();
        //query.clear();
    }
    return ret;
}

void AnkiDeck::setPathInfo(QString path) {
    SQLiteBasic::setPathInfo(path);
    m_dirInfo = path;
    emit pathReady();
}


void AnkiDeck::setDeckInfo(QString deckInfo){
    //m_deckInfo = deckInfo.toUtf8(); // why?
    m_root = m_dirInfo;
    if (!m_root.endsWith("/")) { m_root+="/"; }
    m_root += deckInfo + "/";
    QDir dir(m_root);
    if(!dir.exists()) { dir.mkpath(m_root); }
    m_deckInfo = deckInfo;
    openDatabase(m_deckInfo+"/cards.sqlite3");
}

void AnkiDeck::vacuum(QSqlDatabase *m_pdb) {
    QSqlQuery* p_query1 = new QSqlQuery(*m_pdb);
    p_query1->exec("PRAGMA integrity_check;");
    p_query1->exec("VACUUM;");
    p_query1->finish();
    //p_query1->clear();
    delete p_query1;
//    execute(p_query1, ,NULL);
    //Do not resue p_query1 because query.exec() will be executed in worker thread.
    //Reuse p_query1 might trigger race condition
//    QSqlQuery* p_query2 = new QSqlQuery(*m_pdb);
//    execute(p_query2, "VACUUM;",NULL);
}

void AnkiDeck::releaseDeck(){
    if (m_pdb != NULL) {
        vacuum(m_pdb);
        closeDB();
    }
}

QString prepareString() {
    QString cmd = "INSERT OR REPLACE INTO cardTable (";
    for (int i=0;i<fieldNumber;) {
        cmd += tableFields[i].field;
        i++;
        if (i<fieldNumber) cmd += ",";
    }
    cmd += ") VALUES (";
    for (int i=0;i<fieldNumber;i++) {
        cmd += QString(":%1,").arg(tableFields[i].field);
    }
    cmd = cmd.remove(cmd.length()-1, 1);
    return cmd + ")";
}

void AnkiDeck::addOrReplace(QByteArray cardJSON, NetVendor *imageVendor, NetVendor *speechVendor){
    addCard(cardJSON, imageVendor, speechVendor, true);
}

QString writeFile(qint64 id, QByteArray &data, QString type, QString root) {
    QString filename = QString::number(id)+type;
    QFile file(root+filename);
    if(data.size()!=0) {
        if (file.open(QIODevice::WriteOnly)) {
            if (file.write(data)!=data.size()) {
                filename = "";
                file.remove();
            }
            file.close();
            return filename;
        }
    }
    return "";
}

void AnkiDeck::addCard(QByteArray cardJSON, NetVendor *imageVendor, NetVendor *speechVendor, bool forced){
    QJsonDocument jd = QJsonDocument::fromJson(cardJSON);
    QVariantMap map = jd.toVariant().toMap();

    qint64 id = exist(map.value("word").toString());
    if (forced || id==0) {
        if (id==0) { id = QDateTime::currentDateTime().toMSecsSinceEpoch(); }
        QSqlQuery* p_query = new QSqlQuery(*m_pdb);
        QString insertCmd = prepareString();
        p_query->prepare(insertCmd);
        p_query->bindValue(":id", id);
        for (int i=1;i<fieldNumber;i++) {
            QString arg1 = QString(":%1").arg(tableFields[i].field);
            QVariant arg2 = map.value(tableFields[i].field);
            if (strcmp(tableFields[i].field, "speech")==0) {
                QString filename=writeFile(id, *speechVendor->downloadedNetVendor(), ".mp3", m_root);
                p_query->bindValue(arg1, filename);
            } else if (strcmp(tableFields[i].field, "image")==0) {
                //QString filename=writeFile(id, *imageVendor->downloadedNetVendor(), ".jpg", m_root);
                //p_query->bindValue(arg1, filename);
                p_query->bindValue(arg1, "");
            } else { p_query->bindValue(arg1, arg2); }
        }
        //execute(p_query, "", NULL);
        if (!p_query->exec()) {
            qDebug() << "error while checking existence. Err Msg:" << p_query->lastError();
        }
        p_query->finish();
        //p_query->clear();
        delete p_query;
    } else {
        updateCard(cardJSON, QStringList()<<"pa"<<"notes"<<"speech"<<"image", imageVendor, speechVendor);
    }
}

void AnkiDeck::updateCardAsync(QByteArray cardJSON, QStringList columnLists,
                          NetVendor *imageVendor, NetVendor *speechVendor){
    updateCard(cardJSON, columnLists, imageVendor, speechVendor, false);
}

void AnkiDeck::updateCard(QByteArray cardJSON, QStringList columnLists,
                          NetVendor *imageVendor, NetVendor *speechVendor, bool waitingBlock){
    QJsonDocument jd = QJsonDocument::fromJson(cardJSON);
    QVariantMap map = jd.toVariant().toMap();

    qint64 id = map.value("id").toLongLong();
    assert(id != 0);

    QSqlQuery* p_query = new QSqlQuery(*m_pdb);
    QString qs = "UPDATE cardTable SET ";
    for (int i=0; i<columnLists.size(); i++){
        if(columnLists[i] == "speech"){
            QString filename=writeFile(id, *speechVendor->downloadedNetVendor(), ".mp3", m_root);
            qs += columnLists[i] + " = \"" + filename + "\", ";
        }else if(columnLists[i] == "image"){
            QString filename=writeFile(id, *imageVendor->downloadedNetVendor(), ".jpg", m_root);
            qs += columnLists[i] + " = \"" + filename + "\", ";
        }
        else{// QVariant knows the original type. So there is no problem...(you can check by calling.type())
            QString valueStr;
            if(columnLists[i] == "ef"){
                valueStr = QString::number(round(map.value(columnLists[i]).toDouble()*100)/100);  //四捨五入取小數點兩位
            }else if(columnLists[i] == "imageURL" || columnLists[i] == "speechURL" || columnLists[i] == "notes") {
                valueStr = "\""+map.value(columnLists[i]).toString()+"\"";
            } else{
                valueStr = map.value(columnLists[i]).toString();
            }
            qs += columnLists[i] + " = " +  valueStr +  ",";
        }
    }
    qs.remove(qs.length()-1, 1);
    qs += " WHERE id = " + QString::number(id);
    //qDebug()<< "query string:" << qs;
    if(waitingBlock){
        if (!p_query->exec(qs)) {
            qDebug() << "error while checking existence. Err Msg:" << p_query->lastError();
        }
        p_query->finish();
        //p_query->clear();
        delete p_query;
    }else{
        execute(p_query, qs, NULL);
    }
}

void AnkiDeck::releaseCard(QString id) {
    releaseResource(id);
}

void AnkiDeck::removeCard(QString id) {
    releaseResource(id);
    removeRecord("id", id);
}

void AnkiDeck::clearHistory() {
    QSqlQuery* p_query = new QSqlQuery(*m_pdb);
    QString command = "UPDATE cardTable SET ef=2.5, lastStudy=0, status=0,"  \
                      "interval=0, learningStep=0, due=0, lapseCount=0," \
                      "ansHistory=1;";

    p_query->exec(command);
    p_query->finish();
    //p_query->clear();
    delete p_query;
    //execute(p_query, command, NULL);
    vacuum(m_pdb);
}


void AnkiDeck::removeRecord(QString column, QString value) {
    QSqlQuery query(*m_pdb);
    QString command = "SELECT image, speech FROM cardTable where " + column + "=" + value;
    QString image, speech;
    if (!query.exec(command)) {
        qDebug() << "sql error:" << query.lastError(); }
    if (query.next()) {
        image = query.value("image").toString();
        speech = query.value("speech").toString();
    }
    command = "DELETE FROM cardTable where " + column + "=" + value;
    if (query.exec(command)) {
        QFile::remove(m_root+image);
        QFile::remove(m_root+speech);
    } else {
        qDebug() << "sql error:" << query.lastError();
    }
    query.finish();
    //query.clear();
}

void AnkiDeck::releaseResource(QString id) {
}

qint64 AnkiDeck::exist(QString word) {
    qint64 ret=0;
    QSqlQuery query(*m_pdb);
    QString command = "SELECT id FROM cardTable where word='" + word +"' COLLATE NOCASE";
    if (!query.exec(command)) {
        qDebug() << "error while checking existence. Err Msg:" << query.lastError(); }
    if (query.next()) { ret = query.value("id").toString().toLongLong(); }
    query.finish();
    //query.clear();
    return ret;
}

qint64 AnkiDeck::getRowCounts(CARD_FILTER filter=AnkiDeck::All, qint64 aheadDays = 0) {
    int ret=0;
    QSqlQuery query(*m_pdb);
    QString command = "SELECT Count(*) FROM cardTable " + getSqlFilterStr(filter, AnkiDeck::None, "", aheadDays);
    if (!query.exec(command)) {
        qDebug() << "error while checking row counts. Err Msg:" << query.lastError();
    }
    if (query.next()) { ret = query.value(0).toInt(); }
    query.finish();
    //query.clear();
    if(ret == -1){ret = 0;}
    return ret;
}

QString AnkiDeck::browse(int index) {
    QString qs = "SELECT * FROM cardTable limit " + QString::number(index)+",1";
    QSqlQuery query(*m_pdb);
    if (!query.exec(qs)) {
        qDebug() << "error while executing sql command in browse. Err Msg:" << query.lastError(); }
    return jsonizeCards(&query);
}


QString AnkiDeck::getSqlFilterStr(CARD_FILTER filter=AnkiDeck::All, CARD_ORDER order=AnkiDeck::Random,
                                  QString orderTarget="", qint64 aheadDays = 0){
    QString qs = "";
    switch (filter) {
    case All: break;
    case StatusNew: qs += "WHERE status=0 "; break;
    case StatusLearning: qs += "WHERE status=1 "; break;
    case StatusLearningDueNow: qs += "WHERE status=1  AND due<" + now() + " "; break;
    case StatusReview: qs += "WHERE status=2 "; break;
    case StatusReviewDueToday: qs += "WHERE status=2 AND due<" + fourAM(1) + " "; break;
    case StatusReviewAheadDays: qs += "WHERE status=2 AND due<" + fourAM(1 + aheadDays) + " "; break;
    case StudyToday: qs += "WHERE lastStudy>" + fourAM(0) + " AND lastStudy<" + fourAM(1) + " "; break;
    case StudyAll: qs += "WHERE lastStudy>0 "; break;
    case Mastered: qs += "WHERE ansHistory % 16 = 15 "; break;
    default: return "";
    }
    switch (order) {
    case None: break;
    case Random: qs += "ORDER BY RANDOM() "; break;
    case ASC: qs += "ORDER BY " + orderTarget + " ASC"; break;
    case DESC: qs += "ORDER BY " + orderTarget + " DESC"; break;
    default: return "";
    }
    return qs;
}

QString AnkiDeck::prepareGetCardString(int no, CARD_FILTER filter=AnkiDeck::All, CARD_ORDER order=AnkiDeck::Random,
                             QString orderTarget="", qint64 aheadDays = 0){
    QString qs = "SELECT * FROM cardTable ";
    qs += getSqlFilterStr(filter, order, orderTarget, aheadDays);
    if(no != -1){
        qs += " LIMIT " + QString::number(no);
    }
    return qs;
}

// Pointer to member function is different from pointer to normal function. It's not good to make these
// callback functions as AnkiDeck's member function, because callback function type is defined in
// SQLiteBasic.h. SQLiteBasic can be inherited by a class other than AnkiDeck
void getCardsAsyncCallback(QSqlQuery* p_query, void* p_this){
    QString cards = ((AnkiDeck*)p_this)->jsonizeCards(p_query);
    emit ((AnkiDeck*)p_this)->cardsReady(cards);
}

void AnkiDeck::getCardsAsync(int no, CARD_FILTER filter=AnkiDeck::All, CARD_ORDER order=AnkiDeck::Random,
                           QString orderTarget="", qint64 aheadDays = 0) {
    QString qs = prepareGetCardString(no, filter, order, orderTarget, aheadDays);
    getCardsAsync(qs);
}

void AnkiDeck::getCardsAsync(QString qs){
    QSqlQuery* p_query = new QSqlQuery(*m_pdb);
    execute(p_query, qs, getCardsAsyncCallback);
}

QString AnkiDeck::getCards(int no, CARD_FILTER filter=AnkiDeck::All, CARD_ORDER order=AnkiDeck::Random,
                           QString orderTarget="", qint64 aheadDays = 0) {
    QString qs = prepareGetCardString(no, filter, order, orderTarget, aheadDays);
    return getCards(qs);
}

QString AnkiDeck::getCards(QString qs){
    QSqlQuery query(*m_pdb);
    if (!query.exec(qs)) {
        qDebug() << "error while executing sql command in browse. Err Msg:" << query.lastError(); }
    return jsonizeCards(&query);
}

QString AnkiDeck::jsonizeCards(QSqlQuery *p_query) {

    QString result = "{ \"cards\": [";
    while (p_query->next()) {
        result += "{";
        for (int i=0;i<fieldNumber;i++) {
            const char *format;
            if (strcmp(tableFields[i].type, "TEXT")==0) { format = "\"%1\": \"%2\","; }
            else { format = "\"%1\": %2,"; }
            QString one = QString(format).arg(tableFields[i].field, "%1");
            QVariant value = p_query->value(tableFields[i].field);
            if (strcmp(tableFields[i].field, "pa")==0 || strcmp(tableFields[i].field, "notes")==0) {
                one = one.arg((QString)value.toByteArray().toBase64());
            } else {
                // for error handling, once the database is out of order...
                if(strcmp(tableFields[i].type, "TEXT")!=0 &&
                        value.toString()=="") { one = one.arg(0); }
                else { one = one.arg(value.toString());}
            }
            result += one;
        }
        result = result.remove(result.length()-1, 1);
        result += "},";
    }
    if (result[result.length()-1]==',') result = result.remove(result.length()-1, 1);
    result += "] }";
    p_query->finish();
    //p_query->clear();
    return result;
}

QString AnkiDeck::fourAM(qint64 diffDay) {
    QDateTime today = QDateTime::currentDateTime();
    today.setTime(QTime(4,0,0));
    return QString::number(today.addDays(diffDay).toMSecsSinceEpoch());
}
QString AnkiDeck::now(){
    QDateTime now = QDateTime::currentDateTime();
    return QString::number(now.toMSecsSinceEpoch());
}

QString AnkiDeck::deckInfo() const{
    return m_deckInfo;
}

void makeDeckID(QSqlQuery* p_query) {
    QString qs = "select did from deckInfo limit 1;";
    if (!p_query->exec(qs)) { qWarning() << "Sql command err msg:" << p_query->lastError(); }
    if (!p_query->next()) {
        qs = "INSERT INTO deckInfo (did) VALUES (" +
             QString::number(QDateTime::currentDateTime().toMSecsSinceEpoch()) + ")";
        if (!p_query->exec(qs)) { qWarning() << "Sql command err msg:" << p_query->lastError(); }
    }
}

void AnkiDeck::openDatabase(QString dbFile) {
    if (openDBFile(dbFile)) {
        QSqlQuery* p_query = new QSqlQuery(*m_pdb);
        QString qs = "CREATE TABLE IF NOT EXISTS cardTable(";
        qs += QString("%1 %2 PRIMARY KEY").arg(tableFields[0].field, tableFields[0].type);
        for (int i=1;i<fieldNumber;i++) {
            qs += QString(", %1 %2").arg(tableFields[i].field, tableFields[i].type);
        }
        qs += ")";
        if (!p_query->exec(qs)) { qWarning() << "Sql command err msg:" << p_query->lastError(); }
        qs = "CREATE TABLE IF NOT EXISTS deckInfo(did INT PRIMARY KEY)";
        if (!p_query->exec(qs)) { qWarning() << "Sql command err msg:" << p_query->lastError(); }
        makeDeckID(p_query);
        p_query->finish();
        //p_query->clear();
        delete p_query;
    }
}

void AnkiDeck::setImageVendor (MediaBox *pVendor){
    m_pImageVendor = pVendor;
}

void AnkiDeck::setWordSpeaker(MediaBox *pSpeaker){
    m_pWordSpeaker = pSpeaker;
}

void AnkiDeck::makeUnique() {
    QSqlQuery* p_query = new QSqlQuery(*m_pdb);
    QString qs = QString("UPDATE deckInfo set did=%1").arg(QDateTime::currentDateTime().toMSecsSinceEpoch());
    if (!p_query->exec(qs)) { qWarning() << "Sql command err msg:" << p_query->lastError(); }
    p_query->finish();
    //p_query->clear();
    delete p_query;
}
