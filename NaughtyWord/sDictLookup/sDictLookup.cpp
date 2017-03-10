#include "SDictLookUp.h"
#include <QtDebug>
#include <math.h>
#include <QDir>
#include <stdio.h>

#ifndef WIN32
#include <strings.h>
#else
int strcasecmp(const char *s1, const char *s2) {
    while(1) {
        int c1 = tolower( *((unsigned char*) s1++));
        int c2 = tolower( *((unsigned char*) s2++));

        if (c1 != c2 || c1==0 || c2==0)
            return c1-c2;
    }
}
int strncasecmp(const char *s1, const char *s2, size_t n){
    int total = n;
    for(int i=0;i<total;i++) {
        int c1 = tolower( *((unsigned char*) s1[i]));
        int c2 = tolower( *((unsigned char*) s2[i]));

        if (c1 != c2 || c1==0 || c2==0)
            return c1-c2;
    }
    return 0;
}
#endif
#include "sDictLookupTool.h"

SDictLookUp::SDictLookUp(QObject *parent) : QObject(parent),
    m_dictPath(""),  m_ifo(NULL), m_idx(NULL),
    m_dict(NULL), m_sameType(""), m_dictName("") {
    connect(this, SIGNAL (startSearch()), this, SLOT (executeSearch()));
    m_advancingSearch = false;
    m_init = false;
}

void closeFiles(QFile &f1, QFile &f2, QFile &f3) {
    f1.close();
    f2.close();
    f3.close();
}

SDictLookUp::~SDictLookUp() {
    closeFiles(m_ifo, m_idx, m_dict);
}

bool SDictLookUp::valid() const {
    return m_init;
}

QStringList checkFiles(QString path) {
    QDir dir(path);
    QFileInfoList list = dir.entryInfoList(QDir::Files);
    QStringList fileList;
    for (int i=0;i<list.length();i++) {
        fileList << list[i].absoluteFilePath();
    }
    return fileList;
}


bool SDictLookUp::analyzeIFO() {
    QString line;
    bool result = false;

    do {
        line = m_ifo.readLine(256);
        if(line.startsWith("version")) getOffsetSize(line, m_offset);
        else if(line.startsWith("sametypesequence")) getConfigureValue(line, m_sameType);
        else if(line.startsWith("bookname")) {
            getConfigureValue(line, m_dictName);
            // support english-chinese only, for now
            if (m_dictName.contains("英漢")) { result = true; }
            else qDebug() << "filtered for now...";
        }
    } while (line.size()!=0);
    return result;
}

bool SDictLookUp::setDictPath(const QString path) {
    m_dictPath = path + (path.endsWith("/") ? "" : "/");
    QStringList files = checkFiles(m_dictPath);

    closeFiles(m_ifo, m_idx, m_dict);

    for (int i=0;i<files.length();i++) {
        if(files[i].endsWith(".ifo")) { m_ifo.setFileName(files[i]); continue; }
        if(files[i].endsWith(".idx")) { m_idx.setFileName(files[i]); continue; }
        if(files[i].endsWith(".dict")) { m_dict.setFileName(files[i]); continue; }
    }

    m_init= m_ifo.open(QIODevice::ReadOnly) && m_idx.open(QIODevice::ReadOnly) && m_dict.open(QIODevice::ReadOnly);
    if(m_init) {
        m_totalSize = m_idx.size();
        m_init = analyzeIFO();
    }

    return m_init;
}

QStringList SDictLookUp::searchResult() const {
    return m_searchResult;
}

QString SDictLookUp::searchKey() const {
    return m_searchKey;
}

void SDictLookUp::setSearchKey(const QString key){
    QString theKey = key.trimmed();
    if (m_searchKey!="" && theKey.startsWith(m_searchKey)) { // do advancingSearch
        m_lastSeachKey = m_searchKey;
        m_advancingSearch = true;
    }
    else {
        m_advancingSearch = false;
        m_lastSeachKey = "";
    }
    m_searchKey = theKey;
    m_moreResult = false;

    if (m_searchKey != "" && m_init) emit startSearch();
}

bool SDictLookUp::setMoreResult(bool flag){
    m_moreResult = flag;
    if (m_moreResult == true && m_init)
    {
        emit startSearch();
    }
    return m_moreResult;
}

bool SDictLookUp::moreResult(){

    return m_moreResult;
}

void SDictLookUp::executeSearch() {
    m_searchResult.clear();
    if(m_searchKey[0].toUpper()>='A' && m_searchKey[0].toUpper()<='Z') {
        sequentialSearch();
    }
    else {
        QByteArray keyBytes = m_searchKey.toUtf8();
        if ((unsigned char)keyBytes[0] >= 0xe4) {
            //binarySearchChinese();
        }
    }
    m_lastSeachKey = m_searchKey;
    emit searchDone();
}


int SDictLookUp::sequentialSearch() {
    QList<sDictIndex> indexList;

    if(m_moreResult) {
        char buffer[seekBackRange];
        int read = m_idx.read(buffer, seekBackRange);
        indexList = scanWords((const unsigned char*)buffer, read);
        m_moreResult = false;
    }
    else { indexList = seekIndex(); }

    for (int i=0;i<indexList.length();i++) {
        m_searchResult.append(readAndCompose(m_dict, indexList[i], m_sameType));
    }
    return indexList.length();
}

QList<sDictIndex> SDictLookUp::seekIndex(){ // dedicate for english only
    // should return if key contains non english, should avoid first space...
    QList<indexOffset> results;
    bool closed = false;
    char searchKey[128], init[2] = {'A', '\0'};
    char bufOrg[seekBackRange+seekBackRange], buffer[seekBackRange];
    const char *pKey = searchKey;
    int sizeLeft, keyLen;

    const char *lastFound;
    unsigned long lastOffset;

    strcpy(searchKey, m_searchKey.toUpper().toStdString().c_str());
    keyLen = strlen(searchKey);

    if (m_lastSeachKey!="") {
        strcpy(bufOrg, m_lastSeachKey.toUpper().toStdString().c_str());
        lastFound = bufOrg; lastOffset = m_lastKeyPosition;
    } else {
        lastFound = init;
        lastOffset = 0;
    }

    while (1) {
        appendFound(results, lastFound, lastOffset);
        lastOffset = guessOffset(m_totalSize, pKey, results, closed);
        const char *pWord = readWordFromData(buffer, m_idx, lastOffset, sizeLeft, m_offset);
        if (pWord==0) { break; } //EOF
        int compare = strncasecmp(pKey, pWord, keyLen);
        //qDebug() << "key and sample:" << pKey << pWord;
        if(compare>0) {
            if(prettyClosed((const unsigned char *)pWord, (const unsigned char*)pKey) || closed) {
                //qDebug() << "closed:" << (const char*)pWord << (char*)pKey;
                if (scanUntilFound(pWord, sizeLeft, pKey, keyLen, m_idx, bufOrg, m_offset)==FOUND){
                    m_lastKeyPosition = m_idx.pos() - sizeLeft;
                    return scanWords((const unsigned char*)pWord, sizeLeft);
                } else { break; }
            } else { lastFound = pWord; }
        } else {
            if(compare==0) {
                if (strcasecmp(pWord, pKey)==0) {
                    m_lastKeyPosition = m_idx.pos() - sizeLeft;
                    return scanWords((const unsigned char*)pWord, sizeLeft);
                }
            }
            lastFound = pWord;
        }
    }
    QList<sDictIndex> empty;
    return empty;
}


QList<sDictIndex> SDictLookUp::scanWords(const unsigned char *pWord, int bufferSize) {
    QList<sDictIndex> list;
    int resultCount=0;
    char bufOrg[seekBackRange+seekBackRange];
    char searchKey[128];
    strcpy(searchKey, m_searchKey.toStdString().c_str());

    if (scanUntilFound((const char *&)pWord, bufferSize,
                       (const char*)searchKey, m_searchKey.length(),
                       m_idx, bufOrg, m_offset)!=-1) {
        //qDebug() << "found:" << QString((char*)pWord);
        QByteArray newArray = QByteArray((const char*)pWord, bufferSize);
        while(resultCount++<m_maxResult) {
            insertToListBecomeNext(list, newArray, m_idx, m_offset);
            QString next = QString(newArray).toUpper();
            //qDebug() << QString(newArray) << m_searchKey << newArray.size();
            if (!next.startsWith(m_searchKey.toUpper())) {
                break;
            }
        }
        m_fileLastPosition = m_idx.pos()-newArray.size();
    }
    return list;
}


int SDictLookUp::maxResult() const{
    return m_maxResult;
}

int SDictLookUp::setMaxResult(int max) {
    m_maxResult = max;
    return 0;
}

