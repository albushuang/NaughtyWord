#include <QDesktopServices>
#include "QTDropboxQml.h"
#include <QtDebug>
#include <QApplication>
#include <QClipboard>

#define APP_KEY "rgmlv7zrwyg9hji"   //Under Clark's account
#define APP_SECRET "langz0yrkyanzph"    //Under Clark's account
#define QVERIFY2(x, y) if(x!=true) { qDebug() << y; }
typedef QMap<QString, QSharedPointer<QDropboxFileInfo> > QDropboxFileInfoMap;

QTDropboxQml::QTDropboxQml() {
    dropbox.setKey(APP_KEY);
    dropbox.setSharedSecret(APP_SECRET);
    tokenFile.setFileName("tokens");
    setApi(&dropbox);
    connect(this, SIGNAL(readyRead()), this, SLOT(saveFile()));
    connect(this, SIGNAL(downloadProgress(qint64,qint64)), this, SLOT(progress(qint64,qint64)));
    connect(this, SIGNAL(uploadProgress(qint64,qint64)), this, SLOT(progress(qint64,qint64)));
}

QTDropboxQml::~QTDropboxQml() { }

void QTDropboxQml::start() {

    disconnect(this, SIGNAL(dbConnected()), 0, 0);
    connect(this, SIGNAL(dbConnected()), this, SLOT(fillFileList()));

    QVERIFY2(connectDropbox(QDropbox::Plaintext), "connection error");
}

void QTDropboxQml::logout(){
    tokenFile.remove();
    dropbox.setTokenSecret("");
    dropbox.setToken("");

    emit logoutFinished();
}

bool QTDropboxQml::connectDropbox(QDropbox::OAuthMethod m)
{

    if(tokenFile.exists()) // reuse old tokens
    {
        if(tokenFile.open(QIODevice::ReadOnly|QIODevice::Text))
        {
            QTextStream instream(&tokenFile);
            QString token = instream.readLine().trimmed();
            QString secret = instream.readLine().trimmed();
            if(!token.isEmpty() && !secret.isEmpty())
            {
                dropbox.setToken(token);
                dropbox.setTokenSecret(secret);
                tokenFile.close();
                emit dbConnected();
                return true;
            }
        }
        tokenFile.close();
    }

    // acquire new token
    if(!dropbox.requestTokenAndWait())
    {
        qCritical() << "error on token request";
        return false;
    }

    dropbox.setAuthMethod(m);
    if(!dropbox.requestAccessTokenAndWait())
    {
        qDebug()<<"ask login";
        emit requestUserConsent(dropbox.authorizeLink().toDisplayString());

    }
    return true;
}

void QTDropboxQml::continueUnfinished() {
    dropbox.requestAccessTokenAndWait();
    if(dropbox.error() != QDropbox::NoError)
    {
       qCritical() << "Error: " << dropbox.error() << " - " << dropbox.errorString() << endl;
       return;
    }
    if(!tokenFile.open(QIODevice::WriteOnly|QIODevice::Truncate|QIODevice::Text))
        return;

    QTextStream outstream(&(tokenFile));
    outstream << dropbox.token() << endl;
    outstream << dropbox.tokenSecret() << endl;
    tokenFile.close();

    emit dbConnected();
}

void QTDropboxQml::fillFileList() {
    //QTextStream strout(stdout);
    QDropboxAccount accInf = dropbox.requestAccountInfoAndWait();
    QVERIFY2(dropbox.error() == QDropbox::NoError, "error on request");

    QString cursor = "";
    bool hasMore = true;
    QDropboxFileInfoMap file_cache;
    m_fileList = "";

    do
    {
        QDropboxDeltaResponse r = dropbox.requestDeltaAndWait(cursor, "");
        cursor = r.getNextCursor();
        hasMore = r.hasMore();

        const QDropboxDeltaEntryMap entries = r.getEntries();
        for(QDropboxDeltaEntryMap::const_iterator i = entries.begin(); i != entries.end(); i++)
        {
            if(i.key().contains(".kmr")){
//                qDebug() << "file:" << i.key() << "path:" << i.value()->path() << "\n";
                m_fileList += i.value()->path() + "\n";
            }
        }

    } while (hasMore);
    emit fileListChanged();

}


void QTDropboxQml::download(const QString fileName){
    QString fullPath = "/dropbox" + fileName;

    setFilename(fullPath);
    open(QIODevice::ReadOnly);
}

void QTDropboxQml::saveFile(){

    QString filePath = m_storagePath + m_fileName;
    QFile save(filePath);
    if (save.open(QIODevice::WriteOnly)!=true) {
        qWarning() << filePath << "open failed!";
        return;
    }
    QDropboxFileInfo fileInfo = metadata();
    quint64 fileSize = fileInfo.bytes();
    char *data = (char*) malloc (fileSize);
    readData(data, fileSize);
    save.write(data, fileSize);
    save.close();;

    emit downloaded();
}

void QTDropboxQml::upload(const QString localFullFilePath, const QString networkFilePath){
    QFile file(localFullFilePath);
    file.open(QIODevice::ReadOnly);
    QByteArray data = file.readAll();
    file.close();

    setFilename("/dropbox" + networkFilePath);
    open(QIODevice::WriteOnly);
    writeData(data.data(), data.size());
//    close();  //if we close(), it will upload again

    emit uploaded();
}

QString QTDropboxQml::requestSharedLink(QString file){
    QUrl sharedLink = dropbox.requestSharedLinkAndWait("/dropbox" + file);
    QClipboard *clipboard = QApplication::clipboard();
    clipboard->setText(sharedLink.toDisplayString());
    return sharedLink.toDisplayString();
}

QString QTDropboxQml::fileList() const{
    return m_fileList;
}

void QTDropboxQml::setFileList(const QString fileList) {
    m_fileList = fileList;
}

void QTDropboxQml::setFileName(const QString fileName) {
    m_fileName = fileName;
}

QString QTDropboxQml::fileName() const{
    return m_fileName;
}

void QTDropboxQml::setStoragePath(const QString path) {
    m_storagePath = path;
    if(m_storagePath != ""){
        if (!path.endsWith("/")) {m_storagePath += "/";}
        if(m_storagePath.startsWith("file://")) {m_storagePath.remove(0, 7);}
    }
}

QString QTDropboxQml::storagePath() const{
    return m_storagePath;
}

void QTDropboxQml::progress(qint64 now, qint64 total) {
    emit progressing((double)now/1024/1024, total==-1?0:(double)total/1024/1024);
}
