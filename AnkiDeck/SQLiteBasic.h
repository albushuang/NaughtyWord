#ifndef SQLITE_BASIC_H
#define SQLITE_BASIC_H

#include <QObject>
#include <QList>
#include <QThread>
#include <QMutex>
#include <QtSql/QtSql>
#include <QSqlQuery>
#include <QSqlRecord>

typedef void (* HandleResultCallback) (QSqlQuery*, void *);

// The class that does all the work with the database. This class will
// be instantiated in the thread object's run() method.
class Worker : public QObject
{
  Q_OBJECT

   public:
    Worker( QObject* parent = 0);
    ~Worker();

  public slots:
    void slotExecute(QSqlQuery*, QString, HandleResultCallback);

  signals:
    void results( QSqlQuery*, quint64 );

   private:

};


class SQLiteBasic : public QThread
{
Q_OBJECT

public:

    SQLiteBasic(QObject *parent = 0); // no parameter is allowed
    ~SQLiteBasic();

    void setPathInfo(QString);
    QString pathInfo() const;

    bool openDBFile(QString);
    bool openDBFullPath(QString);
    void closeDB();

    void execute(QSqlQuery*, QString, HandleResultCallback);

public slots:
    void resultsReport( QSqlQuery*, quint64 );

public Q_SLOTS:


protected:
    void databaseInit();
    void databaseDeInit();
    QString m_pathInfo;
    QString m_connectionID;
    QSqlDatabase *m_pdb;
    void run();


Q_SIGNALS:


signals:
    void results( QSqlQuery*, quint64 );
    void executefwd(QSqlQuery*, QString, HandleResultCallback);



private:
     Worker* m_worker;
};

#endif //SQLITE_BASIC_H
