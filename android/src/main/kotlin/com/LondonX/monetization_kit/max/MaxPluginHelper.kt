package com.LondonX.monetization_kit.max

import android.app.Activity
import android.graphics.Color
import android.util.Log
import android.view.View
import android.view.ViewGroup
import com.applovin.mediation.MaxAd
import com.applovin.mediation.MaxAdViewAdListener
import com.applovin.mediation.MaxError
import com.applovin.mediation.MaxReward
import com.applovin.mediation.ads.MaxAdView
import com.applovin.mediation.ads.MaxAppOpenAd
import com.applovin.mediation.ads.MaxInterstitialAd
import com.applovin.mediation.ads.MaxRewardedAd
import com.applovin.mediation.nativeAds.MaxNativeAdListener
import com.applovin.mediation.nativeAds.MaxNativeAdLoader
import com.applovin.mediation.nativeAds.MaxNativeAdView
import com.applovin.sdk.AppLovinSdk
import com.applovin.sdk.AppLovinSdkConfiguration
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformViewRegistry
import java.util.*
import kotlin.math.roundToInt

class MaxPluginHelper(registry: PlatformViewRegistry, private val channel: MethodChannel) {

    val adLoadersPool = hashMapOf<String, MaxNativeAdLoader>()
    val adViewsPool = hashMapOf<String, View?>()
    val interstitialAdsPool = hashMapOf<String, MaxInterstitialAd>()
    val rewardedAdsPool = hashMapOf<String, MaxRewardedAd>()
    val appOpenAdsPool = hashMapOf<String, MaxAppOpenAd>()

    init {
        registry.registerViewFactory(
            "max_native_ad_template",
            MaxNativeAdViewFactory(adViewsPool, adLoadersPool),
        )
        registry.registerViewFactory(
            "max_banner",
            MaxBannerAdViewFactory(adViewsPool),
        )
    }

    private lateinit var activity: Activity

    fun onMethodCall(call: MethodCall, result: MethodChannel.Result, activity: Activity): Boolean {
        this.activity = activity
        when (call.method) {
            "max_initializeSdk" -> {
                AppLovinSdk.getInstance(activity).settings.setVerboseLogging(true)
                val config = AppLovinSdk.getInstance(activity).configuration?.toMap()
                AppLovinSdk.initializeSdk(activity) {}
                result.success(config)
            }

            "max_loadBannerAd" -> {
                val unitId = call.argument<String>("unitId")
                loadBannerAd(unitId!!, result)
            }

            "max_loadNativeAd" -> {
                val unitId = call.argument<String>("unitId")
                loadNativeAd(unitId!!, result)
            }

            "max_loadInterstitialAd" -> {
                val unitId = call.argument<String>("unitId")
                loadInterstitialAd(unitId!!, result)
            }

            "max_showInterstitialAd" -> {
                val adKey = call.argument<String>("adKey")
                showInterstitialAd(adKey, result)
            }

            "max_loadRewardedAd" -> {
                val unitId = call.argument<String>("unitId")
                loadRewardedAd(unitId!!, result)
            }

            "max_showRewardedAd" -> {
                val adKey = call.argument<String>("adKey")
                showRewardedAd(adKey, result)
            }

            "max_loadAppOpenAd" -> {
                val unitId = call.argument<String>("unitId")
                loadAppOpenAd(unitId!!, result)
            }

            "max_showAppOpenAd" -> {
                val adKey = call.argument<String>("adKey")
                showAppOpenAd(adKey, result)
            }

            "max_showMediationDebugger" -> {
                AppLovinSdk.getInstance(activity).showMediationDebugger()
            }

            else -> return false
        }
        return true
    }


    /**
     *  InterstitialAd
     */
    private fun loadInterstitialAd(unitId: String, result: MethodChannel.Result) {
        val interstitialAd = MaxInterstitialAd(unitId, activity)
        val adKey = UUID.randomUUID().toString()
        interstitialAd.setListener(object : SimpleMaxAdListener() {
            override fun onAdLoaded(ad: MaxAd) {
                super.onAdLoaded(ad)
                interstitialAdsPool[adKey] = interstitialAd
                result.success(
                    mapOf<String, Any?>(
                        "adKey" to adKey,
                        "error" to null,
                    )
                )
            }

            override fun onAdLoadFailed(adUnitId: String, error: MaxError) {
                super.onAdLoadFailed(adUnitId, error)
                result.success(
                    mapOf<String, Any?>(
                        "adKey" to null,
                        "error" to error.toMap(),
                    )
                )
            }

            override fun onAdClicked(ad: MaxAd) {
                super.onAdClicked(ad)
                channel.invokeMethod(
                    "max_onAdClick",
                    mapOf<String, Any?>("adKey" to adKey),
                )
            }

            override fun onAdDisplayed(ad: MaxAd) {
                super.onAdDisplayed(ad)
                channel.invokeMethod(
                    "max_onFullscreenAdShow",
                    mapOf<String, Any?>("adKey" to adKey),
                )
            }

            override fun onAdHidden(ad: MaxAd) {
                super.onAdHidden(ad)
                channel.invokeMethod(
                    "max_onFullscreenAdDismiss",
                    mapOf<String, Any?>("adKey" to adKey),
                )
            }
        })
        interstitialAd.loadAd()
    }

    private fun showInterstitialAd(adKey: String?, result: MethodChannel.Result) {
        val interstitialAd = interstitialAdsPool[adKey]
        if (interstitialAd == null) {
            Log.w(
                "MaxAdFlutter",
                "InterstitialAd with adKey: $adKey not found. You should call plugin's loadInterstitialAd method to get an adKey."
            )
            result.success(false)
            return
        }
        if (!interstitialAd.isReady) {
            Log.w(
                "MaxAdFlutter", "InterstitialAd with adKey: $adKey not ready."
            )
            result.success(false)
            return
        }
        interstitialAd.showAd()
        result.success(true)
    }


    /**
     *  RewardedAd
     */
    private fun loadRewardedAd(unitId: String, result: MethodChannel.Result) {
        val rewardedAd = MaxRewardedAd.getInstance(unitId, activity)
        val adKey = UUID.randomUUID().toString()
        rewardedAd.setListener(object : SimpleMaxAdListener() {
            override fun onAdLoaded(ad: MaxAd) {
                super.onAdLoaded(ad)
                rewardedAdsPool[adKey] = rewardedAd
                result.success(
                    mapOf<String, Any?>(
                        "adKey" to adKey,
                        "error" to null,
                    )
                )
            }

            override fun onAdLoadFailed(adUnitId: String, error: MaxError) {
                super.onAdLoadFailed(adUnitId, error)
                result.success(
                    mapOf<String, Any?>(
                        "adKey" to null,
                        "error" to error.toMap(),
                    )
                )
            }

            override fun onAdClicked(ad: MaxAd) {
                super.onAdClicked(ad)
                channel.invokeMethod(
                    "max_onAdClick",
                    mapOf<String, Any?>("adKey" to adKey),
                )
            }

            override fun onAdDisplayed(ad: MaxAd) {
                super.onAdDisplayed(ad)
                channel.invokeMethod(
                    "max_onFullscreenAdShow",
                    mapOf<String, Any?>("adKey" to adKey),
                )
            }

            override fun onAdHidden(ad: MaxAd) {
                super.onAdHidden(ad)
                channel.invokeMethod(
                    "max_onFullscreenAdDismiss",
                    mapOf<String, Any?>("adKey" to adKey),
                )
            }

            override fun onUserRewarded(ad: MaxAd, reward: MaxReward) {
                super.onUserRewarded(ad, reward)
                channel.invokeMethod(
                    "max_onRewarded",
                    mapOf<String, Any?>("adKey" to adKey),
                )
            }
        })
        rewardedAd.loadAd()
    }

    private fun showRewardedAd(adKey: String?, result: MethodChannel.Result) {
        val rewardedAd = rewardedAdsPool[adKey]
        if (rewardedAd == null) {
            Log.w(
                "MaxAdFlutter",
                "RewardedAd with adKey: $adKey not found. You should call plugin's loadRewardedAd method to get an adKey."
            )
            result.success(false)
            return
        }
        if (!rewardedAd.isReady) {
            Log.w(
                "MaxAdFlutter", "RewardedAd with adKey: $adKey not ready."
            )
            result.success(false)
            return
        }
        rewardedAd.showAd()
        result.success(true)
    }

    /**
     *  AppOpenAd
     */
    private fun loadAppOpenAd(unitId: String, result: MethodChannel.Result) {
        val appOpenAd = MaxAppOpenAd(unitId, activity)
        val adKey = UUID.randomUUID().toString()
        appOpenAd.setListener(object : SimpleMaxAdListener() {
            override fun onAdLoaded(ad: MaxAd) {
                super.onAdLoaded(ad)
                appOpenAdsPool[adKey] = appOpenAd
                result.success(
                    mapOf<String, Any?>(
                        "adKey" to adKey,
                        "error" to null,
                    )
                )
            }

            override fun onAdLoadFailed(adUnitId: String, error: MaxError) {
                super.onAdLoadFailed(adUnitId, error)
                result.success(
                    mapOf<String, Any?>(
                        "adKey" to null,
                        "error" to error.toMap(),
                    )
                )
            }

            override fun onAdClicked(ad: MaxAd) {
                super.onAdClicked(ad)
                channel.invokeMethod(
                    "max_onAdClick",
                    mapOf<String, Any?>("adKey" to adKey),
                )
            }

            override fun onAdDisplayed(ad: MaxAd) {
                super.onAdDisplayed(ad)
                channel.invokeMethod(
                    "max_onFullscreenAdShow",
                    mapOf<String, Any?>("adKey" to adKey),
                )
            }

            override fun onAdHidden(ad: MaxAd) {
                super.onAdHidden(ad)
                channel.invokeMethod(
                    "max_onFullscreenAdDismiss",
                    mapOf<String, Any?>("adKey" to adKey),
                )
            }
        })
        appOpenAd.loadAd()
    }

    private fun showAppOpenAd(adKey: String?, result: MethodChannel.Result) {
        val appOpenAd = appOpenAdsPool[adKey]
        if (appOpenAd == null) {
            Log.w(
                "MaxAdFlutter",
                "AppOpenAd with adKey: $adKey not found. You should call plugin's loadAppOpenAd method to get an adKey."
            )
            result.success(false)
            return
        }
        if (!appOpenAd.isReady) {
            Log.w(
                "MaxAdFlutter", "AppOpenAd with adKey: $adKey not ready."
            )
            result.success(false)
            return
        }
        appOpenAd.showAd()
        result.success(true)
    }

    /**
     *  NativeAd
     */
    private fun loadNativeAd(unitId: String, result: MethodChannel.Result) {
        val adLoader = MaxNativeAdLoader(unitId, activity)
        val adKey = UUID.randomUUID().toString()
        adLoader.setNativeAdListener(object : MaxNativeAdListener() {
            override fun onNativeAdLoaded(p0: MaxNativeAdView?, p1: MaxAd) {
                super.onNativeAdLoaded(p0, p1)
                adLoadersPool[adKey] = adLoader
                adViewsPool[adKey] = p0
                result.success(
                    mapOf<String, Any?>(
                        "adKey" to adKey,
                        "error" to null,
                    )
                )
            }

            override fun onNativeAdLoadFailed(p0: String, p1: MaxError) {
                super.onNativeAdLoadFailed(p0, p1)
                result.success(
                    mapOf(
                        "adKey" to null,
                        "error" to p1.toMap(),
                    )
                )
            }

            override fun onNativeAdClicked(p0: MaxAd) {
                super.onNativeAdClicked(p0)
                channel.invokeMethod(
                    "max_onAdClick",
                    mapOf<String, Any?>("adKey" to adKey),
                )
            }
        })
        adLoader.loadAd()
    }

    /**
     *  BannerAd
     */
    private fun loadBannerAd(unitId: String, result: MethodChannel.Result) {
        val adView = MaxAdView(unitId, activity)
        val adKey = UUID.randomUUID().toString()
        adView.setListener(object : MaxAdViewAdListener {
            override fun onAdLoaded(ad: MaxAd) {
                adViewsPool[adKey] = adView
                result.success(
                    mapOf(
                        "adKey" to adKey,
                        "error" to null,
                    )
                )
            }

            override fun onAdDisplayed(ad: MaxAd) {}

            override fun onAdHidden(ad: MaxAd) {}

            override fun onAdClicked(ad: MaxAd) {
                channel.invokeMethod(
                    "max_onAdClick",
                    mapOf<String, Any?>("adKey" to adKey),
                )
            }

            override fun onAdLoadFailed(adUnitId: String, error: MaxError) {
                result.success(
                    mapOf(
                        "adKey" to null,
                        "error" to error.toMap(),
                    )
                )
            }

            override fun onAdDisplayFailed(ad: MaxAd, error: MaxError) {}

            override fun onAdExpanded(ad: MaxAd) {}

            override fun onAdCollapsed(ad: MaxAd) {}
        })
        val width = ViewGroup.LayoutParams.MATCH_PARENT
        val height = (activity.resources.displayMetrics.density * 50).roundToInt()
        adView.layoutParams = ViewGroup.LayoutParams(width, height)
        adView.setBackgroundColor(Color.WHITE)
        adView.loadAd()
    }
}

fun AppLovinSdkConfiguration.toMap(): Map<String, Any?> {
    return mapOf(
        "countryCode" to this.countryCode,
    )
}

fun MaxError.toMap(): Map<String, Any?> {
    return mapOf(
        "code" to this.code,
        "message" to this.message,
        "mediatedNetworkErrorCode" to this.mediatedNetworkErrorCode,
        "mediatedNetworkErrorMessage" to this.mediatedNetworkErrorMessage,
    )
}