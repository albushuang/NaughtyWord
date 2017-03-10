#include "wordSpeaker.h"
#include <QBuffer>
#include <QAudioOutput>
#include <QtDebug>
#include <QFile>
#include <QFileInfo>

QObject* WordSpeaker::qWordSpeakerProvider(QQmlEngine *engine, QJSEngine *scriptEngine) {
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    return WordSpeaker::instance();
}

WordSpeaker* WordSpeaker::instance() {
    static WordSpeaker * pws = new WordSpeaker();
    return pws;
}

WordSpeaker::WordSpeaker(): m_playID(""), m_speechList(), m_mp3player(this), m_audioBuffer() {
    connect(this, SIGNAL (playIDChanged(QString)),
            this, SLOT (handlePlayIDChanged(QString)));
    m_autoPlay = false;
    m_validData = false;
}

WordSpeaker::~WordSpeaker() { }

QString WordSpeaker::playID() const {
    return m_playID;
}

bool WordSpeaker::autoPlay() const {
    return m_autoPlay;
}

void WordSpeaker::setVolume(int v) {
    m_mp3player.setVolumn(v);
}

void WordSpeaker::setSpeechData(QByteArray *pData, QString id) {
    putInMediaBox(*pData, id);
}

void WordSpeaker::setPlayID(const QString &id) {
    if (id != "") {
        m_playID = id;
        emit playIDChanged(m_playID);
    }
}

void WordSpeaker::setAutoPlay(const bool autoPlay) {
    m_autoPlay = autoPlay;
}

bool isMP3FileHeader(unsigned char *pbData) {
    if(pbData[0]!=0xff || (pbData[1] & 0xE0)!=0xE0) { // includes 0xFFF & 0xFFE
        if(pbData[0]!=0x49 || pbData[1]!=0x44) return false;
        else return true;
    }
    return true;
}

bool WordSpeaker::playFile(QString path) {
    QFile file(path);
    if(file.open(QIODevice::ReadOnly)) {
        m_audioBuffer = file.readAll();
        file.close();
        if(isMP3FileHeader((unsigned char*)m_audioBuffer.data())) {
            m_mp3player.setEncodedData(&m_audioBuffer);
            m_validData = true;
            play();
            return true;
        }
    }
    return false;
}


void WordSpeaker::handlePlayIDChanged(QString id) {
    for (int i=0;i < m_speechList.count(); i++) {
        if (m_speechList[i].id == id) {
            // mp3 player should handle invalid header
            if(isMP3FileHeader((unsigned char*)m_speechList[i].data.data())) {
                m_mp3player.setEncodedData(&m_speechList[i].data);
                m_validData = true;
                if(m_autoPlay) { play(); }
            }
            else { m_validData = false; }
            return;
        }
    }
    m_validData = false;
    // play according to new...
}

void WordSpeaker::readBuffer() {
}


void WordSpeaker::play() {
    if (m_validData)
        m_mp3player.play();
}

void WordSpeaker::stop() {
}

void WordSpeaker::pause() {
}

void WordSpeaker::releaseSpeechData(const QString &id) {
    removeFromMediaBox(id);
}

int WordSpeaker::putInMediaBox(QByteArray& data, const QString& id){
    for (int i=0;i<m_speechList.count(); i++) {
        if (m_speechList[i].id == id) return 1;
    }
    QByteArray speechData = data;
    DataMapping map = {id, speechData};
    m_speechList.append(map);
    return 0;
}

QByteArray* WordSpeaker::getFromMediaBox(const QString &id){
    for (int i=0;i<m_speechList.count(); i++) {
        if (m_speechList[i].id == id) { return &m_speechList[i].data; }
    }
    return NULL;
}

bool WordSpeaker::removeFromMediaBox(const QString& id){
    bool found = false;
    for (int i=0;i<m_speechList.count(); i++) {
        if (m_speechList[i].id == id) {
            m_speechList.removeAt(i);
            found = true;
        }
    }
    return found;
}
