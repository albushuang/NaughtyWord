#ifndef GVQT_REWARDVIDEOAD_IOS_H
#define GVQT_REWARDVIDEOAD_IOS_H

#include "IGvQtRewardVideoAd.h"

#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

class QAndroidJniObject;
#if defined(__OBJC__)
@class GvQtRewardVideoAdDelegate;
#endif

class GvQtRewardVideoAdIos : public IGvQtRewardVideoAd
{
    friend class GvQtRewardVideoAdDelegateIosProtected;
public:
    GvQtRewardVideoAdIos();
    virtual ~GvQtRewardVideoAdIos();

    virtual void LoadWithUnitId(const QString& unitId);
    virtual bool IsLoaded() const;
    virtual void Show();

    virtual void AddTestDevice(const QString& hashedDeviceId);

private:
    void OnStatusChanged(bool status);
    bool IsValid() const;

private:
#if defined(__OBJC__)
    GvQtRewardVideoAdDelegate* m_AdMob;
#endif
    bool m_IsNeedToShow;
    bool m_isLoaded;
};

#endif // TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR

#endif // GVQT_REWARDVIDEOAD_IOS_H
