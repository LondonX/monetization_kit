//
//  MaxNativeAdViewFactory.swift
//  max_ad_flutter
//
//  Created by LondonX on 2022/6/16.
//

import Foundation
import Flutter
import AppLovinSDK

class MaxNativeAdViewFactory : NSObject, FlutterPlatformViewFactory {
    let maxAdHelper: MaxAdHelper
    init(maxAdHelper: MaxAdHelper) {
        self.maxAdHelper = maxAdHelper
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
        let view = maxAdHelper.adViewsPool[adKey!]
        let ad = maxAdHelper.adsPool[adKey!]
        let adLoader = maxAdHelper.adLoadersPool[adKey!]
        
        let adView = view as? MAAdView
        adView?.frame = CGRect(x: 0, y: 0, width: 320, height: 50)
        return SimplePlatformView(uiView: view as? UIView) {
            if(ad == nil) {
                return
            }
            adLoader?.destroy(ad!)
            self.maxAdHelper.adLoadersPool.removeValue(forKey: adKey!)
            self.maxAdHelper.adsPool.removeValue(forKey: adKey!)
            self.maxAdHelper.adViewsPool.removeValue(forKey: adKey!)
        }
    }
}
