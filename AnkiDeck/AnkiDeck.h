#ifndef ANKI_DECK_H
#define ANKI_DECK_H

#include <QObject>
#include <QtSql/QtSql>
#include <QSqlQuery>
#include <QtQml>
#include "mediaBox.h"
#include "internetvendor.h"
#include "SQLiteBasic.h"

class AnkiDeck : public SQLiteBasic
{
Q_OBJECT

    Q_PROPERTY(QString deckInfo READ deckInfo WRITE setDeckInfo)
    Q_PROPERTY(QString basePath READ basePath WRITE setPathInfo)

    Q_ENUMS(CARD_FILTER)
    Q_ENUMS(CARD_ORDER)

public:
    static AnkiDeck** instance();
    static QObject* qAnkiDeckProvider(QQmlEngine *engine, QJSEngine *scriptEngine);
    QString jsonizeCards(QSqlQuery*);

    enum CARD_FILTER {
        All=1,
        StatusNew=2,
        StatusLearning=4,
        StatusLearningDueNow=8,
        StatusReview=16,
        StatusReviewDueToday=32,
        StatusReviewAheadDays=64,
        StudyToday=128,
        StudyAll=256,
        Mastered=512,
        RowRange=1024
    };
    enum CARD_ORDER{
        None,
        Random,
        ASC,
        DESC
    };

    void setDeckInfo(QString deckInfo);
    void setPathInfo(QString);
    QString deckInfo() const;

public Q_SLOTS:
    void setReturnFields(QStringList);
    void checkAndFixSqlField();
    void addCard(QByteArray, NetVendor *, NetVendor *, bool forced=false);
    void addOrReplace(QByteArray, NetVendor *, NetVendor *);
    //void releaseCard(QByteArray);
    void releaseCard(QString);
    void updateCard(QByteArray , QStringList, NetVendor *, NetVendor *, bool waitingBlock = true);
    void updateCardAsync(QByteArray , QStringList, NetVendor *, NetVendor *);
    void removeCard(QString);
    void clearHistory();
    qint64 getRowCounts(CARD_FILTER filter, qint64 aheadDays);
    QString browse(int);
    QString getCards(int, CARD_FILTER, CARD_ORDER, QString, qint64, qint64, qint64);
    QString getCards(QString);
    QString getCardsByIds(QVariantList);
    QString prepareGetCardString(int, CARD_FILTER, CARD_ORDER, QString, qint64, qint64, qint64);
    QString getSqlFilterStr(CARD_FILTER, CARD_ORDER, QString, qint64, qint64, qint64);
    void getCardsAsync(int no, CARD_FILTER filter=AnkiDeck::All, CARD_ORDER order=AnkiDeck::Random,
                       QString orderTarget="", qint64 aheadDays = 0, qint64 rangeStart = 1, qint64 rangeEnd = 99999);
    void getCardsAsync(QString);
    QString getDeckID();
    QString basePath() const;
    void newDeck(QString);
    void releaseDeck();
    void setImageVendor (MediaBox*);
    void setWordSpeaker (MediaBox*);
    void handleQueryResults(QSqlQuery*, quint64);
    QStringList getAllWords();
    void makeUnique();

    static QString fourAM(qint64);
    static QString now();

Q_SIGNALS:
    void cardsReady(QString);
    void pathReady();

signals:

private slots:

private:
    AnkiDeck(); // no parameter is allowed
    ~AnkiDeck();
    Q_DISABLE_COPY(AnkiDeck)

    void addColumnField(qint64 index);
    qint64 exist(QString);
    //QThread slowThread;
    void openDatabase(QString);    
    void releaseResource(QString);
    void removeRecord(QString, QString);
    void vacuum(QSqlDatabase*);
    MediaBox *m_pImageVendor;
    MediaBox *m_pWordSpeaker;

    QString m_deckInfo;
    QString m_dirInfo;
    QString m_root;
    QString m_fields;
};

#endif // ANKI_DECK_H


