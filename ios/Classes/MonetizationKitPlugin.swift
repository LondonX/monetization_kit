import Flutter
import UIKit
import google_mobile_ads
import FBAudienceNetwork
import GoogleMobileAdsMediationTestSuite

public class MonetizationKitPlugin: NSObject, FlutterPlugin {
    private let maxAdHelper: MaxAdHelper
    
    init(maxAdHelper: MaxAdHelper) {
        self.maxAdHelper = maxAdHelper
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "monetization_kit", binaryMessenger: registrar.messenger())
        let instance = MonetizationKitPlugin(maxAdHelper: MaxAdHelper(channel: channel, registrar: registrar))
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if(maxAdHelper.handle(call, result: result)) {
            return
        }
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
