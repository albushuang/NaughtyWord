#ifndef DICTLOOKUP_H
#define DICTLOOKUP_H

#include <QObject>
#include <QStringList>
#include <QStringListModel>
#include <QFile>

class DictLookUp : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString searchKey READ searchKey WRITE setSearchKey)
    Q_PROPERTY(QString language READ language WRITE setLanguage)
    Q_PROPERTY(int maxResult READ maxResult WRITE setMaxResult)
    Q_PROPERTY(QStringList searchResult READ searchResult)
    Q_PROPERTY(bool moreResult READ moreResult WRITE setMoreResult)

public:

    DictLookUp(); // no parameter is allowed
    ~DictLookUp();

    QString searchKey() const;
    QStringList searchResult() const;

    void setSearchKey(const QString);
    void setLanguage(const QString);
    bool setMoreResult(bool);
    int setMaxResult(int);
    int maxResult() const;
    QString language() const;
    bool moreResult();

public Q_SLOTS:


Q_SIGNALS:
    void searchDone();
    void startSearch();

private slots:
    void executeSearch();


private:
    int sequentialSearch(QFile*);
    void seekDictionaryFile(QFile *);

    int binarySearchChinese();
    void seekDictionaryFile2();

    qint64 recursiveFind(qint64);
    qint64 seekBack(qint64);
    QString m_searchKey;
    QString m_lastSeachKey;
    QStringList m_searchResult;
    QFile m_file;
    QFile m_cfile;
    long m_searchValue;


    int m_maxResult;
    qint64 m_fileLastPosition;
    qint64 m_advancedSearchStart;
    bool m_moreResult;
    QString m_language;
};

#endif // DICTLOOKUP_H


