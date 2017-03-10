#include "tsConvert.h"
#include <QDebug>


TSConvert::TSConvert() : m_tArray(), m_sArray() { }

TSConvert::~TSConvert() { }


void TSConvert::setTables(QString tA, QString sA) {
    m_tArray = tA;
    m_sArray = sA;
}

QString TSConvert::tArray() const {
    return m_tArray;
}

QString TSConvert::sArray() const {
    return m_sArray;
}

void TSConvert::setTArray(QString tA) {
    m_tArray = tA;
}

void TSConvert::setSArray(QString sA) {
    m_sArray = sA;
}

QString TSConvert::toTraditional(QString cc) {
    QString str;
    for(int i = 0 ; i < cc.length() ; i++ )
    {
        int index = m_sArray.indexOf(cc[i]);
        if( index != -1 )
            str += m_tArray[index];
        else
            str += cc[i];
    }
    return str;
}

QString TSConvert::toSimplified(QString cc) {
    QString str;
    for(int i = 0 ; i < cc.length() ; i++ )
    {
        int index = m_tArray.indexOf(cc[i]);
        if( index != -1 )
            str += m_sArray[index];
        else
            str += cc[i];
    }
    return str;
}

void removeBetweenSymbols(QString &target, QString b, QString e) {
    do {
        int bi = target.indexOf(b);
        if(bi<0) break;
        int ei = target.indexOf(e, bi);
        target = target.remove(bi, ei-bi+1);
    } while(1);
}

QString TSConvert::handleParentheses(QString target) {
    QString ret = target.replace("(某人)", "...");
    ret = ret.replace("（某人）", "...");
    removeBetweenSymbols(ret, "(", ")");
    removeBetweenSymbols(ret, "（", "）");
    //qDebug() << "final" << ret.toStdString().c_str();
    return ret;
}
