#include <QPoint>
#include "QmlAdMob.h"

#ifdef ADMOB_BANNER_INTERSTITIAL
#include "../QtAdMob/QtAdMobBanner.h"
#include "../QtAdMob/QtAdMobInterstitial.h"
#endif

#ifdef NATIVE_REWARDED
#include "../GvQtRewardVideoAd/GvQtRewardVideoAd.h"
#endif


QmlAdMob::QmlAdMob():
    m_Banner(NULL), m_Interstitial(NULL),
    m_rewardedVideoAd(NULL), m_Switch(false) { }

QmlAdMob::~QmlAdMob()
{
    if(m_Banner != NULL) { delete m_Banner; }
    if(m_Interstitial != NULL) { delete m_Interstitial; }
    if(m_rewardedVideoAd != NULL) { delete m_rewardedVideoAd; }
}


#ifdef ADMOB_BANNER_INTERSTITIAL
// ASUS Zen phone ID:"EE0245F83FA1891151FEF2EC4CF7C993"
void QmlAdMob::initBanner(QString unitId, QStringList deviceIDs) {
    m_Banner = CreateQtAdMobBanner();
    m_Banner->Initialize();
    m_Banner->SetUnitId(unitId);
    m_Banner->SetSize(IQtAdMobBanner::Banner);
    for(int i=0;i<deviceIDs.length();i++) { m_Banner->AddTestDevice(deviceIDs[i]); }


    connect(m_Banner, SIGNAL(OnLoaded()), this, SLOT(OnBannerLoaded()));
    connect(m_Banner, SIGNAL(OnLoading()), this, SLOT(OnBannerLoading()));
}

void QmlAdMob::bannerShow(int width)
{
    bool isShowed = m_Banner->IsShow();
    m_width = width;
    if (!isShowed) { m_Banner->Show(); }
    else { m_Banner->Hide(); }
}

void QmlAdMob::OnBannerLoaded()
{
    QPoint position((m_width - m_Banner->GetSizeInPixels().width()) * 0.5f, 0.0f);
    m_Banner->SetPosition(position);
    emit bannerLoaded();
}

void QmlAdMob::OnBannerLoading()
{
    emit bannerLoading();
}

// ASUS Zen phone ID:"EE0245F83FA1891151FEF2EC4CF7C993"
void QmlAdMob::initInterstitial(QStringList deviceIDs) {
    m_Interstitial = CreateQtAdMobInterstitial();
    for(int i=0;i<deviceIDs.length();i++) { m_Interstitial->AddTestDevice(deviceIDs[i]); }

    connect(m_Interstitial, SIGNAL(OnLoaded()), this, SLOT(OnInterstitialLoaded()));
    connect(m_Interstitial, SIGNAL(OnLoading()), this, SLOT(OnInterstitialLoading()));
    connect(m_Interstitial, SIGNAL(OnClosed()), this, SLOT(OnInterstitialClosed()));
}

void QmlAdMob::interstitialLoad(QString uintId)
{
    m_Interstitial->LoadWithUnitId(uintId);
}

void QmlAdMob::interstitialShow()
{
    m_Interstitial->Show();
}

void QmlAdMob::OnInterstitialLoaded()
{
    emit interstitialLoaded();
}

void QmlAdMob::OnInterstitialLoading()
{
    emit interstitialLoading();
}

void QmlAdMob::OnInterstitialClosed()
{
    emit interstitialClosed();
}
#endif

#ifdef NATIVE_REWARDED
void QmlAdMob::initRewardedVideoAd(QStringList deviceIDs)
{
    m_rewardedVideoAd = CreateGvQtRewardVideoAd();
    for(int i=0;i<deviceIDs.length();i++) { m_rewardedVideoAd->AddTestDevice(deviceIDs[i]); }

    connect(m_rewardedVideoAd, SIGNAL(OnLoaded()), this, SLOT(OnRewardedVideoAdLoaded()));
    connect(m_rewardedVideoAd, SIGNAL(OnLoading()), this, SLOT(OnRewardedVideoAdLoading()));
    connect(m_rewardedVideoAd, SIGNAL(OnClosed()), this, SLOT(OnRewardedVideoAdClosed()));
    connect(m_rewardedVideoAd, SIGNAL(OnVideoEnded()), this, SLOT(OnRewardedVideoAdEnded()));
    connect(m_rewardedVideoAd, SIGNAL(OnObtained(QString, int)), this, SLOT(OnRewarded(QString, int)));
}


void QmlAdMob::rewardedVideoAdLoad(QString unitID){
    m_rewardedVideoAd->LoadWithUnitId(unitID);
}

void QmlAdMob::rewardedVideoAdShow(){
    if (m_rewardedVideoAd->IsLoaded()) {
        m_rewardedVideoAd->Show();
    }
}

void QmlAdMob::OnRewarded(QString type, int amount)
{
    emit rewarded(type, amount);
}

void QmlAdMob::OnRewardedVideoAdLoaded()
{
    emit rewardedVideoAdLoaded();
}

void QmlAdMob::OnRewardedVideoAdLoading()
{
    emit rewardedVideoAdLoading();
}

void QmlAdMob::OnRewardedVideoAdEnded()
{
    emit rewardedVideoAdEnded();
}


void QmlAdMob::OnRewardedVideoAdClosed()
{
    emit rewardedVideoAdClosed();
}

#endif
