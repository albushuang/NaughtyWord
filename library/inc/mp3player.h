#include "mpg123.h"
#include "audioout.h"
#include <QByteArray>
#include <QBuffer>

class Mp3Player : public QIODevice {

    Q_OBJECT

public:
    Mp3Player(QObject *parent);
    ~Mp3Player();
    int setEncodedData(QByteArray *);

    qint64 readData(char *data, qint64 maxlen);
    qint64 writeData(const char *data, qint64 len);
    qint64 bytesAvailable() const;

    friend ssize_t readBuf(void *, void *, size_t);
    friend off_t seekBuf(void *, off_t, int);

public slots:
    void stopAudioOutput();
    void setVolumn(int);
    int play();
    int stop();

private:
    int getFormat(QAudioFormat &);

    AudioOut m_audioOutput;
    mpg123_handle *m_mpgHandle;

    QByteArray m_encoded;
    off_t m_pos;
    int m_lastRead;
    //QByteArray *m_decoded;
};


