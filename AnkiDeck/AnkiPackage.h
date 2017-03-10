#ifndef ANKI_PACKAGE_H
#define ANKI_PACKAGE_H

#include <QObject>
#include <QtSql/QtSql>
#include <QSqlQuery>
#include <QtQml>
#include "SQLiteBasic.h"

class AnkiPackage : public SQLiteBasic
{
Q_OBJECT

    Q_PROPERTY(QJsonArray models READ models)
    Q_PROPERTY(QString basePath READ basePath)

    Q_ENUMS(CARD_FILTER)
    Q_ENUMS(CARD_ORDER)
public:
    AnkiPackage();
    ~AnkiPackage();
    QJsonArray models() const;

    enum CARD_FILTER {
        All,
        StatusNew,
        StatusLearning,
        StatusLearningDueNow,
        StatusReview,
        StatusReviewDueToday,
        StatusReviewAheadDays,
        StudyToday,
        StudyAll,
        Mastered
    };
    enum CARD_ORDER{
        None,
        Random,
        ASC,
        DESC
    };
    QString basePath() const;

public Q_SLOTS:
    static bool isAnkiPackage(QString path);

    int getRowCounts(CARD_FILTER, qint64);
    bool openPackage(QString path);
    void updateCard(QByteArray, QStringList);
    void pullInPractice(int);
    void clearHistory();
    QStringList browse(int);
    QString getCards(int, AnkiPackage::CARD_FILTER, AnkiPackage::CARD_ORDER, QString, qint64);
    QString getPicCards(int, AnkiPackage::CARD_FILTER, AnkiPackage::CARD_ORDER, QString, qint64);
    QString getDeckID();


Q_SIGNALS:

signals:

private slots:

private:
    QString jsonizeCards(QSqlQuery *p_query);
    QString getCards(QString);
    bool closePackage();
    QJsonArray m_objArray;
    QString m_ankiPath;
};

#endif // ANKI_PACKAGE_H


