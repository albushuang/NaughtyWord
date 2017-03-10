#ifndef DB_FILTER_H
#define DB_FILTER_H

#include "SQLiteBasic.h"


class DBFilter : public SQLiteBasic
{
Q_OBJECT

    Q_PROPERTY(QString pathInfo READ pathInfo WRITE setPathInfo)

public:

    DBFilter(); // no parameter is allowed
    ~DBFilter();

public Q_SLOTS:
    bool filteredDBKeepFields(QString input, QString output, QString outputPath = "");
    QString filteredDBKeepFields(QString fullPath);
    void setFields2FilterAndTable(QStringList, QString);

Q_SIGNALS:
    void filterDone(QString);
    void filterError();

signals:
    void filterDB(QString);

private slots:
    void StarFilter(QString);

private:
    QStringList m_fields;
    QString m_table;
};

#endif // DB_FILTER_H

// QML example:
//      DBFilter { id: dbfilter }
//      function generateUploadDB() {
//          dbfilter.pathInfo = getDatabasePath();
//          var fields = ["speech", "image"];
//          dbfilter.setFields2FilterAndTable(fields, "cardTable");
//          dbfilter.outputFilteredDB("NBA.kmrj", "NBAtest.kmrj");
//      }
