#include "./Mp3Player.h"
#include "audioout.h"
#include <QDebug>
#include <QByteArray>
#include <QFile>
#include <QTimer>

const int DECODE_BUFFER_SIZE = 64*1024;

Mp3Player::Mp3Player(QObject *parent) : QIODevice(parent), m_encoded(0)
{
    int result = mpg123_init();
    if(result != MPG123_OK) {
        qDebug() << "Cannot initialize mpg123 library:" << mpg123_plain_strerror(result);
    }
    m_mpgHandle = NULL;
    open(QIODevice::ReadOnly);
}

Mp3Player::~Mp3Player()
{
    mpg123_exit();
    close();
}

ssize_t readBuf(void *handle, void *buffer, size_t size) {
    if (handle == NULL) return -1;
    Mp3Player *player = (Mp3Player*)handle;

    //qDebug() << "readBuf:" << (qint64) &player->m_encoded << player->m_pos << size;
    if (player->m_pos+size > player->m_encoded.size()) {
        size = player->m_encoded.size()-player->m_pos;
    }
    memcpy(buffer, player->m_encoded.constData()+player->m_pos, size);
    player->m_pos += size;
    return size;
}

off_t seekBuf(void *handle, off_t offset, int position) {
    if (handle == NULL) return -1;
    off_t ret=0;
    Mp3Player *player = (Mp3Player*)handle;

    switch(position) {
    case SEEK_SET:
        if (offset < 0) ret = -1;
        else { player->m_pos = 0 + (offset > 0 ? offset : 0); ret = player->m_pos; }
        break;
    case SEEK_CUR:
        if (player->m_pos + offset < 0 || player->m_pos + offset > player->m_encoded.size()) ret = -1;
        else { player->m_pos += offset; ret = player->m_pos; }
        break;
    case SEEK_END:
        if (offset > 0) ret = -1;
        else { player->m_pos = player->m_encoded.size() + offset; ret = player->m_pos; }
        break;
    }
    return ret;
}

int Mp3Player::setEncodedData(QByteArray *buffer) {
    m_encoded = *buffer;
    return 0;
}

int Mp3Player::getFormat(QAudioFormat &format) {
    long iFrameRate=0;
    int encoding=0, iChannels=0, mc;
    int iBytesPerChannel = 0;

    off_t m_framenum;
    size_t bytes;
    unsigned char *audio;

    mc = mpg123_decode_frame(m_mpgHandle, &m_framenum, &audio, &bytes);

    if(mc != MPG123_OK) {
        if(mc == MPG123_ERR) { qWarning() << "error in format"; return -1; }
        if(mc == MPG123_NO_SPACE) { qWarning() << "no space"; return -1; }
        if(mc == MPG123_NEW_FORMAT) {
            mpg123_getformat(m_mpgHandle, &iFrameRate, &iChannels, &encoding);
            iBytesPerChannel = mpg123_encsize(encoding);
            if (iBytesPerChannel == 0) qFatal("bytes per channel is 0 !!");
            //qWarning() << "new format in format" << iFrameRate << iChannels << iBytesPerChannel;
            format.setSampleRate(iFrameRate);
            format.setChannelCount(iChannels);
            format.setSampleSize(iBytesPerChannel*8);
            format.setCodec("audio/pcm");
            format.setByteOrder(QAudioFormat::LittleEndian);
            format.setSampleType(QAudioFormat::SignedInt);
        }
    }
    return 0;
}

int Mp3Player::stop() {
    stopAudioOutput();
    if (m_mpgHandle!=NULL) mpg123_close(m_mpgHandle);
    m_mpgHandle = NULL;
    return 0;
}

int Mp3Player::play() {
    stop();

    m_mpgHandle = mpg123_new(NULL, NULL);
    m_pos = 0;
    mpg123_replace_reader_handle(m_mpgHandle, &::readBuf, &::seekBuf, NULL);
    if(mpg123_open_handle(m_mpgHandle, this) != MPG123_OK) {
        qWarning() << "Cannot open mp3 handle";
        return -1;
    }

    QAudioFormat format;
    int mp3file = getFormat(format);
    if (mp3file==0) { m_audioOutput.initializeAudio(format, this); }
    else { close(); }

    return mp3file;
}

void Mp3Player::stopAudioOutput() {
    m_audioOutput.stop();
}

void Mp3Player::setVolumn(int v) {
    int volumn = v < 0 ? 0 : (v > 100? 100 : v);
    m_audioOutput.volumeChange(volumn);
}

qint64 Mp3Player::readData(char *data, qint64 len)
{
    unsigned char *audio;
    off_t m_framenum;
    size_t bytes;
    int mc = mpg123_decode_frame(m_mpgHandle, &m_framenum, &audio, &bytes);
    if(mc != MPG123_OK)
    {
        if(mc == MPG123_ERR) qWarning() << "error in read data";
        if(mc == MPG123_NO_SPACE) qWarning() << "no space";
        if(mc == MPG123_NEW_FORMAT)  qWarning() << "new format!!";
    }
    int small = len > bytes? bytes : len;
    memcpy(data, audio, small);

    if(bytes==0 && m_lastRead==0) {
        // call stop after some deplay....
        stop();
    }
    m_lastRead = bytes;
    return (qint64)small;
}

qint64 Mp3Player::writeData(const char *data, qint64 len)
{
    Q_UNUSED(data);
    Q_UNUSED(len);

    return 0;
}

qint64 Mp3Player::bytesAvailable() const
{
    return QIODevice::bytesAvailable();
}
