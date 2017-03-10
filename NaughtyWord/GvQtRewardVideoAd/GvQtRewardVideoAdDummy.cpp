#include "GvQtRewardVideoAdDummy.h"
#include "IQtAdMobBanner.h"

GvQtRewardVideoAdDummy::GvQtRewardVideoAdDummy()
{
}

GvQtRewardVideoAdDummy::~GvQtRewardVideoAdDummy()
{
}

void GvQtRewardVideoAdDummy::LoadWithUnitId(const QString& unitId)
{
    Q_UNUSED(unitId);
}

bool GvQtRewardVideoAdDummy::IsLoaded() const
{
    return false;
}

void GvQtRewardVideoAdDummy::Show()
{    
}

void GvQtRewardVideoAdDummy::AddTestDevice(const QString& hashedDeviceId)
{
    Q_UNUSED(hashedDeviceId);
}
