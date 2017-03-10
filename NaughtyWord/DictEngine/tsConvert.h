#ifndef TSConvert_H
#define TSConvert_H

#include <QObject>
#include <QByteArray>

class TSConvert : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString tArray READ tArray WRITE setTArray)
    Q_PROPERTY(QString sArray READ sArray WRITE setSArray)

public:

    TSConvert(); // no parameter is allowed
    ~TSConvert();
    QString tArray() const;
    QString sArray() const;
    void setTArray(QString);
    void setSArray(QString);

public Q_SLOTS:
    void setTables(QString tTable, QString sTable);
    QString toTraditional(QString);
    QString toSimplified(QString);
    QString handleParentheses(QString);

Q_SIGNALS:


private slots:


private:
    QString m_tArray, m_sArray;
};

#endif // TSConvert_H


