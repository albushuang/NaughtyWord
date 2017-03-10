#ifndef GVQT_REWARDVIDEOAD_DUMMY_H
#define GVQT_REWARDVIDEOAD_DUMMY_H

#include "IGvQtRewardVideoAd.h"

class GvQtRewardVideoAdDummy : public IGvQtRewardVideoAd
{
public:
    GvQtRewardVideoAdDummy();
    virtual ~GvQtRewardVideoAdDummy();

    virtual void LoadWithUnitId(const QString& unitId);
    virtual bool IsLoaded() const;
    virtual void Show();

    virtual void AddTestDevice(const QString& hashedDeviceId);
};

#endif // GVQT_REWARDVIDEOAD_DUMMY_H
