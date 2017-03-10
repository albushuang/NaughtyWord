#ifndef AUDIOOUT_H
#define AUDIOOUT_H

#include <math.h>
#include <QAudioOutput>
#include <QByteArray>
#include <QIODevice>
#include <QTimer>

class AudioOut : public QObject
{
    Q_OBJECT

public:
    AudioOut();
    ~AudioOut();
    void initializeAudio(QAudioFormat, QIODevice *);
    void stop();
    void pause();
    void volumeChange(int);

private:
    void createAudioOutput();

private:
    QTimer *m_pushTimer;

    QAudioDeviceInfo m_device;
    QAudioOutput *m_audioOutput;
    QIODevice *m_output; // not owned
    QIODevice *m_feedings; // also not owned
    QAudioFormat m_format;
    qreal m_volumn;

    bool m_pullMode;

private slots:
    void pushTimerExpired();
    void toggleMode();
    void toggleSuspendResume();
    void deviceChanged(int index);

};

#endif // AUDIOOUT_H

