#include "GvQtRewardVideoAdIos.h"
#include <QDebug>

#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

#include <GoogleMobileAds/GADRequest.h>
#include <GoogleMobileAds/GADRewardBasedVideoAd.h>
#include <GoogleMobileAds/GADRewardBasedVideoAdDelegate.h>

class GvQtRewardVideoAdDelegateIosProtected
{
public:
    GvQtRewardVideoAdDelegateIosProtected() {};
    ~GvQtRewardVideoAdDelegateIosProtected() {};

    static void OnLoaded(GvQtRewardVideoAdIos* handler, bool status)
    {
        if (!handler)
        {
            return;
        }

        handler->OnStatusChanged(status);
    }

    static void OnLoading(GvQtRewardVideoAdIos* handler)
    {
        if (!handler)
        {
            return;
        }

        handler->OnLoading();
    }

    static void OnWillPresent(GvQtRewardVideoAdIos* handler)
    {
        if (!handler)
        {
            return;
        }

        handler->OnWillPresent();
    }

    static void OnClosed(GvQtRewardVideoAdIos* handler)
    {
        if (!handler)
        {
            return;
        }

        handler->OnClosed();
    }
    static void onObtained(GvQtRewardVideoAdIos* handler, const char* type, int amount) {
        if (!handler)
        {
            return;
        }

        handler->OnObtained(QString(type), amount);
    }
};

@interface GvQtRewardVideoAdDelegate : NSObject<GADRewardBasedVideoAdDelegate>

//@property (nonatomic, strong) GADInterstitial* interstitial;
@property (nonatomic, strong) NSMutableArray* testDevices;
@property (nonatomic, assign) GvQtRewardVideoAdIos *handler;
@property(nonatomic, assign) bool isAdLoaded;

- (id)initWithHandler:(GvQtRewardVideoAdIos *)handler;

- (void)load:(NSString *)adUnitId;;

@end

@implementation GvQtRewardVideoAdDelegate

- (id)initWithHandler:(GvQtRewardVideoAdIos *)handler
{
    self = [super init];
    if (self)
    {
        _handler = handler;
        _testDevices = [[NSMutableArray alloc] init];
        //_testDevices = [[NSMutableArray alloc] initWithArray:@[kGADSimulatorID]];
    }
    return self;
}

- (void)dealloc
{
    //_interstitial.delegate = nil;
    _handler = nullptr;
}

- (void)load:(NSString *)adUnitId;
{
//    GADRequest *request = [GADRequest request];
//    request.testDevices = _testDevices;
//    [_interstitial loadRequest:request];

    GADRequest *request = [GADRequest request];
    request.testDevices = _testDevices;
    [[GADRewardBasedVideoAd sharedInstance] loadRequest:request
                                           withAdUnitID:adUnitId];
                                           //userID: @"user"];
//    [[GADRewardBasedVideoAd sharedInstance] loadRequest:request withAdUnitID:@"ca-app-pub-1482264930793932/1066119608"];
//    [[GADRewardBasedVideoAd sharedInstance] loadRequest:request]
//                                           withAdUnitID:@"ca-app-pub-1482264930793932/1066119608"];
    self.isAdLoaded = false;
    GvQtRewardVideoAdDelegateIosProtected::OnLoading(self.handler);
}

- (void)show
{
    qDebug() << "running .... show";
    UIApplication *application = [UIApplication sharedApplication];
    UIWindow *window = [[application windows] firstObject];
    UIViewController* rootViewController = [window rootViewController];
    
    if ([[GADRewardBasedVideoAd sharedInstance] isReady]) {
        [[GADRewardBasedVideoAd sharedInstance] presentFromRootViewController:rootViewController];
      }
    //[_interstitial presentFromRootViewController:rootViewController];
}

//- (void)interstitialDidReceiveAd:(GADInterstitial *)ad
//{
//    Q_UNUSED(ad);

//    QtAdMobInterstitialIosProtected::OnLoaded(self.handler, true);
//}

//- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error
//{
//    Q_UNUSED(ad);
//    Q_UNUSED(error);
    
//    QtAdMobInterstitialIosProtected::OnLoaded(self.handler, false);
//}

//- (void)interstitialWillPresentScreen:(GADInterstitial *)ad
//{
//    Q_UNUSED(ad);
//    QtAdMobInterstitialIosProtected::OnWillPresent(self.handler);
//}

//- (void)interstitialDidDismissScreen:(GADInterstitial *)ad
//{
//    Q_UNUSED(ad);
//    QtAdMobInterstitialIosProtected::OnClosed(self.handler);
//}

- (void)rewardBasedVideoAdDidReceiveAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
  self.isAdLoaded = true;
  GvQtRewardVideoAdDelegateIosProtected::OnLoaded(self.handler, true);
  qDebug() << "Loaded ... emitted";
  //self.rewardBasedVideoRequestLoading = NO;
  NSLog(@"Reward based video ad is received.");
}

- (void)rewardBasedVideoAdDidOpen:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
  NSLog(@"Opened reward based video ad.");
}

- (void)rewardBasedVideoAdDidStartPlaying:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
  NSLog(@"Reward based video ad started playing.");
}

- (void)rewardBasedVideoAdDidClose:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
  NSLog(@"Reward based video ad is closed.");
  GvQtRewardVideoAdDelegateIosProtected::OnClosed(self.handler);
  //self.showVideoButton.hidden = YES;
}

- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd
    didRewardUserWithReward:(GADAdReward *)reward {
  NSString *rewardMessage =
      [NSString stringWithFormat:@"Reward received with currency %@ , amount %lf", reward.type,
                                 [reward.amount doubleValue]];
  GvQtRewardVideoAdDelegateIosProtected::onObtained(self.handler, [reward.type UTF8String], [reward.amount integerValue]);
  NSLog(@"%@", rewardMessage);
  // Reward the user for watching the video.
//  [self earnCoins:[reward.amount integerValue]];
//  self.showVideoButton.hidden = YES;
}

- (void)rewardBasedVideoAdWillLeaveApplication:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
  NSLog(@"Reward based video ad will leave application.");
}

- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd
    didFailToLoadWithError:(NSError *)error {
  GvQtRewardVideoAdDelegateIosProtected::OnLoaded(self.handler, false);
  //self.rewardBasedVideoRequestLoading = NO;
  NSLog(@"Reward based video ad failed to load.");
}


@end

GvQtRewardVideoAdIos::GvQtRewardVideoAdIos()
    : m_AdMob(NULL)
    , m_IsNeedToShow(false)
{
    qDebug() << "objc:.....";
    m_AdMob = [[GvQtRewardVideoAdDelegate alloc] initWithHandler:this];
}

GvQtRewardVideoAdIos::~GvQtRewardVideoAdIos()
{
}

void GvQtRewardVideoAdIos::LoadWithUnitId(const QString& unitId)
{
    //if (IsValid() && !m_AdMob.interstitial.hasBeenUsed) { return; }
    
    m_IsNeedToShow = false;
    [m_AdMob load:[NSString stringWithUTF8String:unitId.toUtf8().data()]];
    qDebug() << "load called:.....";
}

bool GvQtRewardVideoAdIos::IsLoaded() const
{
    if (!IsValid())
    {
        return false;
    }

    return m_AdMob.isAdLoaded;
}

void GvQtRewardVideoAdIos::Show()
{
    if (IsValid() && IsLoaded())
    {
        [m_AdMob show];
    }
    else
    {
        m_IsNeedToShow = true;
    }
}

void GvQtRewardVideoAdIos::AddTestDevice(const QString& hashedDeviceId)
{
    NSString *deviceId = [NSString stringWithUTF8String:hashedDeviceId.toUtf8().data()];
    [m_AdMob.testDevices addObject:deviceId];
}

void GvQtRewardVideoAdIos::OnStatusChanged(bool status)
{
    if (!status)
    {
        m_AdMob = nil;
    }
    else if (m_IsNeedToShow)
    {
        [m_AdMob show];
    }

    emit OnLoaded();
}

bool GvQtRewardVideoAdIos::IsValid() const
{
    return (m_AdMob != nil);
}

#endif // TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
