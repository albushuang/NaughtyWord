
#include <QtDebug>
#include <assert.h>
#include <QDir>
#include "AnkiPackage.h"



typedef struct tableItem {
    const char *field;
    const char *type;
} TableItem;

TableItem ankiTableFields[] = {
    {"id", "INT"},
    {"factor", "INT"},
    {"type", "INT"},
    {"queue", "INT"},
    {"ivl", "INT"},
    {"due", "INT"},
    {"odue", "INT"},
    {"lapses", "INT"},
    {"flags", "INT"}
};

int ankiFieldNumber = sizeof(ankiTableFields)/sizeof(tableItem);

#define ANKIDB "collection.anki2"
AnkiPackage::AnkiPackage() : m_objArray(), m_ankiPath() {
}

AnkiPackage::~AnkiPackage() {
    closePackage();
}

QString AnkiPackage::basePath() const {
    return m_ankiPath;
}

bool AnkiPackage::isAnkiPackage(QString path) {
    if (!path.endsWith("/")) path += "/";
    return QFile::exists(path+ANKIDB);
}

QByteArray getModel(QSqlQuery & query) {
    QByteArray ret;
    if (!query.exec("select models from col limit 1")) {
        qDebug() << "error while getModel, err Msg:" << query.lastError();
    }
    else if (query.next()) { ret = query.value("models").toByteArray(); }
    return ret;
}

QString AnkiPackage::getDeckID(){
    QString ret;
    if(m_pdb!=NULL) {
        QSqlQuery query(*m_pdb);
        // also available in col/deck
        if (!query.exec("select did from cards limit 1")) {
            qDebug() << "error while getDeckID, err Msg:" << query.lastError();
        }
        else if (query.next()) { ret = query.value("did").toString(); }
        query.finish();
    }
    return ret;
}

QJsonArray getModelArray(QJsonDocument & jd) {
    QJsonObject obj = jd.object();
    obj = obj.take(obj.keys()[0]).toObject();
    return obj.take("flds").toArray();
}

QJsonArray getFields(QSqlQuery & query) {
    QJsonDocument jd = QJsonDocument::fromJson(getModel(query));
    return getModelArray(jd);
}

bool AnkiPackage::openPackage(QString path){
    if (!path.endsWith("/")) path += "/";
    if(openDBFullPath(path+ANKIDB)) {
        m_ankiPath = path;
        QSqlQuery query(*m_pdb);
        m_objArray = getFields(query);
        return true;
    }
    return false;
}

QString extract(QString source, QString start, QString end, int& ihead, int& itail) {
    ihead = source.indexOf(start, itail);
    int e =  source.indexOf(end, ihead+start.length());
    itail = e + end.length();
    if(ihead<0) return QString();
    return source.mid(ihead+start.length(), e-ihead-start.length());
}

QString tryConvert(QString &toBeConvert) {
    QChar *a = toBeConvert.data();
    QString news;
    int i=0;
    while(a[i]!=0) {
        int convert = a[i++].unicode();
        if(convert > 0x7f) {
            news+=QString("\\u%1").arg(convert,4,16,QLatin1Char('0'));
        } else {
            news+=(char)convert;
        }
    }
    return news;
}

void getStartEnd(QString & media, QString &res, int &s, int &e) {
    s = media.indexOf("\""+res+"\"", 0, Qt::CaseInsensitive);
    if(s==-1) {
        s = media.indexOf("\""+tryConvert(res)+"\"", 0, Qt::CaseInsensitive);
    }
    e = media.lastIndexOf("\"", s-2);
    s = media.lastIndexOf("\"", e-1);
}

void findFile(QString & media, QString & target, QString head, QString tail) {
    int ihead, itail=0;
    do {
        QString res = extract(target, head, tail, ihead, itail);
        if (res.isEmpty()) break;
        int start, end;
        getStartEnd(media, res, start, end);
        target.insert(target.indexOf(res)+res.length(), "##" + media.mid(start+1, end-start-1));
    } while(1);
}

QString findFile2(QString & media, QString & target, QString head, QString tail, QString t2="") {
    int ihead, itail = 0;
    QString retMedia;
    do {
        QString res = extract(target, head, tail, ihead, itail);
        if (res.isEmpty()) break;
        int start, end;
        getStartEnd(media, res, start, end);
        if(retMedia.isEmpty()) {retMedia = res + "##" + media.mid(start+1, end-start-1); }
        if(t2!="") itail = target.indexOf(t2, itail) + 1;
        target.remove(ihead, itail-ihead);
        itail-=(itail-ihead);
    } while(1);
    return retMedia;
}

void localResource2(QString all, QString &target, QString &image, QString &speech) {
    image = findFile2(all, target, "<img src=\"", "\"", ">");
    if(image.isEmpty()) { image = findFile2(all, target, "<img src='", "'", ">"); }
    speech = findFile2(all, target, "[sound:", "]");
}

void localResource(QString all, QString &target) {
    findFile(all, target, "<img src=\"", "\"");
    findFile(all, target, "<img src='", "'");
    findFile(all, target, "[sound:", "]");
}

void readMedia(QString path, QString &content) {
    QFile media(path+"media");
    media.open(QIODevice::ReadOnly);
    content = media.readAll();
    media.close();
}

QStringList AnkiPackage::browse(int index){
    QString qs = "select id, flds from notes limit " + QString::number(index) + ",1";
    QStringList aa;
    QSqlQuery query(*m_pdb);
    if (!query.exec(qs)) {
        qDebug() << "error while executing sql command in browse. Err Msg:" << query.lastError();
    }

    QString all;
    readMedia(m_ankiPath, all);

    if (query.next()) {
        QList<QByteArray> b = query.value("flds").toByteArray().split('\x1f');
        for(int i=0;i<b.count();i++) {
            QString target = b[i];
            localResource(all, target);
            aa.append(target);
        }
        aa.append(QString::number(query.value("id").toLongLong()));
    }

    return aa;
}

QJsonArray AnkiPackage::models() const {
    return m_objArray;
}

bool AnkiPackage::closePackage(){
    closeDB();
    return true;
}

QString fourAM(qint64 diffDay) {
    QDateTime today = QDateTime::currentDateTime();
    today.setTime(QTime(4,0,0));
    return QString::number(today.addDays(diffDay).toMSecsSinceEpoch());
}

QString now(){
    QDateTime now = QDateTime::currentDateTime();
    return QString::number(now.toMSecsSinceEpoch());
}

QString getSqlFilterStr(AnkiPackage::CARD_FILTER filter=AnkiPackage::All,
                        AnkiPackage::CARD_ORDER order=AnkiPackage::Random,
                        QString orderTarget="", qint64 aheadDays = 0, bool note=false){
    QString qs = "";
    switch (filter) {
    case AnkiPackage::All: qs += "WHERE cards.id>0 "; break;
    case AnkiPackage::StatusNew: qs += "WHERE cards.type=0 "; break;
    case AnkiPackage::StatusLearning: qs += "WHERE cards.type=1 "; break;
    case AnkiPackage::StatusLearningDueNow: qs += "WHERE cards.type=1  AND cards.due<" + now() + " "; break;
    case AnkiPackage::StatusReview: qs += "WHERE cards.type=2 "; break;
    case AnkiPackage::StatusReviewDueToday: qs += "WHERE cards.type=2 AND cards.due<" + fourAM(1) + " "; break;
    case AnkiPackage::StatusReviewAheadDays: qs += "WHERE cards.type=2 AND cards.due<" + fourAM(1 + aheadDays) + " "; break;
    case AnkiPackage::StudyToday: qs += "WHERE cards.odue>" + fourAM(0) + " AND cards.odue<" + fourAM(1) + " "; break;
    case AnkiPackage::StudyAll: qs += "WHERE cards.odue>0 "; break;
    case AnkiPackage::Mastered: qs += "WHERE cards.flags % 16 = 15 "; break;
    default: return "";
    }

    if(note) {
        qs += "AND notes.flds like '%' || \"<img src\" || '%' ";
    }
    switch (order) {
    case AnkiPackage::None: break;
    case AnkiPackage::Random: qs += "ORDER BY RANDOM() "; break;
    case AnkiPackage::ASC: qs += "ORDER BY " + orderTarget + " ASC"; break;
    case AnkiPackage::DESC: qs += "ORDER BY " + orderTarget + " DESC"; break;
    default: return "";
    }
    return qs;
}

QString prepareFields(bool notes) {
    QString result="SELECT cards.* FROM cards ";
    if(notes) {
        result += "CROSS JOIN notes ON cards.id=notes.id ";
    }
    return result;
}

QString prepareGetCardString(int no, AnkiPackage::CARD_FILTER filter=AnkiPackage::All,
                             AnkiPackage::CARD_ORDER order=AnkiPackage::Random,
                             QString orderTarget="", qint64 aheadDays = 0, bool notes=false){
    QString qs = prepareFields(notes) + getSqlFilterStr(filter, order, orderTarget, aheadDays, notes);
    if(no != -1){
        qs += " LIMIT " + QString::number(no);
    }
    return qs;
}

QString AnkiPackage::getCards(int no, CARD_FILTER filter=AnkiPackage::All, CARD_ORDER order=AnkiPackage::Random,
                           QString orderTarget="", qint64 aheadDays = 0) {
    QString qs = prepareGetCardString(no, filter, order, orderTarget, aheadDays);
    return getCards(qs);
}

QString AnkiPackage::getPicCards(int no, CARD_FILTER filter=AnkiPackage::All, CARD_ORDER order=AnkiPackage::Random,
                           QString orderTarget="", qint64 aheadDays = 0) {
    QString qs = prepareGetCardString(no, filter, order, orderTarget, aheadDays, true);
    return getCards(qs);
}


void getNotes(QSqlQuery& query, qint64 id, QString &result, QString &path, bool sfld) {
    QString qs = "select sfld, flds from notes where id=" + QString::number(id);
    if (!query.exec(qs)) {
        qDebug() << "error while executing sql command in browse. Err Msg:" << query.lastError();
    }
    result += "\"flds\": {";
    QString image, speech;

    QString all, word;
    readMedia(path, all);

    if (query.next()) {
        QList<QByteArray> b = query.value("flds").toByteArray().split('\x1f');
        for(int i=0;i<b.count();i++) {
            QString target = b[i];
            QString img, prn;
            localResource2(all, target, img, prn);
            if(image.isEmpty() && !img.isEmpty()) image = img;
            if(speech.isEmpty() && !prn.isEmpty()) speech = prn;
            result += "\"f" + QString::number(i) + "\" : \"" + target.toUtf8().toBase64() + "\",";
        }
        result.remove(result.length()-1, 1);
        if(sfld) { word = query.value("sfld").toString(); }
    }
    result += "}";
    if(sfld) { result += ", \"word\":\"" + word + "\""; }
    result += ", \"image\":\"" + image + "\"";
    result += ", \"speech\":\"" + speech + "\"";
}

bool chooseSFLD(QJsonArray models) {
    for (int j=0;j<models.count(); j++) {
        QJsonObject o = models[j].toObject();
        QStringList list = o.keys();
        for(int k=0;k<list.count();k++) {
            if(list[k]=="name") {
                QString field = o.value(list[k]).toString();
                if(QString::compare(field, "word", Qt::CaseInsensitive)==0 ||
                   QString::compare(field, "front", Qt::CaseInsensitive)==0 ||
                   QString::compare(field, "back", Qt::CaseInsensitive)==0) {
                    return false;
                }
            }
        }
    }
    return true;
}

QString AnkiPackage::jsonizeCards(QSqlQuery *p_query) {

    QString result = "{ \"cards\": [";
    while (p_query->next()) {
        result += "{";
        for (int i=0;i<ankiFieldNumber;i++) {
            const char *format;
            if (strcmp(ankiTableFields[i].type, "TEXT")==0) { format = "\"%1\": \"%2\","; }
            else { format = "\"%1\": %2,"; }
            QString one = QString(format).arg(ankiTableFields[i].field, "%1");
            QVariant value = p_query->value(ankiTableFields[i].field);
            // for error handling, once the database is out of order...
            if(strcmp(ankiTableFields[i].type, "TEXT")!=0 &&
                    value.toString()=="") { one = one.arg(0); }
            else { one = one.arg(value.toString());}
            result += one;
        }
        QSqlQuery query2(*m_pdb);
        getNotes(query2, p_query->value("nid").toLongLong(), result, m_ankiPath, chooseSFLD(m_objArray));
        result += "},";
    }
    if (result[result.length()-1]==',') result = result.remove(result.length()-1, 1);
    result += "] }";
    p_query->finish();
    return result;
}


QString AnkiPackage::getCards(QString qs){
    QSqlQuery query(*m_pdb);
    if (!query.exec(qs)) {
        qDebug() << "error while executing sql command in browse. Err Msg:" << query.lastError(); }
    return jsonizeCards(&query);
}

int AnkiPackage::getRowCounts(CARD_FILTER filter=AnkiPackage::All, qint64 aheadDays = 0) {
    int ret=0;
    QSqlQuery query(*m_pdb);
    QString command = "SELECT Count(*) FROM cards " + getSqlFilterStr(filter, AnkiPackage::None, "", aheadDays);
    if (!query.exec(command)) {
        qDebug() << "error while checking row counts. Err Msg:" << query.lastError();
    }
    if (query.next()) { ret = query.value(0).toInt(); }
    query.finish();
    if(ret == -1){ret = 0;}
    return ret;
}

bool inFields(QString field) {
    for(int i=0;i<ankiFieldNumber;i++) {
        if(field.startsWith(ankiTableFields[i].field)) return true;
    }
    return false;
}

void AnkiPackage::updateCard(QByteArray cardJSON, QStringList columnLists){
    QJsonDocument jd = QJsonDocument::fromJson(cardJSON);
    QVariantMap map = jd.toVariant().toMap();

    qint64 id = map.value("id").toLongLong();
    assert(id != 0);

    QSqlQuery* p_query = new QSqlQuery(*m_pdb);
    QString qs = "UPDATE cards SET ";
    for (int i=0; i<columnLists.size(); i++){
        if(inFields(columnLists[i])) {// QVariant knows the original type. So there is no problem...(you can check by calling.type())
            QString valueStr;
            valueStr = map.value(columnLists[i]).toString();
            qs += columnLists[i] + " = " +  valueStr + " ";
        }
    }
    qs += " WHERE id = " + QString::number(id);

    if (!p_query->exec(qs)) {
        qDebug() << "error while checking existence. Err Msg:" << p_query->lastError();
    }
    delete p_query;
}

void AnkiPackage::pullInPractice(int numberOfAheadDays){
    QSqlQuery query(*m_pdb);
    QString command = QString("update cards set due=due-%1 WHERE type=2;").arg(numberOfAheadDays);
    if (!query.exec(command)) {
        qDebug() << "error while pullInPractice. Err:" << query.lastError();
    }
    query.finish();
}


void vacuum(QSqlDatabase *m_pdb) {
    QSqlQuery query(*m_pdb);
    query.exec("PRAGMA integrity_check;");
    query.exec("VACUUM;");
    query.finish();
}

void AnkiPackage::clearHistory(){
    QSqlQuery query(*m_pdb);
    QString command = "UPDATE cards SET factor=250, odue=0, type=0,"  \
                      "ivl=0, queue=0, due=0, lapses=0," \
                      "flags=1;";
    query.exec(command);
    query.finish();
    vacuum(m_pdb);
}

