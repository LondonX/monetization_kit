//
//  BannerAdDelegate.swift
//  max_ad_flutter
//
//  Created by LondonX on 2022/6/21.
//

import Foundation
import AppLovinSDK

class BannerAdDelegate : NSObject, MAAdViewAdDelegate {
    private var onClick:((_ ad: MAAd)->Void)?
    private var onLoad:((_ ad: MAAd)->Void)?
    private var onFailToLoad:((_ unitId: String, _ error: MAError)->Void)?
    
    init(
        onClick:((_ ad: MAAd)->Void)? = nil,
        onLoad:((_ ad: MAAd)->Void)? = nil,
        onFailToLoad:((_ unitId: String, _ error: MAError)->Void)? = nil
    ){
        self.onClick = onClick
        self.onLoad = onLoad
        self.onFailToLoad = onFailToLoad
    }
    
    func didExpand(_ ad: MAAd) { }
    
    func didCollapse(_ ad: MAAd) { }
    
    func didLoad(_ ad: MAAd) {
        onLoad?(ad)
    }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        onFailToLoad?(adUnitIdentifier, error)
    }
    
    func didDisplay(_ ad: MAAd) { }
    
    func didHide(_ ad: MAAd) { }
    
    func didClick(_ ad: MAAd) {
        onClick?(ad)
    }
    
    func didFail(toDisplay ad: MAAd, withError error: MAError) { }
}
