//
//  GADNativeAdView.swift
//  Project
//
//  Created by Author on 2023/3/23.
//  Copyright © 2023 Company. All rights reserved.
//

import UIKit
import google_mobile_ads

class AdLarge: SimpleAdView {

    override func setupUI() {
        _headlineView.numberOfLines = 1
        _headlineView.font = .systemFont(ofSize: 14)
        _bodyView.numberOfLines = 2
        _bodyView.font = .systemFont(ofSize: 12)
        _callToActionView.layer.cornerRadius = 8
        _callToActionView.titleLabel?.font = .systemFont(ofSize: 14)
        _callToActionView.titleLabel?.setContentHuggingPriority(.required, for: .horizontal)
        _callToActionView.titleLabel?.setContentCompressionResistancePriority(.required, for: .horizontal)
        applyColorScheme(nil)
    }
    
    override func setupConstraints(_ nativeAd: GADNativeAd) -> [NSLayoutConstraint] {
        let withIcon = nativeAd.icon?.image != nil
        return [
            //root
            _viewMediaContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            _viewMediaContainer.topAnchor.constraint(equalTo: topAnchor),
            _viewMediaContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            _viewMediaContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1),
            _viewInfoContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            _viewInfoContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            _viewInfoContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            _viewInfoContainer.heightAnchor.constraint(equalToConstant: 52 + 8 * 2),

            //_viewMediaContainer
            _imageView.leadingAnchor.constraint(equalTo: _viewMediaContainer.leadingAnchor),
            _imageView.topAnchor.constraint(equalTo: _viewMediaContainer.topAnchor),
            _imageView.trailingAnchor.constraint(equalTo: _viewMediaContainer.trailingAnchor),
            _imageView.bottomAnchor.constraint(equalTo: _viewMediaContainer.bottomAnchor),
            _mediaView.leadingAnchor.constraint(equalTo: _viewMediaContainer.leadingAnchor),
            _mediaView.topAnchor.constraint(equalTo: _viewMediaContainer.topAnchor),
            _mediaView.trailingAnchor.constraint(equalTo: _viewMediaContainer.trailingAnchor),
            _mediaView.bottomAnchor.constraint(equalTo: _viewMediaContainer.bottomAnchor),

            //_viewInfoContainer
            _iconView.widthAnchor.constraint(equalToConstant: 52),
            _iconView.leadingAnchor.constraint(equalTo: _viewInfoContainer.leadingAnchor, constant: 8),
            _iconView.topAnchor.constraint(equalTo: _viewInfoContainer.topAnchor, constant: 8),
            _iconView.bottomAnchor.constraint(equalTo: _viewInfoContainer.bottomAnchor, constant: -8),
            _headlineView.leadingAnchor.constraint(
                equalTo: withIcon
                ? _iconView.trailingAnchor
                : _viewInfoContainer.leadingAnchor,
                constant: 8),
            _headlineView.trailingAnchor.constraint(equalTo: _callToActionView.leadingAnchor, constant: -8),
            _headlineView.bottomAnchor.constraint(equalTo: _viewInfoContainer.centerYAnchor, constant: -6),
            _bodyView.leadingAnchor.constraint(
                equalTo: withIcon
                ? _iconView.trailingAnchor
                : _viewInfoContainer.leadingAnchor,
                constant: 8),
            _bodyView.topAnchor.constraint(equalTo: _viewInfoContainer.centerYAnchor, constant: -5),
            _bodyView.trailingAnchor.constraint(equalTo: _callToActionView.leadingAnchor, constant: -8),
            _callToActionView.centerYAnchor.constraint(equalTo: _viewInfoContainer.centerYAnchor),
            _callToActionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            _callToActionView.widthAnchor.constraint(greaterThanOrEqualToConstant: 52),
            _callToActionView.heightAnchor.constraint(equalToConstant: 32),
        ]
    }
}

