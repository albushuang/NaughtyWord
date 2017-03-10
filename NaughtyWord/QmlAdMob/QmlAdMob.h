#ifndef QML_ADMOB_H
#define QML_ADMOB_H

#include <QtQml>

class IQtAdMobBanner;
class IQtAdMobInterstitial;
class IGvQtRewardVideoAd;
//namespace Ui {
//class QmlAdMob;
//}

class QmlAdMob : public QObject
{
    Q_OBJECT

public:
    QmlAdMob();
    ~QmlAdMob();

public Q_SLOTS:
#ifdef ADMOB_BANNER_INTERSTITIAL
    void initBanner(QString unitId, QStringList deviceID);
    void initInterstitial(QStringList deviceID);
    void interstitialLoad(QString unitID);
    void interstitialShow();
    void bannerShow(int);
#endif

#ifdef NATIVE_REWARDED
    void initRewardedVideoAd(QStringList deviceID);
    void rewardedVideoAdLoad(QString unitID);
    void rewardedVideoAdShow();
#endif

Q_SIGNALS:
#ifdef ADMOB_BANNER_INTERSTITIAL
    void bannerLoading();
    void bannerLoaded();
    void interstitialLoaded();
    void interstitialLoading();
    void interstitialClosed();
#endif

#ifdef NATIVE_REWARDED
    void rewardedVideoAdLoaded();
    void rewardedVideoAdLoading();
    void rewardedVideoAdClosed();
    void rewardedVideoAdEnded();
    void rewarded(QString type, int amount);
#endif

protected:
    
private slots:
#ifdef ADMOB_BANNER_INTERSTITIAL
    void OnBannerLoaded();
    void OnBannerLoading();
    void OnInterstitialLoaded();
    void OnInterstitialLoading();
    void OnInterstitialClosed();
#endif

#ifdef NATIVE_REWARDED
    void OnRewardedVideoAdLoaded();
    void OnRewardedVideoAdLoading();
    void OnRewardedVideoAdClosed();
    void OnRewardedVideoAdEnded();
    void OnRewarded(QString, int);
#endif

private:
    //Ui::QmlAdMob *ui;

    IQtAdMobBanner* m_Banner;
    IQtAdMobInterstitial* m_Interstitial;
    IGvQtRewardVideoAd* m_rewardedVideoAd;

    bool m_Switch;
    int m_width;
};

#endif // QML_ADMOB_H
