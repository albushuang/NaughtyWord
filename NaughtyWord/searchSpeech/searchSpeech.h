#ifndef SearchSpeech_H
#define SearchSpeech_H

#include <QObject>
#include <QByteArray>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QMutex>
#include "internetvendor.h"

class SearchSpeech :  public NetVendor {

    Q_OBJECT

    Q_PROPERTY(QUrl targetSpeechUrl READ targetSpeechUrl WRITE setTargetSpeechUrl NOTIFY targetChanged)
    Q_PROPERTY(QString searchKey READ searchKey WRITE setSearchKey NOTIFY keyChanged)
    Q_PROPERTY(QStringList urlList READ urlList)
    Q_PROPERTY(QString downloadedData READ downloadedData)

public:
    SearchSpeech(); // no parameter is allowed
    ~SearchSpeech();

    QString searchKey() const;
    QStringList urlList() const;
    QUrl targetSpeechUrl() const;
    QByteArray downloadedData() const;

//PRAGMA: NetVendor protocol
    virtual QByteArray *downloadedNetVendor();
    virtual QUrl * downloadedUrlNetVendor();

public Q_SLOTS:
    void setSearchKey(const QString);
    void setTargetSpeechUrl(const QUrl);
    SearchSpeech *self() { return this; }

Q_SIGNALS:
    void searchCompleted();
    void downloadCompleted();
    void networkUnavailable();

signals:
    void keyChanged();
    void targetChanged();
    void oneSearchDone();

private slots:
    void pageDownloaded(QNetworkReply* pReply);
    void startSearching();
    void accumulateResults();

private:
    void analyzePage();
    void extractString(QString target);
    void getShtooka();
    void getYahoo();

    QNetworkAccessManager m_WebCtrl;
    QByteArray m_downloadedData;
    QString m_searchKey;
    QUrl m_targetSpeechUrl;
    QStringList m_urlList;
    QMutex m_mutex;
    int m_searchNo;
};

#endif // SearchSpeech_H


