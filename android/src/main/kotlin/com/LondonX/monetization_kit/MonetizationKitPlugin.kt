package com.LondonX.monetization_kit

import android.app.Activity
import com.google.android.ads.mediationtestsuite.MediationTestSuite
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class MonetizationKitPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private lateinit var flutterEngine: FlutterEngine

    private var activity: Activity? = null
    private val requireActivity get() = activity!!

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "monetization_kit")
        channel.setMethodCallHandler(this)

        @Suppress("DEPRECATION")
        flutterEngine = flutterPluginBinding.flutterEngine
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        val args = call.arguments as? Map<*, *>
        when (call.method) {
            "initAds" -> {
                val withAdmob = args?.get("withAdmob") == true
                if (withAdmob) {
                    GoogleMobileAdsPlugin.registerNativeAdFactory(
                        flutterEngine,
                        "admobNative",
                        AdmobNative(requireActivity),
                    )
                }
                result.success(true)
            }
            "startAdmobMediationTest" -> MediationTestSuite.launch(requireActivity)
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }
}
