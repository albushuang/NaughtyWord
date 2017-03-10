#ifndef IMAGE_SCRAPER_H
#define IMAGE_SCRAPER_H

#include <QStringList>
#include "filedownloader.h"

class ImageScraper: public FileDownloader{

Q_OBJECT
    Q_PROPERTY(QString keys READ keys WRITE setKeys)

public:
    ImageScraper();
    ~ImageScraper();

    QString keys() const;

public Q_SLOTS:
    void setKeys(const QString &);
    void setKeyAndRange(const QString &, int, int, bool);

Q_SIGNALS:
    void scraped(QStringList urls, QStringList tbUrls);

private slots:
    void scrape();

signals:

private:
    QString m_searchKey;
    QStringList m_urlResults;
    QStringList m_tbResults;
};


#endif // IMAGE_SCRAPER_H

