
#include <assert.h>
#include "SQLiteBasic.h"
#include <qDebug>

#define WARNING_MSG "error while executing sql command. Err Msg:"


Worker::Worker( QObject* parent )
    : QObject( parent )
{
}

Worker::~Worker()
{
}

void Worker::slotExecute(QSqlQuery* p_query, QString qs, HandleResultCallback callback)
{
    if(qs != ""){
        if (!p_query->exec(qs)) { qDebug() << "error while executing sql. Err Msg:" << p_query->lastError(); }
    }else{
        if (!p_query->exec()) { qDebug() << "error while executing sql. Err Msg:" << p_query->lastError(); }
    }
    emit results(p_query, callback);
}


SQLiteBasic::SQLiteBasic(QObject *parent): m_pathInfo(""), m_pdb(NULL) {
    Q_UNUSED(parent)
    m_connectionID = QString::number(QDateTime::currentDateTime().toMSecsSinceEpoch());
    m_pThread = new DBThread();
    m_pThread->m_pOwner = this;
    m_pThread->start();  //start the thread so Qthread will call "run()" in its thread(For ex, work thread).
              //Note that this constructor is called in the thread of creating this instance (main thread)
}

SQLiteBasic::~SQLiteBasic() {
    if (m_pdb != NULL) { databaseDeInit(); }
    m_pThread -> quit();
    m_pThread -> wait();
    delete m_pThread;
}

void SQLiteBasic::setPathInfo(QString path) {
    m_pathInfo = path + (path.endsWith('/') ? "" : "/");
}

QString SQLiteBasic::pathInfo() const {
    return m_pathInfo;
}


void SQLiteBasic::databaseInit() {
    if (m_pdb == NULL) {
        m_pdb = new QSqlDatabase(QSqlDatabase::addDatabase("QSQLITE", m_connectionID));
    }
    if (m_pdb->isValid() == false ) { qWarning() << "database is not valid!"; }
}

void SQLiteBasic::databaseDeInit() {
    if(m_pdb != NULL) { m_pdb->close(); }
    QSqlDatabase::removeDatabase(m_connectionID);
    delete m_pdb;
    m_pdb = NULL;
}

bool SQLiteBasic::openDBFullPath(QString fullPath) {
    closeDB();
    databaseInit();

    m_pdb->setHostName("localhost");
    m_pdb->setDatabaseName(fullPath);
    if (m_pdb->open() == false ) {
        qWarning() << "open database failed!!" << m_pdb->lastError();
        return false;
    }
    return true;
}


bool SQLiteBasic::openDBFile(QString input) {
    return openDBFullPath(m_pathInfo+input);
}

void SQLiteBasic::closeDB() {
    if(m_pdb != NULL) { m_pdb->close(); }
}

//Remember to dynamic "new"(alloc) a query to call this function
void SQLiteBasic::execute(QSqlQuery* p_query, QString qs, HandleResultCallback callback)
{
    emit executefwd(p_query, qs, callback);
}


DBThread::DBThread(QObject *parent) {
    Q_UNUSED(parent)
}
DBThread::~DBThread() { }

void DBThread::run()
{

    // Create worker object within the context of the new thread
    m_worker = new Worker();

    // Critical: register new type so that this signal can be
    // dispatched across thread boundaries by Qt using the event system
    qRegisterMetaType<QSqlQuery>( "QSqlQuery" );
    qRegisterMetaType<HandleResultCallback>( "HandleResultCallback" );

    connect( m_pOwner, SIGNAL( executefwd( QSqlQuery*, QString, HandleResultCallback) ),
             m_worker, SLOT( slotExecute( QSqlQuery*, QString, HandleResultCallback) ) );

    connect( m_worker, SIGNAL( results(QSqlQuery*, HandleResultCallback) ),
             m_pOwner, SIGNAL( results(QSqlQuery*, HandleResultCallback) ) );

    exec();
}
