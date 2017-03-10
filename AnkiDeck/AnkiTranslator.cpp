
#include <QtDebug>
#include <assert.h>
#include <QDir>
#include <QDebug>
#include "AnkiTranslator.h"


AnkiTranslator::AnkiTranslator() {
    m_k2a["ef"] = "factor";
    m_k2a["status"] = "type";
    m_k2a["learningStep"] = "queue";
    m_k2a["interval"] = "ivl";
    m_k2a["due"] = "due";
    m_k2a["lastStudy"] = "odue";
    m_k2a["lapseCount"] = "lapses";
    m_k2a["ansHistory"] = "flags";
}

AnkiTranslator::~AnkiTranslator() {
}

int correctEF(QString & json, QString key) {
    int i=json.indexOf(key); // "ef" & "factor" only
    if(i>=0) {
        int b = json.indexOf(":", i);
        int e = json.indexOf(",", i);
        QString value = json.mid(b+1, e-b-1);
        QString wb = key=="ef" ? QString("%1").arg((double)value.toInt()/100, 0, 'f', 2) :
                                 QString("%1").arg((int)value.toDouble()*100);
        json.replace(b+1, e-b-1, wb);
    }
    return i;
}

void removeBetween(QString & word, QString s, QString e) {
    int loops = 0;
    do {
        int start = word.indexOf(s), end = word.indexOf(e, start+s.length());
        if(start>=0 && end>=0) {
            word.remove(start, end-start+e.length());
        } else return;
        loops++;
    } while(1);
}

QString removeHTML(QString word) {
    int loops = 0;
    do {
        int start = word.indexOf("<"), end = word.indexOf(">", start+1);
        if(start>=0 && end>=0) {
            if(word.mid(start, 4)!="<br>") {
                word.remove(start, end-start+1);
            } else {
                word.replace(start, 4, "\n");
            }
        } else break;
        loops++;
    } while(1);
    return word;
}


QString removeMedia(QString source) {
    QString res = source;
    removeBetween(res, "[", "]");
    removeBetween(res, "<img", ">");
    return res;
}

QString extract(QString source, QString start, QString end) {
    int s = source.indexOf(start);
    int e = source.indexOf(end, s+start.length());
    if(s<0) return QString();
    return source.mid(s+start.length(), e-s-start.length());
}

void rearrange(QString &json, QString word, QString notes, QString pa, bool toBase64) {
    int start = json.indexOf("\"flds\": {");
    int end = json.indexOf("}", start);
    if(toBase64) {
        notes = notes.toUtf8().toBase64();
        pa = pa.toUtf8().toBase64();
        word = word.toUtf8().toBase64();
    }
    QString toRep = "\"notes\":\""   + notes +
                     "\",\"pa\":\""   + pa;
    if(!word.isEmpty()) { toRep += "\",\"word\":\"" + word; }
    json.replace(start, end-start+1, toRep + "\"");
}

void makeNotes(QString & json, QJsonArray & models, bool toBase64) {
    QJsonDocument jd = QJsonDocument::fromJson(json.toUtf8());
    QJsonArray arr = jd.object().take("cards").toArray();

    for (int cardNo=0;cardNo<arr.count();cardNo ++) {
        QJsonObject obj2 = arr[cardNo].toObject().take("flds").toObject();

        QString word, front, back, meaning, pa;
        for (int j=0;j<models.count();j++) {
            QJsonObject o = models[j].toObject();
            QStringList list = o.keys();
            QString value = QByteArray::fromBase64(obj2.take("f"+QString::number(j)).toVariant().toByteArray());
            for(int k=0;k<list.count();k++) {
                if(list[k]=="name") {
                    QString field = o.value(list[k]).toString();
                    value = removeHTML(value.trimmed());
                    if (field.compare("Word", Qt::CaseInsensitive)==0) {
                        word = value;
                    } else if (field.compare("Front", Qt::CaseInsensitive)==0) {
                        front = value;
                    } else if (field.compare("Back", Qt::CaseInsensitive)==0) {
                        back = value;
                    } else if (field.compare("IPA", Qt::CaseInsensitive)==0) {
                        pa = value;
                    } else {
                        if (!value.isEmpty()) { meaning += "- " + value + "\n"; } // avoid field to make it suitable for card
                    }
                }
            }
        }
        if(word.isEmpty()) {
            word = front.isEmpty() ? back : front;
        } else {
            if(!meaning.isEmpty()) meaning += "\n";
            meaning += front;
        }
        if(!front.isEmpty()) {
            if(!meaning.isEmpty()) meaning += "\n";
            meaning += back;
        }
        rearrange(json, word, meaning, pa, toBase64);
    }
}

QString AnkiTranslator::toKMRJJSON(QString json, QJsonArray models, bool toBase64) {
    QList<QString> keys = m_k2a.keys();
    for(int i=0;i<keys.count();i++) {
        int index=0;
        do {
            index = json.indexOf("\""+m_k2a[keys[i]]+"\"", index, Qt::CaseInsensitive);
            if (index<0 || keys[i]=="") break;
            json.replace(index+1, m_k2a[keys[i]].length(), keys[i]);
            index+=keys[i].length();
        } while (1);
    }

    correctEF(json, "ef");
    makeNotes(json, models, toBase64);
    return json;
}

QString AnkiTranslator::toAnkiJSON(QString json) {
    QList<QString> keys = m_k2a.keys();
    for(int i=0;i<keys.count();i++) {
        int index=0;
        do {
            index = json.indexOf("\""+keys[i]+"\"", index, Qt::CaseInsensitive);
            if (index<0 || keys[i]=="") break;
            json.replace(index+1, keys[i].length(), m_k2a[keys[i]]);
            index+=m_k2a[keys[i]].length();
        } while (1);
    }

    correctEF(json, "factor");
    return json;
}

QString AnkiTranslator::toAnkiQuery(QString query) {
    QList<QString> keys = m_k2a.keys();

    for(int i=0;i<keys.count();i++) {
        int index=0;
        do {
            index = query.indexOf("\""+keys[i]+"\"", index, Qt::CaseInsensitive);
            if (index<0 || keys[i]=="") break;
            query.replace(index+1, keys[i].length(), m_k2a[keys[i]]);
            index+=m_k2a[keys[i]].length();
        } while (1);
    }
    // if contains "ef", the value should be converted to integer and times 100
    return query;
}

QString AnkiTranslator::toKMRJQuery(QString) {
    return "";
}

int AnkiTranslator::toAnkiFilter(int filter){
    return (AnkiPackage::CARD_FILTER) filter;
}

int AnkiTranslator::toAnkiOrder(int order){
    return (AnkiPackage::CARD_ORDER) order;
}

QString AnkiTranslator::toAnkiField(QString field){
    return m_k2a[field];
}

QString AnkiTranslator::toKMRJField(QString field){
    return m_k2a.key(field);
}
