#ifndef SDictLookUp_H
#define SDictLookUp_H

#include <QObject>
#include <QStringList>
#include <QStringListModel>
#include <QFile>

typedef struct index_t {
    QString word;
    quint64 offset;
    unsigned long size;
} sDictIndex;

typedef struct indexFound_t {
    char wordFound[20];
    unsigned long offset;
} indexOffset;

class SDictLookUp : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString searchKey READ searchKey WRITE setSearchKey)
    Q_PROPERTY(int maxResult READ maxResult WRITE setMaxResult)
    Q_PROPERTY(QStringList searchResult READ searchResult)
    Q_PROPERTY(bool moreResult READ moreResult WRITE setMoreResult)
    Q_PROPERTY(QString valid READ valid)

public:

    SDictLookUp(QObject *parent=0);
    ~SDictLookUp();

    QString searchKey() const;
    QStringList searchResult() const;

    void setSearchKey(const QString);
    bool setMoreResult(bool);
    int setMaxResult(int);
    int maxResult() const;
    bool moreResult();
    bool valid() const;

public Q_SLOTS:
    bool setDictPath(QString);

Q_SIGNALS:
    void searchDone();
    void startSearch();

private slots:
    void executeSearch();


private:
    QList<sDictIndex> scanWords(const unsigned char*, int);
    bool analyzeIFO();
    int sequentialSearch();
    QList<sDictIndex> seekIndex();

//    int binarySearchChinese();
//    void seekDictionaryFile2();

    QString m_dictPath;
    QFile m_ifo;
    QFile m_idx;
    QFile m_dict;

//    QString phoneticAlphabet(QByteArray);
//    QByteArray processWordType(QByteArray);

//    qint64 recursiveFind(qint64);
//    qint64 seekBack(qint64);
    QString m_searchKey;
    QString m_lastSeachKey;
    QStringList m_searchResult;

    int m_maxResult;
    int m_offset;
    int m_totalSize;
    QString m_sameType;
    QString m_dictName;
    qint64 m_fileLastPosition;
    qint64 m_lastKeyPosition;

    bool m_moreResult;
    bool m_advancingSearch;
    bool m_init;
};

#endif // SDictLookUp_H


