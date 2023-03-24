//
//  MaxBannerAdViewFactory.swift
//  max_ad_flutter
//
//  Created by LondonX on 2022/6/20.
//

import Foundation
import AppLovinSDK

class MaxBannerAdViewFactory : NSObject, FlutterPlatformViewFactory {
    let pluginInstance: SwiftMaxAdFlutterPlugin
    
    init(pluginInstance: SwiftMaxAdFlutterPlugin) {
        self.pluginInstance = pluginInstance
        super.init()
    }
    
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
    
    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        let creationParams = args as? [String : Any]
        let adKey = creationParams?["adKey"] as? String
        if(adKey == nil) {
            return SimplePlatformView()
        }
        let view = pluginInstance.adViewsPool[adKey!]
        let adView = view as? MAAdView
        adView?.frame = CGRect(x: 0, y: 0, width: 320, height: 50)
        return SimplePlatformView(uiView: view as? UIView) {
            adView?.stopAutoRefresh()
            self.pluginInstance.adViewsPool.removeValue(forKey: adKey!)
        }
    }
}
