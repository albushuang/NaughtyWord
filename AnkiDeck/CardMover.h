#ifndef CARD_MOVER_H
#define CARD_MOVER_H

#include <QObject>
#include <QtSql/QtSql>
#include <QSqlQuery>
#include <QtQml>
#include "mediaBox.h"
#include "internetvendor.h"
#include "SQLiteBasic.h"

class CardMover : public SQLiteBasic
{
Q_OBJECT

    Q_PROPERTY(QString basePath READ basePath WRITE setPathInfo)


public:
    CardMover();
    ~CardMover();

    void setPathInfo(QString);

public Q_SLOTS:

    QString basePath() const;
    int moveCard(QString source, QString target, qint64 id);
    int getRowCounts(QString database);


Q_SIGNALS:
    void moveDone(int);

signals:

private slots:

private:
    void vacuum(QSqlDatabase *m_pdb);
    void releaseDeck();
    QString m_deckInfoS;
    QString m_deckInfoT;
    QString m_dirInfo;
};

#endif // CARD_MOVER_H


