//
//  NativeAdFactory.swift
//  Runner
//
//  Created by LondonX on 2022/6/6.
//

import Foundation
import google_mobile_ads

class AdmobNative : FLTNativeAdFactory {
    func createNativeAd(
        _ nativeAd: GADNativeAd,
        customOptions: [AnyHashable : Any]? = nil
    ) -> GADNativeAdView? {
        let adSize = customOptions?["adSize"] as? String
        let rawColorScheme = customOptions?["colorScheme"] as? [String : Any]
        let colorScheme = rawColorScheme == nil ? nil : ColorScheme.fromRaw(raw: rawColorScheme!)
        
        let nativeAdView = adSize == "small" ? AdSmall() : AdLarge()
        nativeAdView.applyAd(nativeAd)
        // set color
        if (colorScheme != nil) {
            nativeAdView.applyColorScheme(colorScheme!)
        }
        return nativeAdView
    }
    
    var defaultIconLeading: CGFloat = 0
    var defaultIconWidth: CGFloat = 0
    private func setLargeAdIconHidden(adView: GADNativeAdView, isHidden: Bool){
        let iconLeading = adView.iconView?.constraints.first(where: { constraint in
            return constraint.identifier == "iconLeading"
        })
        if(defaultIconLeading == 0) {
            defaultIconLeading = iconLeading?.constant ?? 0
        }
        iconLeading?.constant = isHidden ? 0 : defaultIconLeading
        let iconWidth = adView.iconView?.constraints.first(where: { constraint in
            return constraint.identifier == "iconWidth"
        })
        if(defaultIconWidth == 0) {
            defaultIconWidth = iconWidth?.constant ?? 0
        }
        iconWidth?.constant = isHidden ? 0 : defaultIconWidth
    }
    
    var defaultIconVertical: CGFloat = 0
    var defaultIconHeight: CGFloat = 0
    var defaultButtonVertical: CGFloat = 0
    private func setSmallAdIconHidden(adView: GADNativeAdView, isHidden: Bool){
        let iconVertical = adView.iconView?.constraints.first(where: { constraint in
            return constraint.identifier == "iconVertical"
        })
        let iconHeight = adView.iconView?.constraints.first(where: { constraint in
            return constraint.identifier == "iconHeight"
        })
        let buttonVertical = adView.iconView?.constraints.first(where: { constraint in
            return constraint.identifier == "buttonVertical"
        })
        if(defaultIconVertical == 0){
            defaultIconVertical = iconVertical?.constant ?? 0
        }
        if(defaultIconHeight == 0){
            defaultIconHeight = iconHeight?.constant ?? 0
        }
        if(defaultButtonVertical == 0){
            defaultButtonVertical = buttonVertical?.constant ?? 0
        }
        iconVertical?.constant = isHidden ? 0: defaultIconVertical
        iconHeight?.constant = isHidden ? 0: defaultIconHeight
        buttonVertical?.constant = isHidden ? 0: defaultButtonVertical
    }
}
