#include "imageScraper.h"
#include <QtDebug>
#include <Qbuffer>
#include <QFile>

ImageScraper::ImageScraper(): m_searchKey(""), m_urlResults(), m_tbResults() {
    connect(this, SIGNAL (downloaded()), this, SLOT (scrape()));
}

ImageScraper::~ImageScraper(){ }

void ImageScraper::setKeys(const QString &keys) {
    setKeyAndRange(keys, 1, 16, false);
}

void ImageScraper::setKeyAndRange(const QString & keys, int first, int number, bool forBiz = false){
    // bing starts from 1
    const QString binImageUrl = "https://www.bing.com/images/search?q=%1&qft=%2&FORM=HDRSC2&first=%3&count=%4";
    //const QString binImageUrl = "https://www.bing.com/images/search?q=%1&FORM=IBASEP&first=%2&count=%3";
    //const QString googleImageUrl = "https://www.google.com.tw/search?tbm=isch&q=";
    m_urlResults.clear();
    m_tbResults.clear();
    m_searchKey = keys;

    QString filter = forBiz ? "+filterui:license-L2_L3_L4" : "" ;

    setFileUrl(QUrl(binImageUrl.arg(m_searchKey, filter, QString::number(first+1), QString::number(number))));
}

QString extractUrl(QString &html) {
    // for google, QString start="imgurl=", end = "&amp;";
    // for bing
    const QString start1="<div class=\"fileInfo\">";
    // <div class=\"item\">
    // <a class=\"thumb\"
    const QString start2="href=\"";
    const QString end = "h=\"ID=images";

    int indexB = html.indexOf(start1);
    if(indexB<0) return "";
    html.remove(0, indexB+start1.length());
    indexB = html.indexOf(start2);
    html.remove(0, indexB+start2.length());
    int indexE = html.indexOf(end);
    if (indexE <0 ) return "";
    QString oneLink = html.mid(0, indexE);
    int quote = oneLink.lastIndexOf("\"");
    if (quote>0) { oneLink = oneLink.mid(0, quote); }
    html.remove(0, indexE+end.length());
    return oneLink;
}

QString extractTbUrl(QString &html) {
    const QString tbs = "src=\"";
    const QString tbe = "/>";
    const QString tbSemi = "&amp";

    int indexB = html.indexOf(tbs);
    html.remove(0, indexB+tbs.length());
    int indexE = html.indexOf(tbe);
    int indexE2 = html.indexOf(tbSemi);
    int endLength = tbe.length();
    if (indexE2>0 && indexE2<indexE) {
        indexE = indexE2;
        endLength = tbSemi.length();
    }
    QString tbLink = html.mid(0, indexE);
    html.remove(0, indexE+endLength);
    return tbLink;
}

void ImageScraper::scrape(){

    QString result = m_downloadedData;
//    static int i=0;
//    QString path("/Users/albus/Desktop/result%1.html");
//    QFile file(path.arg(i++));
//    file.open(QIODevice::WriteOnly);
//    file.write(m_downloadedData);
//    file.close();
    m_urlResults.clear();
    m_tbResults.clear();

    do {
        QString url = extractUrl(result);
        if (url=="") break;
        m_urlResults << url;
        m_tbResults << extractTbUrl(result);
    } while(1);
    scraped(m_urlResults, m_tbResults);
}

QString ImageScraper::keys() const {
    return m_searchKey;
}

