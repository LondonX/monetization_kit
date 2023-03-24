package com.LondonX.max_ad_flutter

import android.app.Activity
import android.content.Context
import android.graphics.Color
import android.util.Log
import android.view.View
import android.view.ViewGroup
import androidx.annotation.NonNull
import com.applovin.mediation.MaxAd
import com.applovin.mediation.MaxAdViewAdListener
import com.applovin.mediation.MaxError
import com.applovin.mediation.MaxReward
import com.applovin.mediation.ads.MaxAdView
import com.applovin.mediation.ads.MaxInterstitialAd
import com.applovin.mediation.ads.MaxRewardedAd
import com.applovin.mediation.nativeAds.MaxNativeAdListener
import com.applovin.mediation.nativeAds.MaxNativeAdLoader
import com.applovin.mediation.nativeAds.MaxNativeAdView
import com.applovin.sdk.AppLovinMediationProvider
import com.applovin.sdk.AppLovinSdk
import com.applovin.sdk.AppLovinSdkConfiguration
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.*

class MaxAdFlutterPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private lateinit var activity: Activity

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "max_ad_flutter")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
        flutterPluginBinding.platformViewRegistry.registerViewFactory(
            "max_native_ad_template",
            MaxNativeAdViewFactory(),
        )
        flutterPluginBinding.platformViewRegistry.registerViewFactory(
            "max_banner",
            MaxBannerAdViewFactory(),
        )
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "initializeSdk" -> {
                AppLovinSdk.getInstance(context).settings.setVerboseLogging(true)
                AppLovinSdk.getInstance(context).mediationProvider = AppLovinMediationProvider.MAX
                AppLovinSdk.initializeSdk(context) {
                    result.success(it.toMap())
                }
            }
            "loadBannerAd" -> {
                val unitId = call.argument<String>("unitId")
                loadBannerAd(unitId!!, result)
            }
            "loadNativeAd" -> {
                val unitId = call.argument<String>("unitId")
                loadNativeAd(unitId!!, result)
            }
            "loadInterstitialAd" -> {
                val unitId = call.argument<String>("unitId")
                loadInterstitialAd(unitId!!, result)
            }
            "showInterstitialAd" -> {
                val adKey = call.argument<String>("adKey")
                showInterstitialAd(adKey, result)
            }
            "loadRewardedAd" -> {
                val unitId = call.argument<String>("unitId")
                loadRewardedAd(unitId!!, result)
            }
            "showRewardedAd" -> {
                val adKey = call.argument<String>("adKey")
                showRewardedAd(adKey, result)
            }
            "showMediationDebugger" -> {
                AppLovinSdk.getInstance(context).showMediationDebugger()
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    companion object {
        val adLoadersPool = hashMapOf<String, MaxNativeAdLoader>()
        val adViewsPool = hashMapOf<String, View?>()
        val interstitialAdsPool = hashMapOf<String, MaxInterstitialAd>()
        val rewardedAdsPool = hashMapOf<String, MaxRewardedAd>()
    }

    /**
     *  InterstitialAd
     */
    private fun loadInterstitialAd(unitId: String, result: Result) {
        val interstitialAd = MaxInterstitialAd(unitId, activity)
        val adKey = UUID.randomUUID().toString()
        interstitialAd.setListener(object : SimpleMaxAdListener() {
            override fun onAdLoaded(ad: MaxAd?) {
                super.onAdLoaded(ad)
                interstitialAdsPool[adKey] = interstitialAd
                result.success(
                    mapOf<String, Any?>(
                        "adKey" to adKey,
                        "error" to null,
                    )
                )
            }

            override fun onAdLoadFailed(adUnitId: String?, error: MaxError?) {
                super.onAdLoadFailed(adUnitId, error)
                result.success(
                    mapOf<String, Any?>(
                        "adKey" to null,
                        "error" to error?.toMap(),
                    )
                )
            }

            override fun onAdClicked(ad: MaxAd?) {
                super.onAdClicked(ad)
                channel.invokeMethod(
                    "onAdClick",
                    mapOf<String, Any?>("adKey" to adKey),
                )
            }

            override fun onAdDisplayed(ad: MaxAd?) {
                super.onAdDisplayed(ad)
                channel.invokeMethod(
                    "onFullscreenAdShow",
                    mapOf<String, Any?>("adKey" to adKey),
                )
            }

            override fun onAdHidden(ad: MaxAd?) {
                super.onAdHidden(ad)
                channel.invokeMethod(
                    "onFullscreenAdDismiss",
                    mapOf<String, Any?>("adKey" to adKey),
                )
            }
        })
        interstitialAd.loadAd()
    }

    private fun showInterstitialAd(adKey: String?, result: Result) {
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
                "MaxAdFlutter",
                "InterstitialAd with adKey: $adKey not ready."
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
    private fun loadRewardedAd(unitId: String, result: Result) {
        val rewardedAd = MaxRewardedAd.getInstance(unitId, activity)
        val adKey = UUID.randomUUID().toString()
        rewardedAd.setListener(object : SimpleMaxAdListener() {
            override fun onAdLoaded(ad: MaxAd?) {
                super.onAdLoaded(ad)
                rewardedAdsPool[adKey] = rewardedAd
                result.success(
                    mapOf<String, Any?>(
                        "adKey" to adKey,
                        "error" to null,
                    )
                )
            }

            override fun onAdLoadFailed(adUnitId: String?, error: MaxError?) {
                super.onAdLoadFailed(adUnitId, error)
                result.success(
                    mapOf<String, Any?>(
                        "adKey" to null,
                        "error" to error?.toMap(),
                    )
                )
            }

            override fun onAdClicked(ad: MaxAd?) {
                super.onAdClicked(ad)
                channel.invokeMethod(
                    "onAdClick",
                    mapOf<String, Any?>("adKey" to adKey),
                )
            }

            override fun onAdDisplayed(ad: MaxAd?) {
                super.onAdDisplayed(ad)
                channel.invokeMethod(
                    "onFullscreenAdShow",
                    mapOf<String, Any?>("adKey" to adKey),
                )
            }
            
            override fun onAdHidden(ad: MaxAd?) {
                super.onAdHidden(ad)
                channel.invokeMethod(
                    "onFullscreenAdDismiss",
                    mapOf<String, Any?>("adKey" to adKey),
                )
            }

            override fun onUserRewarded(ad: MaxAd?, reward: MaxReward?) {
                super.onUserRewarded(ad, reward)
                channel.invokeMethod(
                    "onRewarded",
                    mapOf<String, Any?>("adKey" to adKey),
                )
            }
        })
        rewardedAd.loadAd()
    }

    private fun showRewardedAd(adKey: String?, result: Result) {
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
                "MaxAdFlutter",
                "RewardedAd with adKey: $adKey not ready."
            )
            result.success(false)
            return
        }
        rewardedAd.showAd()
        result.success(true)
    }

    /**
     *  NativeAd
     */
    private fun loadNativeAd(unitId: String, result: Result) {
        val adLoader = MaxNativeAdLoader(unitId, context)
        val adKey = UUID.randomUUID().toString()
        adLoader.setNativeAdListener(object : MaxNativeAdListener() {
            override fun onNativeAdLoaded(p0: MaxNativeAdView?, p1: MaxAd?) {
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

            override fun onNativeAdLoadFailed(p0: String?, p1: MaxError?) {
                super.onNativeAdLoadFailed(p0, p1)
                result.success(
                    mapOf(
                        "adKey" to null,
                        "error" to p1?.toMap(),
                    )
                )
            }

            override fun onNativeAdClicked(p0: MaxAd?) {
                super.onNativeAdClicked(p0)
                channel.invokeMethod(
                    "onAdClick",
                    mapOf<String, Any?>("adKey" to adKey),
                )
            }
        })
        adLoader.loadAd()
    }

    /**
     *  BannerAd
     */
    private fun loadBannerAd(unitId: String, result: Result) {
        val adView = MaxAdView(unitId, context)
        val adKey = UUID.randomUUID().toString()
        adView.setListener(object : MaxAdViewAdListener {
            override fun onAdLoaded(ad: MaxAd?) {
                adViewsPool[adKey] = adView
                result.success(
                    mapOf(
                        "adKey" to adKey,
                        "error" to null,
                    )
                )
            }

            override fun onAdDisplayed(ad: MaxAd?) {}

            override fun onAdHidden(ad: MaxAd?) {}

            override fun onAdClicked(ad: MaxAd?) {
                channel.invokeMethod(
                    "onAdClick",
                    mapOf<String, Any?>("adKey" to adKey),
                )
            }

            override fun onAdLoadFailed(adUnitId: String?, error: MaxError?) {
                result.success(
                    mapOf(
                        "adKey" to null,
                        "error" to error?.toMap(),
                    )
                )
            }

            override fun onAdDisplayFailed(ad: MaxAd?, error: MaxError?) {}

            override fun onAdExpanded(ad: MaxAd?) {}

            override fun onAdCollapsed(ad: MaxAd?) {}
        })
        val width = ViewGroup.LayoutParams.MATCH_PARENT
        val height = context.resources.getDimensionPixelSize(R.dimen.banner_height_50)
        adView.layoutParams = ViewGroup.LayoutParams(width, height)
        adView.setBackgroundColor(Color.WHITE)
        adView.loadAd()
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {}

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}

    override fun onDetachedFromActivity() {}
}

fun AppLovinSdkConfiguration.toMap(): Map<String, Any?> {
    return mapOf(
        "countryCode" to this.countryCode,
        "consentDialogState" to this.consentDialogState.ordinal,
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