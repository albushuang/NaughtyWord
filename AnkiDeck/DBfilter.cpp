
#include <QtDebug>
#include <assert.h>
#include <QDir>
#include "DBfilter.h"

#define WARNING_MSG "error while executing sql command. Err Msg:"

DBFilter::DBFilter(): m_fields(NULL), m_table("") {
    connect(this, SIGNAL(filterDB(QString)), this, SLOT(StarFilter(QString)));
}

DBFilter::~DBFilter() { }

void DBFilter::setFields2FilterAndTable(QStringList fields, QString table){
    m_fields = fields;
    m_table = table;
}


QString prepareOutputName(QString name, QString newPath, QString samePath) {
    newPath = newPath == "" ? samePath : newPath;
    if(!newPath.endsWith('/')) newPath += "/";
    return newPath+name;
}

bool DBFilter::filteredDBKeepFields(QString input, QString output, QString outputPath) {
    if (openDBFile(input)!=true) { return false; }
    if (m_table!="") {
        QString fullOutput = prepareOutputName(output, outputPath, m_pathInfo);
        emit filterDB(fullOutput);
        return true;
    }
    return false;
}

QString DBFilter::filteredDBKeepFields(QString fullPath) {
    int index = fullPath.lastIndexOf("/");
    QString pathName = fullPath.left(index+1);
    QString inputName = fullPath.mid(index+1);
    QString mainName = inputName.section(".", 0, 0);
    QString outputName = mainName+"_WithoutImageSpeech"+inputName.split(mainName, QString::SkipEmptyParts)[0];
    m_pathInfo = pathName;
    if (filteredDBKeepFields(inputName, outputName, pathName)) return pathName+outputName;
    else return "";
}


QString filterFields(QStringList &fields, QSqlDatabase* pdb, QString table, bool withNULL) {
    QString replace = withNULL ? "NULL," : "";
    QSqlQuery query(*pdb);
    QString qs = "PRAGMA table_info(" + table + ");";
    QString result = "";
    if (query.exec(qs)) {
        while (query.next()) {
            if(fields.contains(query.value(1).toString(), Qt::CaseInsensitive)) {
                result += replace;
            } else {
                result += query.value(1).toString() + ",";
            }
        }
        if(result.length()!=0) result = result.remove(result.length()-1, 1);
    } else { qWarning() << WARNING_MSG << query.lastError(); }

    query.finish();
    return result;
}

void DBFilter::StarFilter(QString fullOutput) {
    QSqlQuery query(*m_pdb);
    QStringList qsl;
    qsl << "ATTACH DATABASE '" + fullOutput + "' AS outputDB";
    qsl << "CREATE TABLE outputDB." + m_table + " AS select * from " + m_table + " limit 0;";
    qsl << "INSERT INTO outputDB." + m_table + " SELECT " +
           filterFields(m_fields, m_pdb, m_table, true) + " FROM " + m_table;
    // TODO: close database and open new database for integrity check
    qsl << "PRAGMA integrity_check;";
    qsl << "VACUUM;";

    int command=0;
    while(query.exec(qsl[command])) {
        if (++command >= qsl.length()) break;
    }

    if (command < qsl.length()) {
        qWarning() << WARNING_MSG << query.lastError();
        emit filterError();
    } else { emit filterDone(fullOutput); }

    query.finish();
    databaseDeInit();
}

