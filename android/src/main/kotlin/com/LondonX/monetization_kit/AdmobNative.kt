package com.LondonX.monetization_kit

import android.annotation.SuppressLint
import android.app.Activity
import android.graphics.drawable.GradientDrawable
import android.view.LayoutInflater
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import com.LondonX.monetization_kit.entity.ColorScheme
import com.LondonX.monetization_kit.entity.FlutterColor
import com.bumptech.glide.Glide
import com.google.android.gms.ads.nativead.MediaView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class AdmobNative(private val activity: Activity) : GoogleMobileAdsPlugin.NativeAdFactory {
    override fun createNativeAd(
        nativeAd: NativeAd?, customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        if (nativeAd == null || activity.isDestroyed) return NativeAdView(activity)
        val glide = Glide.with(activity)
        val adSize = customOptions?.get("adSize")?.toString()
        val raw = customOptions?.get("colorScheme") as? Map<*, *>
        val colorScheme = raw?.let { ColorScheme.fromRaw(it) }

        @SuppressLint("InflateParams") val nativeAdView = LayoutInflater.from(activity).inflate(
            if (adSize == "small") R.layout.ad_small else R.layout.ad_large,
            null,
            false,
        ) as NativeAdView
        val contentContainer = nativeAdView.findViewById<View>(R.id.content_container) ?: null
        // mediaView/imageView
        val imageView = nativeAdView.findViewById<ImageView>(R.id.ad_img) ?: null
        if (imageView != null) {
            if (nativeAd.images.isNotEmpty()) {
                val image = nativeAd.images.first()
                glide.load(image.drawable ?: image.uri).into(imageView)
            }
        }
        val mediaView = nativeAdView.findViewById<MediaView>(R.id.ad_media) ?: null
        if (mediaView != null) {
            if (nativeAd.mediaContent != null) {
                mediaView.setImageScaleType(ImageView.ScaleType.CENTER_CROP)
                mediaView.mediaContent = nativeAd.mediaContent!!
                imageView?.visibility = View.INVISIBLE
                mediaView.visibility = View.VISIBLE
            } else {
                imageView?.visibility = View.VISIBLE
                mediaView.visibility = View.INVISIBLE
            }
        }
        // icon/title/description
        val iconView = nativeAdView.findViewById<ImageView>(R.id.ad_icon) ?: null
        if (iconView != null) {
            if (nativeAd.icon != null) {
                iconView.visibility = View.VISIBLE
                if (nativeAd.icon!!.drawable != null) {
                    iconView.setImageDrawable(nativeAd.icon!!.drawable)
                } else {
                    glide.load(nativeAd.icon!!.uri).into(iconView)
                }
            } else {
                iconView.visibility = View.GONE
            }
        }
        val title = nativeAdView.findViewById<TextView>(R.id.ad_title)
        title.text = nativeAd.headline
        val description = nativeAdView.findViewById<TextView>(R.id.ad_desc)
        description.text = nativeAd.body
        // button
        val button = nativeAdView.findViewById<TextView>(R.id.ad_btn)
        button.text = nativeAd.callToAction
        // setup
        nativeAdView.imageView = imageView
        nativeAdView.mediaView = mediaView
        nativeAdView.iconView = iconView
        nativeAdView.headlineView = title
        nativeAdView.bodyView = description
        nativeAdView.callToActionView = button
        nativeAdView.setNativeAd(nativeAd)
        // set colors
        if (colorScheme != null) {
            val placeholder: FlutterColor = colorScheme.onSurface.copy(a = 0x11)
            val container: FlutterColor = colorScheme.surface.copy(a = 0x80)
            val textColor: FlutterColor = colorScheme.onSurface
            val textColorSecondary: FlutterColor = colorScheme.onSurface.copy(a = 0x80)
            nativeAdView.setBackgroundColor(colorScheme.surface.v)
            imageView?.setBackgroundColor(placeholder.v)
            mediaView?.setBackgroundColor(placeholder.v)
            iconView?.setBackgroundColor(placeholder.v)
            contentContainer?.setBackgroundColor(container.v)
            title.setTextColor(textColor.v)
            description.setTextColor(textColorSecondary.v)
            button.setTextColor(colorScheme.onPrimary.v)
            (button.background.mutate() as GradientDrawable).setColor(colorScheme.primary.v)
        }
        return nativeAdView
    }
}



