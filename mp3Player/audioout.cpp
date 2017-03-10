#include "audioout.h"
#include <qDebug>

AudioOut::AudioOut()
    : m_pushTimer(new QTimer(this))
    , m_device(QAudioDeviceInfo::defaultOutputDevice())
    , m_audioOutput(0)
    , m_output(0)
    , m_feedings(0)
    , m_volumn(1)
{
}


void AudioOut::initializeAudio(QAudioFormat format, QIODevice *feedings)
{
    connect(m_pushTimer, SIGNAL(timeout()), SLOT(pushTimerExpired()));

    m_pullMode = true;

    m_format = format;
    m_feedings = feedings;

    QAudioDeviceInfo info(QAudioDeviceInfo::defaultOutputDevice());
    if (!info.isFormatSupported(m_format)) {
        qWarning() << "Reqeusting format not supported";
        //m_format = info.nearestFormat(m_format);
    } else {
        createAudioOutput();
    }
}

void AudioOut::createAudioOutput()
{
    delete m_audioOutput;
    m_audioOutput = 0;
    m_audioOutput = new QAudioOutput(m_device, m_format, this);
    m_audioOutput->setVolume(m_volumn);
    m_audioOutput->start(m_feedings);
}

AudioOut::~AudioOut()
{

}

void AudioOut::stop() {
    if(m_pushTimer!=NULL) { m_pushTimer->stop(); }
    if(m_audioOutput!=NULL) {
        //m_audioOutput->reset();
        m_audioOutput->stop();
        m_audioOutput->disconnect(this);
    }
}

void AudioOut::pause() {
    m_pushTimer->stop();
    m_audioOutput->suspend();
}

void AudioOut::deviceChanged(int index)
{
    stop();
    //m_device = m_deviceBox->itemData(index).value<QAudioDeviceInfo>();
    //createAudioOutput();
}

void AudioOut::volumeChange(int value)
{
    m_volumn = qreal(value/100.0f);
    if (m_audioOutput)
        m_audioOutput->setVolume(m_volumn);
}

void AudioOut::pushTimerExpired()
{
    if (m_audioOutput && m_audioOutput->state() != QAudio::StoppedState) {

    }
}

void AudioOut::toggleMode()
{
    m_pushTimer->stop();
    m_audioOutput->stop();

    if (m_pullMode) {
        //switch to push mode (periodically push to QAudioOutput using a timer)
        m_output = m_audioOutput->start();
        m_pullMode = false;
        m_pushTimer->start(20);
    } else {
        //switch to pull mode (QAudioOutput pulls from Generator as needed)
        m_pullMode = true;
        m_audioOutput->start(m_feedings);
    }
}

void AudioOut::toggleSuspendResume()
{
    if (m_audioOutput->state() == QAudio::SuspendedState) {
        m_audioOutput->resume();
    } else if (m_audioOutput->state() == QAudio::ActiveState) {
        m_audioOutput->suspend();
    } else if (m_audioOutput->state() == QAudio::StoppedState) {
        m_audioOutput->resume();
    } else if (m_audioOutput->state() == QAudio::IdleState) {
        // no-op
    }
}

