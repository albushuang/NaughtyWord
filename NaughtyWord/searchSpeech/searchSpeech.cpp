#include "searchSpeech.h"
#include <QtDebug>

SearchSpeech::SearchSpeech() : m_downloadedData(0),
    m_searchKey(""), m_mutex(QMutex::NonRecursive), m_searchNo(0)
{
   connect(&m_WebCtrl, SIGNAL (finished(QNetworkReply*)),
            this, SLOT (pageDownloaded(QNetworkReply*)));
   connect(this, SIGNAL (keyChanged()),  this, SLOT (startSearching()));
   connect(this, SIGNAL (oneSearchDone()),  this, SLOT (accumulateResults()));

}

SearchSpeech::~SearchSpeech() { }

void SearchSpeech::pageDownloaded(QNetworkReply* pReply) {
    m_mutex.lock();
    m_downloadedData = pReply->readAll();


    if(pReply->request().url() == m_targetSpeechUrl) {
        m_mutex.unlock();
        emit downloadCompleted();
    } else {
        analyzePage();
        pReply->deleteLater();
        m_mutex.unlock();
        emit oneSearchDone();
    }
}

void SearchSpeech::analyzePage() {
    QString page = m_downloadedData;
    if (page.contains("<title>Shtooka - Pronunciation", Qt::CaseInsensitive)) { // project shtooka
        getShtooka();
    } else if (page.contains("Yahoo奇摩")) {
        getYahoo();
    } else { // cdict
        if (page.contains("type=\"audio/mp3\">", Qt::CaseInsensitive)) {
            extractString("type=\"audio/mp3\">");
        } else if (page.contains("type=\"audio/wav\"", Qt::CaseInsensitive)) {
            extractString("type=\"audio/wav\">");
        }
    }
}

void SearchSpeech::getShtooka() {
    QString result = m_downloadedData;
    do {
        int indexB = result.indexOf("onClick=\"readtrack('player'"), indexE;
        if (result.mid(0, indexB).contains("Translations:", Qt::CaseInsensitive) ||
            result.mid(0, indexB).contains("Expressions:", Qt::CaseInsensitive) ||
            result.mid(0, indexB).contains("Derived forms:", Qt::CaseInsensitive) ) return;
        if (indexB == -1) return;
        result = result.remove(0, indexB+strlen("onClick=\"readtrack('player'"));
        indexB = result.indexOf("'http://");
        indexE = result.indexOf(".mp3'");
        m_urlList.append("shtooka@" + result.mid(indexB+1, indexE-indexB-1+4));
    } while(1);
}

void SearchSpeech::getYahoo() {
    const char audioExt[] = ".mp3";
    const char audioStart[] = "http://l.yimg.com";
    QString result = m_downloadedData;
    do {
        int indexE = result.indexOf(audioExt);
        if (indexE == -1) return;
        QString subString;
        QString mp3 = result.mid(0, indexE+strlen(audioExt));
        int indexB = mp3.lastIndexOf(audioStart, -1, Qt::CaseInsensitive);
        if (indexB < indexE) {
            subString = mp3.mid(indexB, indexE-indexB+strlen(audioExt));
            m_urlList.append("yahoo@" + subString);
        } else { return; }
        result = result.remove(0, indexB+subString.length());
    } while(1);
}

void SearchSpeech::extractString(QString target) {
    QString result = m_downloadedData;
    do {
        int indexB = result.indexOf("<source src=");
        int indexE = result.indexOf(target);
        if (indexB < indexE && indexB != -1) {
            QString subString = result.mid(indexB, indexE-indexB+1);
            if (! subString.contains(">") )  {
                QString candidate = subString.section("\"", 1, 1);
                if(candidate.startsWith("//")) candidate = "http:" + candidate;
                m_urlList.append("cdict@" + candidate);
                return;
            } else { result = result.remove(0, indexB+strlen("<source src=")); }
        } else { return; }
    } while(1);
}

const char * speechURLs[] = {
    // not able to leverage yahoo dictionary directly, legal issue
    // "http://tw.dictionary.search.yahoo.com/search?p=",
    "http://shtooka.net/search.php?lang=eng&str=",
    "http://cdict.net/?q=",
    ""
};

void SearchSpeech::startSearching() {
    if (m_WebCtrl.networkAccessible() != true){
        emit networkUnavailable();
        return;
    }
    m_urlList.clear();
    m_searchNo = 0;

    //http://www.oxfordlearnersdictionaries.com/
    //http://dictionary.cambridge.org/dictionary/english-chinese-traditional/geometric
    while(strcmp(speechURLs[m_searchNo],"")!=0) {
        m_WebCtrl.get(QNetworkRequest(speechURLs[m_searchNo] + m_searchKey));
        m_searchNo++;
    }
}

QString SearchSpeech::searchKey() const {
    return m_searchKey;
}

void SearchSpeech::setSearchKey(QString key){
    if(key != "") {
        if(m_searchKey == key) {
            emit searchCompleted();
        } else {
            m_searchKey = key;
            emit keyChanged();
        }
    }
}

QStringList SearchSpeech::urlList() const
{
    return m_urlList;
}

void SearchSpeech::accumulateResults() {
    m_mutex.lock();
    m_searchNo--;
    m_mutex.unlock();
    if (m_searchNo <= 0) {
        if (m_urlList.count()==0) m_downloadedData.clear();
        emit searchCompleted();
    }
}

QUrl SearchSpeech::targetSpeechUrl() const {
    return m_targetSpeechUrl;
}

void SearchSpeech::setTargetSpeechUrl(const QUrl target){
    if (m_WebCtrl.networkAccessible() != true){
        emit networkUnavailable();
    }
    else if(m_targetSpeechUrl == target) { emit downloadCompleted(); }
    else if (target.isEmpty() != true) {
        m_targetSpeechUrl = target;
        QNetworkRequest request(m_targetSpeechUrl);
        m_WebCtrl.get(request);
        emit targetChanged();
    }
}

QByteArray SearchSpeech::downloadedData() const {
    return m_downloadedData;
}

QByteArray* SearchSpeech::downloadedNetVendor() {
    return &m_downloadedData;
}

QUrl* SearchSpeech::downloadedUrlNetVendor() {
    return &m_targetSpeechUrl;
}
