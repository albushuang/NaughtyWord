#include "GvQtRewardVideoAdIos.h"


#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

#import "ALSdk.h"
#import "ALIncentivizedInterstitialAd.h"
#include <QDebug>



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
    static void OnVideoEnded(GvQtRewardVideoAdIos* handler) {
        if (!handler)
        {
            return;
        }

        handler->OnVideoEnded();
    }

    static void onObtained(GvQtRewardVideoAdIos* handler, const char* type, int amount) {
        if (!handler)
        {
            return;
        }

        handler->OnObtained(QString(type), amount);
    }
};

@interface GvQtRewardVideoAdDelegate : NSObject<ALAdLoadDelegate, ALAdRewardDelegate, ALAdDisplayDelegate, ALAdVideoPlaybackDelegate>

//@property (nonatomic, strong) GADInterstitial* interstitial;
@property (nonatomic, strong) NSMutableArray* testDevices;
@property (nonatomic, assign) GvQtRewardVideoAdIos *handler;
@property(nonatomic, assign) bool isAdLoaded;

- (id)initWithHandler:(GvQtRewardVideoAdIos *)handler;

- (void)load:(NSString *)adUnitId;

@end

@implementation GvQtRewardVideoAdDelegate

- (id)initWithHandler:(GvQtRewardVideoAdIos *)handler/* adUnitId:(NSString *)adUnitId*/
{
    self = [super init];
    if (self)
    {
        _handler = handler;
        _testDevices = [[NSMutableArray alloc] init];
        //_testDevices = [[NSMutableArray alloc] initWithArray:@[kGADSimulatorID]];
//        GADRequest *request = [GADRequest request];
//        [[GADRewardBasedVideoAd sharedInstance] loadRequest:request
//                                                withAdUnitID:adUnitId];
//                                               //withAdUnitID:@"INSERT_AD_UNIT_HERE"];
        //_interstitial = [[GADInterstitial alloc] initWithAdUnitID:adUnitId];
        //_interstitial.delegate = self;
        [ALSdk initializeSdk];
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

//    GADRequest *request = [GADRequest request];
//    request.testDevices = _testDevices;
//    [[GADRewardBasedVideoAd sharedInstance] loadRequest:request
//                                           withAdUnitID:adUnitId
//                                           userID: @"user"];
//    [[GADRewardBasedVideoAd sharedInstance] loadRequest:request withAdUnitID:@"ca-app-pub-1482222222222222/1666666688"];
//    [[GADRewardBasedVideoAd sharedInstance] loadRequest:request]
//                                           withAdUnitID:@"ca-app-pub-1482222222222222/1666666688"];

    [ALIncentivizedInterstitialAd preloadAndNotify: self];
    GvQtRewardVideoAdDelegateIosProtected::OnLoading(self.handler);
    self.isAdLoaded = false;
}

- (void)show
{
//    UIApplication *application = [UIApplication sharedApplication];
//    UIWindow *window = [[application windows] firstObject];
//    UIViewController* rootViewController = [window rootViewController];
    
//    if ([[GADRewardBasedVideoAd sharedInstance] isReady]) {
//        [[GADRewardBasedVideoAd sharedInstance] presentFromRootViewController:rootViewController];
//        if([ALIncentivizedInterstitialAd isReadyForDisplay]){
//            // Show call not using a reward delegate.
//            [ALIncentivizedInterstitialAd show];
//        }
//      }
    //[_interstitial presentFromRootViewController:rootViewController];

        // Unlike interstitials, you need to preload each rewarded video before it can be displayed.
    if ([ALIncentivizedInterstitialAd isReadyForDisplay])
    {
        // Optional: Assign delegates
        [ALIncentivizedInterstitialAd shared].adDisplayDelegate = self;
        [ALIncentivizedInterstitialAd shared].adVideoPlaybackDelegate = self;

        [ALIncentivizedInterstitialAd showAndNotify: self];
    }
    else
    {
        // Ideally, the SDK preloads ads when you initialize it in application:didFinishLaunchingWithOptions: of the app delegate
        [self load: nil];
    }
}

#pragma mark - Ad Load Delegate

- (void)adService:(ALAdService *)adService didLoadAd:(ALAd *)ad
{
    self.isAdLoaded = true;
    GvQtRewardVideoAdDelegateIosProtected::OnLoaded(self.handler, true);
}

- (void)adService:(ALAdService *)adService didFailToLoadAdWithError:(int)code
{
     NSLog([NSString stringWithFormat: @"Rewarded video failed to load with error code %d", code]);
}

#pragma mark - Ad Reward Delegate

- (void)rewardValidationRequestForAd:(ALAd *)ad didSucceedWithResponse:(nonnull NSDictionary *)response
{
    /* AppLovin servers validated the reward. Refresh user balance from your server.  We will also pass the number of coins
     awarded and the name of the currency.  However, ideally, you should verify this with your server before granting it. */

    // i.e. - "Coins", "Gold", whatever you set in the dashboard.
    NSString *currencyName = [response objectForKey: @"currency"];

    // For example, "5" or "5.00" if you've specified an amount in the UI.
    NSString *amountGivenString = [response objectForKey: @"amount"];
    NSNumber *amountGiven = [NSNumber numberWithFloat: [amountGivenString floatValue]];

    // Do something with this information.
    // [MYCurrencyManagerClass updateUserCurrency: currencyName withChange: amountGiven];
    // GvQtRewardVideoAdDelegateIosProtected::OnMessage(self.handler, [[NSString stringWithFormat: @"Rewarded %@ %@", amountGiven, currencyName] UTF8String]);
    // By default we'll show a UIAlertView informing your user of the currency & amount earned.
    // If you don't want this, you can turn it off in the Manage Apps UI.
    NSString *rewardMessage =
        [NSString stringWithFormat:@"Reward received with currency %@ , amount %lf", currencyName, amountGiven];
    GvQtRewardVideoAdDelegateIosProtected::onObtained(self.handler, [currencyName UTF8String], [amountGivenString integerValue]);
}

- (void)rewardValidationRequestForAd:(ALAd *)ad didFailWithError:(NSInteger)responseCode
{
    GvQtRewardVideoAdDelegateIosProtected::OnLoaded(self.handler, false);
    if (responseCode == kALErrorCodeIncentivizedUserClosedVideo)
    {
        // Your user exited the video prematurely. It's up to you if you'd still like to grant
        // a reward in this case. Most developers choose not to. Note that this case can occur
        // after a reward was initially granted (since reward validation happens as soon as a
        // video is launched).
    }
    else if (responseCode == kALErrorCodeIncentivizedValidationNetworkTimeout || responseCode == kALErrorCodeIncentivizedUnknownServerError)
    {
        // Some server issue happened here. Don't grant a reward. By default we'll show the user
        // a UIAlertView telling them to try again later, but you can change this in the
        // Manage Apps UI.
    }
    else if (responseCode == kALErrorCodeIncentiviziedAdNotPreloaded)
    {
        // Indicates that the developer called for a rewarded video before one was available.
    }
}

- (void)rewardValidationRequestForAd:(ALAd *)ad didExceedQuotaWithResponse:(NSDictionary *)response
{
    // Your user has already earned the max amount you allowed for the day at this point, so
    // don't give them any more money. By default we'll show them a UIAlertView explaining this,
    // though you can change that from the Manage Apps UI.
    NSLog(@"Reward based video ad: didExceedQuotaWithResponse.");
}

- (void)rewardValidationRequestForAd:(ALAd *)ad wasRejectedWithResponse:(NSDictionary *)response
{
    // Your user couldn't be granted a reward for this view. This could happen if you've blacklisted
    // them, for example. Don't grant them any currency. By default we'll show them a UIAlertView explaining this,
    // though you can change that from the Manage Apps UI.
    NSLog(@"Reward based video ad is rejected.");
}

#pragma mark - Ad Display Delegate

- (void)ad:(nonnull ALAd *)ad wasDisplayedIn:(nonnull UIView *)view
{
    NSLog(@"Ad Displayed");
}

- (void)ad:(nonnull ALAd *)ad wasHiddenIn:(nonnull UIView *)view
{
    NSLog(@"Ad Dismissed");
}

- (void)ad:(nonnull ALAd *)ad wasClickedIn:(nonnull UIView *)view
{
    NSLog(@"Ad Clicked");
}

#pragma mark - Ad Video Playback Delegate

- (void)videoPlaybackBeganInAd:(nonnull ALAd *)ad
{
    NSLog(@"Video Started");
}

- (void)videoPlaybackEndedInAd:(nonnull ALAd *)ad atPlaybackPercent:(nonnull NSNumber *)percentPlayed fullyWatched:(BOOL)wasFullyWatched
{
    NSLog(@"Video Ended");
    GvQtRewardVideoAdDelegateIosProtected::OnVideoEnded(self.handler);
}

// - (void)rewardBasedVideoAdDidReceiveAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
//   GvQtRewardVideoAdDelegateIosProtected::OnLoaded(self.handler, true);
//   self.isAdLoaded = true;
//   //self.rewardBasedVideoRequestLoading = NO;
//   NSLog(@"Reward based video ad is received.");
// }

// - (void)rewardBasedVideoAdDidOpen:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
//   NSLog(@"Opened reward based video ad.");
// }

// - (void)rewardBasedVideoAdDidStartPlaying:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
//   NSLog(@"Reward based video ad started playing.");
// }

// - (void)rewardBasedVideoAdDidClose:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
//   NSLog(@"Reward based video ad is closed.");
//   GvQtRewardVideoAdDelegateIosProtected::OnClosed(self.handler);
//   //self.showVideoButton.hidden = YES;
// }

// - (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd
//     didRewardUserWithReward:(GADAdReward *)reward {
//   NSString *rewardMessage =
//       [NSString stringWithFormat:@"Reward received with currency %@ , amount %lf", reward.type,
//                                  [reward.amount doubleValue]];
//   GvQtRewardVideoAdDelegateIosProtected::onObtained(self.handler, [reward.type UTF8String], [reward.amount integerValue]);
//   NSLog(@"%@", rewardMessage);
//   // Reward the user for watching the video.
// //  [self earnCoins:[reward.amount integerValue]];
// //  self.showVideoButton.hidden = YES;
// }

// - (void)rewardBasedVideoAdWillLeaveApplication:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
//   NSLog(@"Reward based video ad will leave application.");
// }

// - (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd
//     didFailToLoadWithError:(NSError *)error {
//   GvQtRewardVideoAdDelegateIosProtected::OnLoaded(self.handler, false);
//   //self.rewardBasedVideoRequestLoading = NO;
//   NSLog(@"Reward based video ad failed to load.");
// }


@end

GvQtRewardVideoAdIos::GvQtRewardVideoAdIos()
    : m_AdMob(nil)
    , m_IsNeedToShow(false)
{
    m_AdMob = [[GvQtRewardVideoAdDelegate alloc] initWithHandler:this];
}

GvQtRewardVideoAdIos::~GvQtRewardVideoAdIos()
{
}

void GvQtRewardVideoAdIos::LoadWithUnitId(const QString& unitId)
{
    if (!IsValid() /*&&
        !m_AdMob.interstitial.hasBeenUsed*/)
    {
        return;
    }
    
    m_IsNeedToShow = false;
    [m_AdMob load:[NSString stringWithUTF8String:unitId.toUtf8().data()]];
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
