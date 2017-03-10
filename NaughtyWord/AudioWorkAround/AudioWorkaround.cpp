
#include <qDebug>
#include "AudioWorkaround.h"
#include <QFile>

AudioWorkaround::AudioWorkaround(): m_resList() { }


void releaseAll(QList<ResPair> & list) {
    for(int i=0;i<list.count(); i++) {
        QFile::rename(list[i].nPath, list[i].oPath);
    }
    list.erase(list.begin(), list.end());
}

AudioWorkaround::~AudioWorkaround() {
    releaseAll(m_resList);
}

QString extract(QString source, QString start, QString end, QString & type, int &from, bool toExtract) {
    QString info=source;
    if(toExtract) {
        int s = source.indexOf(start, from);
        int e = source.indexOf(end, s+start.length());
        from = e + end.length();
        if(s<0) return QString();
        info = source.mid(s+start.length(), e-s-start.length());
    }
    else if(from !=0 ) { return ""; }
    else { from = source.length(); }

    QStringList files = info.split("##");
    QStringList names = files[0].split(".");
    type = names[names.length()-1];
    return files[1];
}

QStringList workAround(QList<ResPair>& slist, QString id, QString content, QString path, bool toExtract) {
    if(!path.endsWith("/")) path += "/";
    int from = 0;
    QStringList list;
    do {
        QString ext;
        QString res = extract(content, "[sound:", "]", ext, from, toExtract);
        if (res.isEmpty()) break;
        ResPair pair;
        pair.id = id;
        pair.oPath = path+res;
        pair.nPath = path+res+"."+ext;
        slist.append(pair);
        if (!QFile::rename(pair.oPath, pair.nPath)) {
            qWarning() << "unable to workaround!" << pair.oPath << pair.nPath;
        }
        list.append(pair.nPath);
    } while(1);
    return list;
}

QStringList AudioWorkaround::makeResource(QString id, QString content, QString path){
    return workAround(m_resList, id, content, path, true);
}

QStringList AudioWorkaround::makeResourceReady(QString id, QString content, QString path){
    return workAround(m_resList, id, content, path, false);
}

int AudioWorkaround::releaseResource(QString id) {
    int no = 0;
    for(int i=m_resList.count()-1;i>=0; i--) {
        if(m_resList[i].id==id) {
            QFile::rename(m_resList[i].nPath, m_resList[i].oPath);
            m_resList.removeAt(i);
            no++;
        }
    }
    return no;
}
