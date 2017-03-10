#ifndef IGVQT_REWARDVIDEOAD_H
#define IGVQT_REWARDVIDEOAD_H

#include <QObject>
#include <QString>
#include <QSize>
#include <QPoint>

class IGvQtRewardVideoAd : public QObject
{
    Q_OBJECT
public:
    IGvQtRewardVideoAd() {}
    virtual ~IGvQtRewardVideoAd() {}

    virtual void LoadWithUnitId(const QString& unitId) = 0;
    virtual bool IsLoaded() const = 0;
    virtual void Show() = 0;

    virtual void AddTestDevice(const QString& hashedDeviceId) = 0;

signals:
    void OnLoaded();
    void OnLoading();
    void OnWillPresent();
    void OnClosed();
    void OnClicked();
    void OnStarted();
    void OnOpened();
    void OnVideoEnded();
    void OnObtained(QString, int);
};

#endif // IGVQT_REWARDVIDEOAD_H

