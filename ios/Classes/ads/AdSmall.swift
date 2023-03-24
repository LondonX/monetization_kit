//
//  AdSmall.swift
//  monetization_kit
//
//  Created by LondonX on 2023/3/23.
//

import Foundation
import google_mobile_ads

class AdSmall : SimpleAdView {
    
    override func setupUI() {
        _headlineView.numberOfLines = 1
        _headlineView.font = .systemFont(ofSize: 14)
        _bodyView.numberOfLines = 2
        _bodyView.font = .systemFont(ofSize: 12)
        _callToActionView.layer.cornerRadius = 8
        _callToActionView.titleLabel?.font = .systemFont(ofSize: 12)
        _callToActionView.titleLabel?.setContentHuggingPriority(.required, for: .horizontal)
        _callToActionView.titleLabel?.setContentCompressionResistancePriority(.required, for: .horizontal)
        applyColorScheme(nil)
    }
    
    override func setupConstraints(_ nativeAd: GADNativeAd) -> [NSLayoutConstraint] {
        let withIcon = nativeAd.icon?.image != nil
        return [
            _viewMediaContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 1),
            _viewMediaContainer.topAnchor.constraint(equalTo: topAnchor, constant: 1),
            _viewMediaContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1),
            _viewMediaContainer.widthAnchor.constraint(equalTo: _viewMediaContainer.heightAnchor),
            _imageView.leadingAnchor.constraint(equalTo: _viewMediaContainer.leadingAnchor),
            _imageView.topAnchor.constraint(equalTo: _viewMediaContainer.topAnchor),
            _imageView.trailingAnchor.constraint(equalTo: _viewMediaContainer.trailingAnchor),
            _imageView.bottomAnchor.constraint(equalTo: _viewMediaContainer.bottomAnchor),
            _mediaView.leadingAnchor.constraint(equalTo: _viewMediaContainer.leadingAnchor),
            _mediaView.topAnchor.constraint(equalTo: _viewMediaContainer.topAnchor),
            _mediaView.trailingAnchor.constraint(equalTo: _viewMediaContainer.trailingAnchor),
            _mediaView.bottomAnchor.constraint(equalTo: _viewMediaContainer.bottomAnchor),
            
            _viewInfoContainer.leadingAnchor.constraint(equalTo: _viewMediaContainer.trailingAnchor, constant: 8),
            _viewInfoContainer.topAnchor.constraint(equalTo: _viewMediaContainer.topAnchor),
            _viewInfoContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            _viewInfoContainer.bottomAnchor.constraint(equalTo: _viewMediaContainer.bottomAnchor),
            
            _headlineView.leadingAnchor.constraint(equalTo: _viewInfoContainer.leadingAnchor),
            _headlineView.trailingAnchor.constraint(equalTo: _callToActionView.leadingAnchor, constant: -8),
            _headlineView.bottomAnchor.constraint(equalTo: _viewInfoContainer.centerYAnchor, constant: -8),
            _bodyView.leadingAnchor.constraint(equalTo: _viewInfoContainer.leadingAnchor),
            _bodyView.topAnchor.constraint(equalTo: _viewInfoContainer.centerYAnchor, constant: -7),
            _bodyView.trailingAnchor.constraint(equalTo: _callToActionView.leadingAnchor, constant: -8),
            
            _iconView.centerXAnchor.constraint(equalTo: _callToActionView.centerXAnchor),
            _iconView.bottomAnchor.constraint(equalTo: _viewInfoContainer.centerYAnchor, constant: -2),
            _iconView.widthAnchor.constraint(equalToConstant: 32),
            _iconView.heightAnchor.constraint(equalToConstant: 32),
            
            withIcon
            ? _callToActionView.topAnchor.constraint(equalTo: _viewInfoContainer.centerYAnchor, constant: 4)
            : _callToActionView.centerYAnchor.constraint(equalTo: _viewInfoContainer.centerYAnchor),
            _callToActionView.trailingAnchor.constraint(equalTo: _viewInfoContainer.trailingAnchor),
            _callToActionView.widthAnchor.constraint(greaterThanOrEqualToConstant: 44),
            _callToActionView.heightAnchor.constraint(equalToConstant: 24),
        ]
    }
}
