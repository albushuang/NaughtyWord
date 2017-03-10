package com.glovisdom.NaughtyWord;

// import com.google.ads.mediation.admob.AdMobAdapter;
import com.glovisdom.NaughtyWord.R;
// import com.google.android.gms.ads.AdRequest;
// import com.google.android.gms.ads.AdListener;
// import com.google.android.gms.ads.MobileAds;
// import com.google.android.gms.ads.reward.RewardItem;
// import com.google.android.gms.ads.reward.RewardedVideoAd;
// import com.google.android.gms.ads.reward.RewardedVideoAdListener;


import com.applovin.adview.AppLovinIncentivizedInterstitial;
import com.applovin.sdk.AppLovinAd;
import com.applovin.sdk.AppLovinAdClickListener;
import com.applovin.sdk.AppLovinAdDisplayListener;
import com.applovin.sdk.AppLovinAdLoadListener;
import com.applovin.sdk.AppLovinAdRewardListener;
import com.applovin.sdk.AppLovinAdVideoPlaybackListener;
import com.applovin.sdk.AppLovinErrorCodes;
import com.applovin.sdk.AppLovinSdk;

import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
import android.util.Log;
import org.qtproject.qt5.android.bindings.QtActivity;
import org.qtproject.qt5.android.bindings.QtApplication;
import java.util.ArrayList;
import java.util.logging.Logger;
import android.widget.FrameLayout;
//import android.support.v4.app.NotificationCompat;

import java.lang.ref.WeakReference;
import java.util.Map;

public class GvQtRewardVideoAdActivity extends QtActivity// implements RewardedVideoAdListener
{
    //private ViewGroup m_ViewGroup;
    //private AdView m_AdBannerView = null;
    //private RewardedVideoAd m_RewardedVideoAd = null;
    private boolean m_IsRewardVideoAdLoaded = false;
    private ArrayList<String> m_TestDevices = new ArrayList<String>();
    private AppLovinIncentivizedInterstitial incentivizedInterstitial = null;
    private static Logger LOGGER = Logger.getLogger("InfoLogging");
    final GvQtRewardVideoAdActivity self = this;

    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        AppLovinSdk.initializeSdk(getApplicationContext());
        final AppLovinSdk sdk = AppLovinSdk.getInstance(getApplicationContext());
    }

    public void AddAdTestDevice(final String deviceId)
    {
        runOnUiThread(new Runnable()
        {
            public void run()
            {
                m_TestDevices.add(deviceId);
            }
        });
    }

    public void LoadRewardedVideoAdWithUnitId(final String adId)
    {
        onRewardVideoAdLoading();
        runOnUiThread(new Runnable()
        {
            public void run()
            {
                // setContentView(R.layout.activity_main);
                // if (m_RewardedVideoAd == null) {
                //     m_RewardedVideoAd = MobileAds.getRewardedVideoAdInstance(self);
                //     m_RewardedVideoAd.setRewardedVideoAdListener(self);
                // }
                // RequestNewRewardedVideoAd(adId);

                m_IsRewardVideoAdLoaded = false;
                incentivizedInterstitial = AppLovinIncentivizedInterstitial.create(getApplicationContext());
                String str = "instance:" + incentivizedInterstitial;
                LOGGER.info(str);
                incentivizedInterstitial.preload(new AppLovinAdLoadListener() {
                    @Override
                    public void adReceived(AppLovinAd appLovinAd) {
                        self.m_IsRewardVideoAdLoaded = true;
                        self.onRewardVideoAdLoaded();
                        LOGGER.info("Rewarded video loaded.");
                    }

                    @Override
                    public void failedToReceiveAd(int errorCode) {
                        LOGGER.info("Rewarded video failed to load with error code " + errorCode);
                    }
                });
            }
        });
    }

    public void ShowRewardedVideoAd()
    {
        final WeakReference<GvQtRewardVideoAdActivity> weakRef = new WeakReference<GvQtRewardVideoAdActivity>(this);
        onRewardVideoAdWillPresent();
        final GvQtRewardVideoAdActivity self = this;
        runOnUiThread(new Runnable()
        {
            public void run()
            {
                if (incentivizedInterstitial.isAdReadyToDisplay()) {

                    //
                    // OPTIONAL: Create listeners
                    //

                    // Reward Listener
                    AppLovinAdRewardListener adRewardListener = new AppLovinAdRewardListener() {
                        @Override
                        public void userRewardVerified(AppLovinAd appLovinAd, Map map) {
                            // AppLovin servers validated the reward. Refresh user balance from your server.  We will also pass the number of coins
                            // awarded and the name of the currency.  However, ideally, you should verify this with your server before granting it.

                            // i.e. - "Coins", "Gold", whatever you set in the dashboard.
                            String currencyName = (String) map.get("currency");
                            // For example, "5" or "5.00" if you've specified an amount in the UI.
                            String amountGivenString = (String) map.get("amount");
                            LOGGER.info("Rewarded " + amountGivenString + " " + currencyName);
                            Double d = Double.parseDouble(amountGivenString);
                            onRewardedItemObtained(currencyName,  Integer.valueOf(d.intValue()));
                            // By default we'll show a alert informing your user of the currency & amount earned.
                            // If you don't want this, you can turn it off in the Manage Apps UI.
                        }

                        @Override
                        public void userOverQuota(AppLovinAd appLovinAd, Map map) {
                            // Your user has already earned the max amount you allowed for the day at this point, so
                            // don't give them any more money. By default we'll show them a alert explaining this,
                            // though you can change that from the AppLovin dashboard.
                        }

                        @Override
                        public void userRewardRejected(AppLovinAd appLovinAd, Map map) {
                            // Your user couldn't be granted a reward for this view. This could happen if you've blacklisted
                            // them, for example. Don't grant them any currency. By default we'll show them an alert explaining this,
                            // though you can change that from the AppLovin dashboard.
                        }

                        @Override
                        public void validationRequestFailed(AppLovinAd appLovinAd, int responseCode) {
                            if (responseCode == AppLovinErrorCodes.INCENTIVIZED_USER_CLOSED_VIDEO) {
                                // Your user exited the video prematurely. It's up to you if you'd still like to grant
                                // a reward in this case. Most developers choose not to. Note that this case can occur
                                // after a reward was initially granted (since reward validation happens as soon as a
                                // video is launched).
                            } else if (responseCode == AppLovinErrorCodes.INCENTIVIZED_SERVER_TIMEOUT || responseCode == AppLovinErrorCodes.INCENTIVIZED_UNKNOWN_SERVER_ERROR) {
                                // Some server issue happened here. Don't grant a reward. By default we'll show the user
                                // a alert telling them to try again later, but you can change this in the
                                // AppLovin dashboard.
                            } else if (responseCode == AppLovinErrorCodes.INCENTIVIZED_NO_AD_PRELOADED) {
                                // Indicates that the developer called for a rewarded video before one was available.
                                // Note: This code is only possible when working with rewarded videos.
                            }
                        }

                        @Override
                        public void userDeclinedToViewAd(AppLovinAd appLovinAd) {
                            // This method will be invoked if the user selected "no" when asked if they want to view an ad.
                            // If you've disabled the pre-video prompt in the "Manage Apps" UI on our website, then this method won't be called.
                        }
                    };

                    // Video Playback Listener
                    AppLovinAdVideoPlaybackListener adVideoPlaybackListener = new AppLovinAdVideoPlaybackListener() {
                        @Override
                        public void videoPlaybackBegan(AppLovinAd appLovinAd) {
                            //log("Video Started");
                        }

                        @Override
                        public void videoPlaybackEnded(AppLovinAd appLovinAd, double v, boolean b) {
                            //LOGGER.info("Video Ended");
                            self.onRewardVideoAdEnded();
                        }
                    };

                    // Ad Dispaly Listener
                    AppLovinAdDisplayListener adDisplayListener = new AppLovinAdDisplayListener() {
                        @Override
                        public void adDisplayed(AppLovinAd appLovinAd) {
                            //log("Ad Displayed");
                        }

                        @Override
                        public void adHidden(AppLovinAd appLovinAd) {
                            //log("Ad Dismissed");
                        }
                    };

                    // Ad Click Listener
                    AppLovinAdClickListener adClickListener = new AppLovinAdClickListener() {
                        @Override
                        public void adClicked(AppLovinAd appLovinAd) {
                            //log("Ad Click");
                        }
                    };

                    /*
                     NOTE: We recommend the use of placements (AFTER creating them in your dashboard):

                     incentivizedInterstitial.show("REWARDED_VIDEO_DEMO_SCREEN", adRewardListener, adVideoPlaybackListener, adDisplayListener, adClickListener);

                     To learn more about placements, check out https://applovin.com/integration#androidPlacementsIntegration
                     */
                    onRewardVideoAdWillPresent(); // again!
                    incentivizedInterstitial.show(weakRef.get(), adRewardListener, adVideoPlaybackListener, adDisplayListener, adClickListener);
                    m_IsRewardVideoAdLoaded = false;
                // if (m_IsRewardVideoAdLoaded)
                // {
                //     onRewardVideoAdWillPresent();
                //     m_RewardedVideoAd.show();
                //     m_IsRewardVideoAdLoaded = false; // Ad might be presented only once, need reload
                // }
                }
            }
        });
    }


//    @Override
//     public void onRewardedVideoAdLoaded() {
//        onRewardVideoAdLoaded();
//        m_IsRewardVideoAdLoaded = true;
//         //findViewById(R.id.display_button).setVisibility(View.VISIBLE);
//     }

     // public void onDisplayButtonClicked(View view) {
     //     if (m_RewardedVideoAd.isLoaded()) {
     //         m_RewardedVideoAd.show();
     //     }
     // }
//    @Override
//    public void onRewardedVideoAdFailedToLoad(int errorCode) {
//        //Utils.showToast(mActivity, "onRewardedVideoFailedToLoad");
//    }

    public boolean IsRewardedVideoAdLoaded()
    {
        return m_IsRewardVideoAdLoaded;
    }

    // @Override
    // public void onRewardedVideoShown() {
    //     //Utils.showToast(mActivity, "onRewardedVideoShown");
    // }

    // @Override
    // public void onRewardedVideoFinished(int amount, String name) {
    //     //Utils.showToast(mActivity, String.format("onRewardedVideoFinished. Reward: %d %s", amount, name));
    // }

//    @Override
//    public void onRewardedVideoAdOpened() {
//        onRewardVideoAdOpened();
//        //Utils.showToast(mActivity, String.format("onRewardedVideoClosed,  finished: %s", finished));
//    }
//        @Override
//    public void onRewardedVideoAdClosed() {
//        onRewardVideoAdClosed();
//        //Utils.showToast(mActivity, String.format("onRewardedVideoClosed,  finished: %s", finished));
//    }

//    @Override
//    public void onRewardedVideoStarted() {
//        onRewardVideoAdStarted();
//        //Utils.showToast(mActivity, String.format("onRewardedVideoClosed,  finished: %s", finished));
//    }

//    @Override
//    public void onRewardedVideoAdLeftApplication() {
//        onRewardVideoAdClicked();
//        //Toast.makeText(this, "onRewardedVideoAdLeftApplication", Toast.LENGTH_SHORT).show();
//    }

//    @Override
//     public void onRewarded(RewardItem rewardItem) {
//        onRewardedItemObtained(rewardItem.getType(), rewardItem.getAmount());
//     }

     @Override
     public void onResume() {
         super.onResume();
         //m_RewardedVideoAd.resume(this);
     }

     // @Override
     // public void onPause() {
     //     //m_RewardedVideoAd.pause();
     //     super.onPause(this);
     // }

     @Override
     public void onDestroy() {
         //m_RewardedVideoAd.destroy(this);
         super.onDestroy();
     }


    private static native void onRewardVideoAdLoading();
    private static native void onRewardVideoAdLoaded();
    private static native void onRewardVideoAdEnded();
    private static native void onRewardVideoAdWillPresent();
    private static native void onRewardVideoAdStarted();
    private static native void onRewardVideoAdOpened();
    private static native void onRewardVideoAdClosed();
    private static native void onRewardVideoAdClicked();
    private static native void onRewardedItemObtained(final String type, int amount);
}
