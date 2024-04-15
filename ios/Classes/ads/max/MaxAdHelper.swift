import Flutter
import UIKit
import AppLovinSDK
import AppTrackingTransparency

public class MaxAdHelper: NSObject {
    private let channel: FlutterMethodChannel
    
    init(channel: FlutterMethodChannel, registrar: FlutterPluginRegistrar) {
        self.channel = channel
        super.init()
        registrar.register(
            MaxNativeAdViewFactory(maxAdHelper: self),
            withId: "max_native_ad_template"
        )
        registrar.register(
            MaxBannerAdViewFactory(maxAdHelper: self),
            withId: "max_banner"
        )
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) -> Bool {
        let args = call.arguments as? Dictionary<String, Any>
        switch call.method {
        case "max_initializeSdk":
            initSdk(result: result)
            break
        case "max_loadBannerAd":
            let unitId = args?["unitId"] as? String
            loadBannerAd(unitId: unitId ?? "", result: result)
            break
        case "max_loadNativeAd":
            let unitId = args?["unitId"] as? String
            loadNativeAd(unitId: unitId ?? "", result: result)
            break
        case "max_loadInterstitialAd":
            let unitId = args?["unitId"] as? String
            loadInterstitialAd(unitId: unitId ?? "", result: result)
            break
        case "max_showInterstitialAd":
            let adKey = args?["adKey"] as? String
            showInterstitialAd(adKey: adKey ?? "", result: result)
            break
        case "max_loadRewardedAd":
            let unitId = args?["unitId"] as? String
            loadRewardedAd(unitId: unitId ?? "", result: result)
            break
        case "max_showRewardedAd":
            let adKey = args?["adKey"] as? String
            showRewardedAd(adKey: adKey ?? "", result: result)
            break
        case "max_loadAppOpenAd":
            let unitId = args?["unitId"] as? String
            loadAppOpenAd(unitId: unitId ?? "", result: result)
            break
        case "max_showAppOpenAd":
            let adKey = args?["adKey"] as? String
            showAppOpenAd(adKey: adKey ?? "", result: result)
            break
        case "max_showMediationDebugger":
            ALSdk.shared().showMediationDebugger()
            break
        default:
            return false
        }
        return true
    }
    
    private func initSdk(result: @escaping FlutterResult) {
        ALSdk.shared().initializeSdk { (configuration: ALSdkConfiguration) in
        }
        let configMap = alSdkConfigToMap(config: ALSdk.shared().configuration)
        result(configMap)
    }
    
    public var adLoadersPool: [String : MANativeAdLoader] = [:]
    public var adsPool: [String : MAAd] = [:]
    public var adViewsPool: [String : UIView?] = [:]
    public var interstitialAdsPool: [String : MAInterstitialAd] = [:]
    public var appOpenAdsPool: [String : MAAppOpenAd] = [:]
    public var rewardedAdsPool: [String : MARewardedAd] = [:]
    
    //MARK: - Banner Ad
    private var bannerDelegate: BannerAdDelegate!
    private func loadBannerAd(unitId: String, result: @escaping FlutterResult) {
        let adView = MAAdView(adUnitIdentifier: unitId)
        adView.backgroundColor = UIColor.white
        let adKey = UUID.init().uuidString
        self.bannerDelegate = BannerAdDelegate(
            onClick: {ad in
                self.channel.invokeMethod("max_onAdClick", arguments: ["adKey" : adKey])
            },
            onLoad: {ad in
                self.adViewsPool[adKey] = adView
                result([
                    "adKey" : adKey,
                    "error" : nil,
                ])
            },
            onFailToLoad: { unitId, error in
                result([
                    "adKey" : nil,
                    "error" : maErrorToMap(error: error),
                ])
            }
        )
        adView.delegate = self.bannerDelegate
        adView.loadAd()
    }
    
    //MARK: - Native Ad
    private var nativeDelegate: NativeAdDelegate? = nil
    private func loadNativeAd(unitId: String, result: @escaping FlutterResult) {
        let adLoader = MANativeAdLoader(adUnitIdentifier: unitId)
        let adKey = UUID.init().uuidString
        self.nativeDelegate = NativeAdDelegate(
            onClick: {ad in
                self.channel.invokeMethod("max_onAdClick", arguments: ["adKey" : adKey])
            },
            onLoad: { nativeAdView, ad in
                self.adLoadersPool[adKey] = adLoader
                self.adsPool[adKey] = ad
                self.adViewsPool[adKey] = nativeAdView
                result([
                    "adKey" : adKey,
                    "error" : nil,
                ])
            },
            onFailToLoad: { unitId, error in
                result([
                    "adKey" : nil,
                    "error" : maErrorToMap(error: error),
                ])
            }
        )
        adLoader.nativeAdDelegate = self.nativeDelegate
        adLoader.loadAd()
    }
    //MARK: - Interstitial Ad
    private var interstitialDelegate: FullscreenAdDelegate? = nil
    func loadInterstitialAd(unitId: String, result: @escaping FlutterResult) {
        let adKey = UUID.init().uuidString
        let interstitialAd = MAInterstitialAd(adUnitIdentifier: unitId)
        self.interstitialDelegate = FullscreenAdDelegate(
            onClick: {ad in
                self.channel.invokeMethod("max_onAdClick", arguments: ["adKey" : adKey])
            },
            onLoad: {ad in
                self.interstitialAdsPool[adKey] = interstitialAd
                result([
                    "adKey" : adKey,
                    "error" : nil,
                ])
            },
            onFailToLoad: {unitId, error in
                result([
                    "adKey" : nil,
                    "error" : maErrorToMap(error: error),
                ])
            },
            onShow: { ad in
                self.channel.invokeMethod(
                    "max_onFullscreenAdShow",
                    arguments: [
                        "adKey" : adKey,
                    ])
            },
            onClose: { ad in
                self.channel.invokeMethod(
                    "max_onFullscreenAdDismiss",
                    arguments: [
                        "adKey" : adKey,
                    ])
            }
        )
        interstitialAd.delegate = self.interstitialDelegate
        interstitialAd.load()
    }
    
    func showInterstitialAd(adKey: String, result: @escaping FlutterResult) {
        let interstitialAd = interstitialAdsPool[adKey]
        if (interstitialAd == nil) {
            print(
                "MaxAdFlutter",
                "InterstitialAd with adKey: $adKey not found. You should call plugin's loadInterstitialAd method to get an adKey."
            )
            result(false)
            return
        }
        if (!interstitialAd!.isReady) {
            print(
                "MaxAdFlutter",
                "InterstitialAd with adKey: $adKey not ready."
            )
            result(false)
            return
        }
        interstitialAd!.show()
        result(true)
    }
    
    //MARK: - Rewarded Ad
    private var rewardedDelegate: FullscreenAdDelegate? = nil
    func loadRewardedAd(unitId: String, result: @escaping FlutterResult) {
        let adKey = UUID.init().uuidString
        let rewardedAd = MARewardedAd.shared(withAdUnitIdentifier: unitId)
        self.rewardedDelegate = FullscreenAdDelegate(
            onClick: {ad in
                self.channel.invokeMethod("max_onAdClick", arguments: ["adKey" : adKey])
            },
            onLoad: {ad in
                self.rewardedAdsPool[adKey] = rewardedAd
                result([
                    "adKey" : adKey,
                    "error" : nil,
                ])
            },
            onFailToLoad: {unitId, error in
                result([
                    "adKey" : nil,
                    "error" : maErrorToMap(error: error),
                ])
            },
            onShow: { ad in
                self.channel.invokeMethod(
                    "max_onFullscreenAdShow",
                    arguments: [
                        "adKey" : adKey,
                    ])
            },
            onClose: { ad in
                self.channel.invokeMethod(
                    "max_onFullscreenAdDismiss",
                    arguments: [
                        "adKey" : adKey,
                    ])
            },
            onRewarded: { ad in
                self.channel.invokeMethod(
                    "max_onRewarded",
                    arguments: [
                        "adKey" : adKey,
                    ])
            }
        )
        rewardedAd.delegate = self.rewardedDelegate
        rewardedAd.load()
    }
    
    func showRewardedAd(adKey: String, result: @escaping FlutterResult) {
        let rewardedAd = rewardedAdsPool[adKey]
        if (rewardedAd == nil) {
            print(
                "MaxAdFlutter",
                "RewardedAd with adKey: $adKey not found. You should call plugin's loadRewardedAd method to get an adKey."
            )
            result(false)
            return
        }
        if (!rewardedAd!.isReady) {
            print(
                "MaxAdFlutter",
                "RewardedAd with adKey: $adKey not ready."
            )
            result(false)
            return
        }
        rewardedAd!.show()
        result(true)
    }
    
    //MARK: - AppOpen Ad
    private var appOpenDelegate: FullscreenAdDelegate? = nil
    func loadAppOpenAd(unitId: String, result: @escaping FlutterResult) {
        let adKey = UUID.init().uuidString
        let appOpenAd = MAAppOpenAd(adUnitIdentifier: unitId)
        self.appOpenDelegate = FullscreenAdDelegate(
            onClick: {ad in
                self.channel.invokeMethod("max_onAdClick", arguments: ["adKey" : adKey])
            },
            onLoad: {ad in
                self.appOpenAdsPool[adKey] = appOpenAd
                result([
                    "adKey" : adKey,
                    "error" : nil,
                ])
            },
            onFailToLoad: {unitId, error in
                result([
                    "adKey" : nil,
                    "error" : maErrorToMap(error: error),
                ])
            },
            onShow: { ad in
                self.channel.invokeMethod(
                    "max_onFullscreenAdShow",
                    arguments: [
                        "adKey" : adKey,
                    ])
            },
            onClose: { ad in
                self.channel.invokeMethod(
                    "max_onFullscreenAdDismiss",
                    arguments: [
                        "adKey" : adKey,
                    ])
            }
        )
        appOpenAd.delegate = self.appOpenDelegate
        appOpenAd.load()
    }
    
    func showAppOpenAd(adKey: String, result: @escaping FlutterResult) {
        let appOpenAd = appOpenAdsPool[adKey]
        if (appOpenAd == nil) {
            print(
                "MaxAdFlutter",
                "AppOpenAd with adKey: $adKey not found. You should call plugin's loadAppOpenAd method to get an adKey."
            )
            result(false)
            return
        }
        if (!appOpenAd!.isReady) {
            print(
                "MaxAdFlutter",
                "AppOpenAd with adKey: $adKey not ready."
            )
            result(false)
            return
        }
        appOpenAd!.show()
        result(true)
    }
}

func alSdkConfigToMap(config: ALSdkConfiguration) -> [String : Any] {
    return [
        "countryCode" : config.countryCode,
        "consentDialogState" : config.consentDialogState.rawValue,
    ]
}

func maErrorToMap(error: MAError) -> [String : Any?] {
    return [
        "code": error.code.rawValue,
        "message": error.message,
        "mediatedNetworkErrorCode" : error.mediatedNetworkErrorCode,
        "mediatedNetworkErrorMessage" : error.mediatedNetworkErrorMessage,
    ]
}
