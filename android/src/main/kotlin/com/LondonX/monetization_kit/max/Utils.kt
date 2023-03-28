package com.LondonX.monetization_kit.max

import android.view.View
import io.flutter.plugin.platform.PlatformView

fun buildEmptyPlatformView(): PlatformView {
    return object : PlatformView {
        override fun getView(): View? = null

        override fun dispose() {
        }
    }
}