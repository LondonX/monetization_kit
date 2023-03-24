import Flutter
import UIKit
import google_mobile_ads
import FBAudienceNetwork
import GoogleMobileAdsMediationTestSuite

public class MonetizationKitPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "monetization_kit", binaryMessenger: registrar.messenger())
        let instance = MonetizationKitPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String : Any]
        switch(call.method) {
        case "initAds":
          let withAdmob = args?["withAdmob"] as? Bool ?? false
          if(withAdmob) {
              FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
                UIApplication.shared.delegate as! FlutterAppDelegate,
                factoryId: "admobNative",
                nativeAdFactory: AdmobNative()
              )
              // Admob mediations
              FBAdSettings.setAdvertiserTrackingEnabled(true)
          }
          result(true)
          break
        case "startAdmobMediationTest":
            let viewController = UIApplication.shared.delegate?.window??.rootViewController;
            GoogleMobileAdsMediationTestSuite.present(on:viewController!, delegate:nil)
            break
        default:
          break
        }
    }
}
