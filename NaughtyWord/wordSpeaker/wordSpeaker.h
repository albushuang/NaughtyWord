#ifndef WORD_SPEAKER_H
#define WORD_SPEAKER_H

#include <QObject>
#include <QByteArray>
#include <QBuffer>
#include <QtQml>
#include "mp3Player.h"
#include "../headers/vendors.h"
#include "mediaBox.h"

class WordSpeaker : public MediaBox
{
    Q_OBJECT

    Q_PROPERTY(QString playID READ playID WRITE setPlayID NOTIFY playIDChanged)
    Q_PROPERTY(bool autoPlay READ autoPlay WRITE setAutoPlay)

public:
    static WordSpeaker* instance();

    static QObject* qWordSpeakerProvider(QQmlEngine *engine, QJSEngine *scriptEngine);

    QString playID() const;
    bool autoPlay() const;
    void setSpeechData(QByteArray *pData, QString id);
    void releaseSpeechData(const QString &);

    //PRAGMA: protocol MediaBox
    virtual int putInMediaBox(QByteArray&, const QString &);
    virtual bool removeFromMediaBox(const QString &);
    virtual QByteArray* getFromMediaBox(const QString &id);


public Q_SLOTS:
    bool playFile(QString);
    void setPlayID(const QString &);
    void setAutoPlay(const bool);
    void play();
    void stop();
    void pause();
    void setVolume(int);

Q_SIGNALS:
//signals:
    void playIDChanged(QString);
    void speechReady();

private slots:
    void handlePlayIDChanged(QString);
    void readBuffer();

private:
    WordSpeaker(); // no parameter is allowed
    ~WordSpeaker();
    Q_DISABLE_COPY(WordSpeaker)

    QString m_playID;
    QList<DataMapping> m_speechList;
    Mp3Player m_mp3player;
    bool m_autoPlay;
    bool m_validData;
    QByteArray m_audioBuffer;
};

#endif // WORD_SPEAKER_H


