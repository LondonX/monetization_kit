package com.LondonX.max_ad_flutter

import android.content.Context
import android.util.Log
import android.view.View
import com.applovin.mediation.ads.MaxAdView
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class MaxBannerAdViewFactory :
    PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
        if (context == null) return buildEmptyPlatformView()
        val creationParams = args as? Map<*, *>
        val adKey = creationParams?.get("adKey")?.toString()
        val adView = MaxAdFlutterPlugin.adViewsPool[adKey] as? MaxAdView
        if (adKey.isNullOrBlank()) {
            Log.w(
                "MaxAdFlutter",
                "adKey is null or blank. You should call plugin's loadNativeAd method to get an adKey."
            )
            return buildEmptyPlatformView()
        }
        if (adView == null) {
            Log.w(
                "MaxAdFlutter",
                "adLoader with adKey: $adKey not found. You should call plugin's loadNativeAd method to get an adKey."
            )
            return buildEmptyPlatformView()
        }
        adView.startAutoRefresh()

        return object : PlatformView {
            override fun getView(): View = adView

            override fun dispose() {
                adView.stopAutoRefresh()
                adView.destroy()
            }
        }
    }
}