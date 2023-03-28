//
//  NaticeAdDelegate.swift
//  max_ad_flutter
//
//  Created by LondonX on 2022/6/16.
//

import Foundation
import AppLovinSDK

class NativeAdDelegate : NSObject, MANativeAdDelegate {
    private var onClick:((_ ad: MAAd)->Void)?
    private var onLoad:((_ nativeAdView: MANativeAdView?, _ ad: MAAd)->Void)?
    private var onFailToLoad:((_ unitId: String, _ error: MAError)->Void)?
    
    init(
        onClick: ((_ ad: MAAd)->Void)? = nil,
        onLoad: ((_ nativeAdView: MANativeAdView?, _ ad: MAAd)->Void)? = nil,
        onFailToLoad: ((_ unitId: String, _ error: MAError)->Void)? = nil
    ) {
        self.onClick = onClick
        self.onLoad = onLoad
        self.onFailToLoad = onFailToLoad
    }
    
    func didClickNativeAd(_ ad: MAAd) {
        onClick?(ad)
    }
    
    func didLoadNativeAd(_ nativeAdView: MANativeAdView?, for ad: MAAd) {
        onLoad?(nativeAdView, ad)
    }
    
    func didFailToLoadNativeAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        onFailToLoad?(adUnitIdentifier, error)
    }
}
