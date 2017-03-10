#ifndef AnkiTranslator_H
#define AnkiTranslator_H

#include <QObject>
#include <QMap>
#include "AnkiDeck.h"
#include "AnkiPackage.h"

class AnkiTranslator: public QObject
{
Q_OBJECT

public:
    AnkiTranslator();
    ~AnkiTranslator();

public Q_SLOTS:
    QString toKMRJJSON(QString json, QJsonArray, bool);
    QString toAnkiJSON(QString json);
    QString toAnkiQuery(QString);
    QString toKMRJQuery(QString);
    int toAnkiFilter(int);
    int toAnkiOrder(int);
    QString toAnkiField(QString);
    QString toKMRJField(QString);

Q_SIGNALS:

signals:

private slots:

private:
    QMap<QString, QString> m_k2a;
};

#endif // AnkiTranslator_H


