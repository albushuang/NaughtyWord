#include "dictLookup.h"
#include "../dictionary/dictlib.h"
#include <QtDebug>
#include <QTextCodec>
#include <math.h>

DictLookUp::DictLookUp() :
    m_file(":/dictionary/gdicts.idx"),
    m_cfile(":/dictionary/cedict.lib"),
    m_maxResult(0) {
    m_lastSeachKey = "";
    connect(this, SIGNAL (startSearch()), this, SLOT (executeSearch()));
    m_file.open(QIODevice::ReadOnly);
    m_cfile.open(QIODevice::ReadOnly);
}

DictLookUp::~DictLookUp() {
    m_file.close();
    m_cfile.close();
}


QStringList DictLookUp::searchResult() const {
    return m_searchResult;
}

QString DictLookUp::searchKey() const {
    return m_searchKey;
}

void DictLookUp::setSearchKey(const QString key){
    m_searchKey = key;
    m_moreResult = false;

    if (m_searchKey != "") emit startSearch();
    else m_lastSeachKey = "";
}

void DictLookUp::setLanguage(const QString lang) {
    m_language = lang;
}

bool DictLookUp::setMoreResult(bool flag){
    m_moreResult = flag;
    if (m_moreResult == true)
    {
        emit startSearch();
    }
    return m_moreResult;
}

bool DictLookUp::moreResult(){

    return m_moreResult;
}

void DictLookUp::executeSearch() {
    m_searchResult.clear();
    if(m_searchKey[0].toUpper()>='A' && m_searchKey[0].toUpper()<='Z') {
        sequentialSearch(&m_file);
        m_lastSeachKey = m_searchKey;
    }
    else {
        QByteArray keyBytes = m_searchKey.toUtf8();
        if ((unsigned char)keyBytes[0] >= 0xe4) {
            binarySearchChinese();
        }
    }
    m_lastSeachKey = m_searchKey;
    emit searchDone();
}

#define CEDICT_HEADERS 0x3190
int DictLookUp::binarySearchChinese(){
    seekDictionaryFile2();
    int resultcount = 0;
    do {
        QByteArray aline = m_cfile.readLine(512); // how much is enough? what if not enough?
        QString bline = aline;

        if (bline == "" ) { break; }
        //if(m_language=="sc") { int index = bline.indexOf(" "); bline = bline.remove(0, index+1); }
        if (bline.startsWith(m_searchKey, Qt::CaseSensitive)) {
            if(resultcount==0 && !m_moreResult) {
                m_advancedSearchStart = m_cfile.pos();
            }
            bline[bline.length()-1]='\0';
            QString newLine = bline.split(" ")[0] + "=";
            QStringList lines = bline.split("/");
            for (int i=1;i<lines.count()-1;i++) newLine += lines[i] + "; ";
            m_searchResult.append(newLine);
            resultcount ++;
        }
        else if (bline.split("=")[0] > m_searchKey) {
            break;
        }

    } while (resultcount<m_maxResult);
    m_fileLastPosition = m_cfile.pos();
    return resultcount;
}

#define MAKE_UTF8_INT(a) ((unsigned char)(a)[0] << 16) | ((unsigned char)(a)[1] << 8) | ((unsigned char)(a)[2])
void DictLookUp::seekDictionaryFile2(){
    qint64 fileOffset;

    if(m_moreResult) { fileOffset = m_fileLastPosition; }
    else if (m_lastSeachKey != "" && m_searchKey.contains(m_lastSeachKey)) {
        fileOffset = m_advancedSearchStart;
    }
    else {
        qint64 fileSize = m_cfile.size();
        QByteArray keyBytes = m_searchKey.toUtf8();
        m_searchValue =  MAKE_UTF8_INT(keyBytes);
        qint64 seekRange = (float)(m_searchValue-0xe4b880)/(0xe9beb6-0xe4b880) * fileSize;
        Q_ASSERT(seekRange >= 0);

        fileOffset=recursiveFind(seekRange);
    }
    m_cfile.seek(fileOffset);
}


#define MAGIC_NUMBER 256
#define MAGIC_NUMBER2 0.02
qint64 DictLookUp::recursiveFind(qint64 seekRange){
    m_cfile.seek(seekRange + CEDICT_HEADERS); m_cfile.readLine(512);
    qint64 currentPos = m_cfile.pos();
    QString bline = m_cfile.readLine(512);

    QByteArray keyBytes2 = bline.split(" ")[0].toUtf8();
    qint64 valueFound = MAKE_UTF8_INT(keyBytes2);

    if(m_searchValue >= valueFound && m_searchValue-valueFound < MAGIC_NUMBER) {
        if (m_searchValue > valueFound) return currentPos;
        else return seekBack(seekRange + CEDICT_HEADERS);
    }
    else {
        float diff = (float)(valueFound-m_searchValue)/(m_searchValue-0xe4b880);
        seekRange *= (1-diff);
    }

    return recursiveFind(seekRange);
}

qint64 DictLookUp::seekBack(qint64 seekRange) {
    qint64 startRange = seekRange;
    do {
        startRange -= 512;
        m_cfile.seek(startRange); m_cfile.readLine(512);
        QString aline = m_cfile.readLine(512);
        QByteArray keyBytes2 = aline.split(" ")[0].toUtf8();
        qint64 valueFound = MAKE_UTF8_INT(keyBytes2);
        if (valueFound != m_searchValue) break;
    } while(1);
    return m_cfile.pos();
}


int DictLookUp::sequentialSearch(QFile *file) {
    int resultcount = 0;
    seekDictionaryFile(file);
    do {
        QByteArray aline = file->readLine(256); // how much is enough? what if not enough?
        QString bline = aline;
        if (bline == "" ) { break; }
        else if (bline.startsWith(m_searchKey, Qt::CaseInsensitive)) {
            aline[aline.length()-1]='\0';
            QList<QByteArray> info = aline.split('=');
            m_searchResult.append(info[0]);
            resultcount ++;
        }
        else if (bline.split("=")[0] > m_searchKey.toLower()) {
            break;
        }
    } while (resultcount<m_maxResult);
    m_fileLastPosition = file->pos();
    return resultcount;
}

void DictLookUp::seekDictionaryFile(QFile *file){
    qint64 fileOffset;

    if(m_moreResult) { fileOffset = m_fileLastPosition; }
    else {
        int letter = m_searchKey.toUpper()[0].cell() - 'A';
        int index2 = m_searchKey.toUpper()[1].cell() - 'A';
        fileOffset = dictOffsets[letter].letter;

        if (m_searchKey[1] == QChar('\0')) { }
        else if (index2>=0 && index2 <=25) fileOffset += dictOffsets[letter].offsets[index2];
    }
    file->seek(fileOffset);
}

int DictLookUp::maxResult() const{
    return m_maxResult;
}

QString DictLookUp::language() const{
    return m_language;
}

int DictLookUp::setMaxResult(int max) {
    m_maxResult = max;
    return 0;
}

