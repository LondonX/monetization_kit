package com.LondonX.monetization_kit.max

import android.content.Context
import android.util.Log
import android.view.View
import com.applovin.mediation.nativeAds.MaxNativeAdLoader
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class MaxNativeAdViewFactory(
    private val adViewsPool: HashMap<String, View?>,
    private val adLoadersPool: HashMap<String, MaxNativeAdLoader>,
) :
    PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
        if (context == null) return buildEmptyPlatformView()
        val creationParams = args as? Map<*, *>
        val adKey = creationParams?.get("adKey")?.toString()
        if (adKey.isNullOrBlank()) {
            Log.w(
                "MaxAdFlutter",
                "adKey is null or blank. You should call plugin's loadNativeAd method to get an adKey."
            )
            return buildEmptyPlatformView()
        }
        return buildMaxPlatformView(adKey)
    }


    private fun buildMaxPlatformView(adKey: String?): PlatformView {
        val adLoader = adLoadersPool[adKey]
        val adView = adViewsPool[adKey]
        if (adLoader == null) {
            Log.w(
                "MaxAdFlutter",
                "adLoader with adKey: $adKey not found. You should call plugin's loadNativeAd method to get an adKey."
            )
        }
        if (adView == null) {
            Log.w(
                "MaxAdFlutter",
                "adLoader with adKey: $adKey not found. You should call plugin's loadNativeAd method to get an adKey."
            )
        }
        return object : PlatformView {
            override fun getView(): View? = adView

            override fun dispose() {
                adLoader?.destroy()
                adLoadersPool.remove(adKey)
                adViewsPool.remove(adKey)
            }
        }
    }
}
