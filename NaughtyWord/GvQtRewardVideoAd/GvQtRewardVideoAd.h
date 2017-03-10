#ifndef GVQT_REWARDVIDEOAD_H
#define GVQT_REWARDVIDEOAD_H

#include "GvQtRewardVideoAdAndroid.h"
#include "GvQtRewardVideoAdDummy.h"
#include "GvQtRewardVideoAdIos.h"

inline IGvQtRewardVideoAd* CreateGvQtRewardVideoAd()
{
#if (__ANDROID_API__ >= 9)
    return new GvQtRewardVideoAdAndroid();
#elif (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
    return new GvQtRewardVideoAdIos();
#else
    return new GvQtRewardVideoAdDummy();
#endif
}

#endif // GVQT_REWARDVIDEOAD_H

