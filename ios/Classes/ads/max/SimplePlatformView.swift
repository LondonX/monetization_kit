//
//  Utils.swift
//  max_ad_flutter
//
//  Created by LondonX on 2022/6/16.
//

import Foundation
import Flutter
import AppLovinSDK

class SimplePlatformView : NSObject, FlutterPlatformView {
    let uiView: UIView?
    let onDispose:(()->())?
    init(
        uiView: UIView? = nil,
        onDispose:(()->())? = nil
    ) {
        self.uiView = uiView
        self.onDispose = onDispose
    }
    deinit {
        uiView?.removeFromSuperview()
        onDispose?()
    }
    
    func view() -> UIView {
        if(uiView != nil) {
            ALUtils.topViewControllerFromKeyWindow().view?.addSubview(uiView!)
        }
        return self.uiView ?? UIView()
    }
}
