//
//  InterstitialAdDelegate.swift
//  max_ad_flutter
//
//  Created by LondonX on 2022/6/21.
//

import Foundation
import AppLovinSDK

class FullscreenAdDelegate : NSObject, MAAdDelegate, MARewardedAdDelegate {
    
    private var onClick: ((_ ad: MAAd)->Void)?
    private var onLoad: ((_ ad: MAAd)->Void)?
    private var onFailToLoad: ((_ unitId: String, _ error: MAError)->Void)?
    private var onShow: ((_ ad: MAAd)->Void)?
    private var onClose: ((_ ad: MAAd)->Void)?
    private var onRewarded: ((_ ad: MAAd)->Void)?
    
    init(
        onClick:((_ ad: MAAd)->Void)? = nil,
        onLoad:((_ ad: MAAd)->Void)? = nil,
        onFailToLoad:((_ unitId: String, _ error: MAError)->Void)? = nil,
        onShow:((_ ad: MAAd)->Void)? = nil,
        onClose:((_ ad: MAAd)->Void)? = nil,
        onRewarded:((_ ad: MAAd)->Void)? = nil
    ){
        self.onClick = onClick
        self.onLoad = onLoad
        self.onFailToLoad = onFailToLoad
        self.onShow = onShow
        self.onClose = onClose
        self.onRewarded = onRewarded
    }
    
    func didLoad(_ ad: MAAd) {
        onLoad?(ad)
    }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        onFailToLoad?(adUnitIdentifier, error)
    }
    
    func didDisplay(_ ad: MAAd) {
        onShow?(ad)
    }
    
    func didHide(_ ad: MAAd) {
        onClose?(ad)
    }
    
    func didClick(_ ad: MAAd) {
        onClick?(ad)
    }
    
    func didFail(toDisplay ad: MAAd, withError error: MAError) { }
    
    // MARK: - MARewardedAdDelegate
    func didStartRewardedVideo(for ad: MAAd) { }
    
    func didCompleteRewardedVideo(for ad: MAAd) { }
    
    func didRewardUser(for ad: MAAd, with reward: MAReward) {
        onRewarded?(ad)
        onClose?(ad)
    }
}
