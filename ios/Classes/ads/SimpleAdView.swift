//
//  SimpleAdView.swift
//  monetization_kit
//
//  Created by LondonX on 2023/3/23.
//

import Foundation
import google_mobile_ads

class SimpleAdView : GADNativeAdView{
    internal let _viewMediaContainer = UIView()
    internal let _viewInfoContainer = UIView()
    internal let _imageView = UIImageView()
    internal let _mediaView = GADMediaView()
    internal let _iconView = UIImageView()
    internal let _headlineView = UILabel()
    internal let _bodyView = UILabel()
    internal let _callToActionView = UIButton(type: .custom)
    
    init() {
        super.init(frame: CGRect())
        
        // add views
        addSubview(_viewMediaContainer)
        addSubview(_viewInfoContainer)
        _viewMediaContainer.addSubview(_imageView)
        _viewMediaContainer.addSubview(_mediaView)
        _viewInfoContainer.addSubview(_iconView)
        _viewInfoContainer.addSubview(_headlineView)
        _viewInfoContainer.addSubview(_bodyView)
        _viewInfoContainer.addSubview(_callToActionView)
        
        // set outlet
        headlineView = _headlineView
        bodyView = _bodyView
        callToActionView = _callToActionView
        iconView = _iconView
        imageView = _imageView
        mediaView = _mediaView
        
        // prepare constraint layout
        disableAutoresizing([
            _viewMediaContainer,
            _imageView,
            _mediaView,
            _viewInfoContainer,
            _iconView,
            _headlineView,
            _bodyView,
            _callToActionView,
        ])
        
        // setupUI (override)
        setupUI()
        applyColorScheme(nil)
        // applyAd, applyColorScheme (optional)
        // setupConstraints (override)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     Init UI properties such as color, font
     */
    internal func setupUI() {}
    
    /**
     Setup UI constraints such as position, size
     */
    internal func setupConstraints(_ nativeAd: GADNativeAd) -> [NSLayoutConstraint] {
        return []
    }
    
    /**
     Apply color scheme
     */
    func applyColorScheme(_ colorScheme: ColorScheme?) {
        let placeholder = (colorScheme?.onSurface.v ?? UIColor.black).withAlphaComponent(0.8)
        _headlineView.textColor = colorScheme?.onSurface.v ?? .darkText
        _bodyView.textColor = colorScheme?.onSurface.v ?? .darkText
        _viewMediaContainer.backgroundColor = colorScheme?.surface.v ?? .systemBackground
        _viewInfoContainer.backgroundColor = (colorScheme?.surface.v ?? .systemBackground).withAlphaComponent(0.8)
        _imageView.backgroundColor = placeholder
        _callToActionView.backgroundColor = colorScheme?.primary.v ?? .systemFill
    }
    
    /**
     Apply ad
     */
    func applyAd(_ nativeAd: GADNativeAd) {
        NSLayoutConstraint.activate(setupConstraints(nativeAd))
        
        // image/media
        if(nativeAd.images?.isEmpty == false){
            _imageView.image = nativeAd.images?.first?.image
        }
        _mediaView.mediaContent = nativeAd.mediaContent
        _mediaView.contentMode = .scaleAspectFill
        // icon/title/description
        _headlineView.text = nativeAd.headline
        _bodyView.text = nativeAd.body
        if(nativeAd.icon?.image != nil){
            _iconView.image = nativeAd.icon?.image
        }
        // action
        _callToActionView.setTitle(nativeAd.callToAction, for: .normal)
        _callToActionView.isUserInteractionEnabled = false
        
        super.nativeAd = nativeAd
    }
    
    private func disableAutoresizing(_ views: [UIView]) {
        for v in views {
            v.translatesAutoresizingMaskIntoConstraints = false
        }
    }
}

