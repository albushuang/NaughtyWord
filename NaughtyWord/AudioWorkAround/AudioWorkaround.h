#ifndef AUDIO_WORKAROUND_H
#define AUDIO_WORKAROUND_H

#include <QObject>
#include <QList>

typedef struct _ResPair {
    QString id;
    QString oPath;
    QString nPath;
} ResPair;

class AudioWorkaround : public QObject
{
Q_OBJECT

public:

    AudioWorkaround();
    ~AudioWorkaround();

public Q_SLOTS:
    QStringList makeResource(QString id, QString content, QString path);
    QStringList makeResourceReady(QString id, QString content, QString path);
    int releaseResource(QString id);
protected:

Q_SIGNALS:


signals:


private slots:


private:
    QList<ResPair> m_resList;
};

#endif //AUDIO_WORKAROUND_H
