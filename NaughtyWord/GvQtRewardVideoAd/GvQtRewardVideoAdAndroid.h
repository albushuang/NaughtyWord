#ifndef GVQT_REWARDVIDEOAD_ANDROID_H
#define GVQT_REWARDVIDEOAD_ANDROID_H

#include "IGvQtRewardVideoAd.h"

#if (__ANDROID_API__ >= 9)

class QAndroidJniObject;

class GvQtRewardVideoAdAndroid : public IGvQtRewardVideoAd
{
public:
    typedef QMap<uint32_t, GvQtRewardVideoAdAndroid*> TInstances;

    GvQtRewardVideoAdAndroid();
    virtual ~GvQtRewardVideoAdAndroid();

    virtual void LoadWithUnitId(const QString& unitId);
    virtual bool IsLoaded() const;
    virtual void Show();

    virtual void AddTestDevice(const QString& hashedDeviceId);
    
    static const TInstances& Instances();

private:
    bool IsValid() const;

private:
    QAndroidJniObject* m_Activity;
    int m_Index;
    static int s_Index;
    static TInstances s_Instances;
};

#endif // __ANDROID_API__

#endif // GVQT_REWARDVIDEOAD_ANDROID_H
