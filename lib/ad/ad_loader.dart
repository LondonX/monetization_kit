import 'dart:async';
import 'package:flutter/material.dart';
import 'package:monetization_kit/monetization_kit.dart';

import 'entity/ad_enum.dart';
import 'provider/ad_provider.dart';

///
/// Ad monetization kit
/// [unitIds] Ad unit id list, multiple IDs will be switched every load.
/// [adType] Ad type.
/// [reloadInterval] Reload interval for AuoLoadingAdContainer.
/// [log] Log callback with multiple args.
/// [expiration] Cache expiration for valid check.
/// [isWaterfall] should load [unitIds] 1 by 1 on every load.
///
class AdLoader {
  final List<String> unitIds;
  final AdType adType;
  final Duration reloadInterval;
  final Duration expiration;
  final bool isWaterfall;
  final double? widgetRatioOverride;
  final Function(
    AdProvider provider,
    AdAction action,
    AdType type,
    String unitId,
  )? log;

  AdLoader({
    required this.unitIds,
    required this.adType,
    this.reloadInterval = const Duration(seconds: 30),
    this.expiration = const Duration(minutes: 30),
    this.isWaterfall = false,
    this.widgetRatioOverride,
    this.log,
  }) : assert(
          unitIds.isNotEmpty,
        );

  int _unitIndex = 0;

  ///
  /// 切换配置
  ///
  String _nextUnitId() {
    final configs = unitIds;
    final config = configs[_unitIndex];
    _unitIndex = (_unitIndex + 1) % configs.length;
    return config;
  }

  DateTime _adCachedAt = DateTime.fromMillisecondsSinceEpoch(0);
  bool get adCacheValid {
    final isFullscreenAdCached = _fullscreenAdCache != null &&
        _fullscreenCachedAdProvider != null &&
        _fullscreenCachedType != null;
    if (_widgetAdCache == null && !isFullscreenAdCached) return false;
    return DateTime.now().difference(_adCachedAt) < expiration;
  }

  Widget? _widgetAdCache;
  final _widgetAdLoadings = <Completer<Widget?>>[];
  bool _isWidgetAdLoading = false;
  Widget? get widgetAdCache => _widgetAdCache;

  ///
  /// load Widget ads (Native/Banner)
  ///
  Future<Widget?> loadWidgetAd({
    ColorScheme? colorScheme,
    bool autoConsume = true,
  }) async {
    if (adCacheValid) {
      _log("loadWidgetAd cachedAt: $_adCachedAt");
      return _widgetAdCache!;
    }
    if (_isWidgetAdLoading) {
      final completer = Completer<Widget?>();
      _widgetAdLoadings.add(completer);
      _log("loadWidgetAd current is loading, add into queue");
      return await completer.future;
    }
    _isWidgetAdLoading = true;
    if (isWaterfall) _unitIndex = 0;
    while (!adCacheValid) {
      final unitId = _nextUnitId();
      final AdProvider provider =
          MonetizationKit.instance.adProviders.firstWhere(
        (provider) => provider.shouldAccept(unitId),
      );
      _log(
        "loadWidgetAd provider: ${provider.name}, adType: ${adType.name}, unitId: $unitId",
      );
      Future<Widget?> adLoading;
      switch (adType) {
        case AdType.native:
        case AdType.nativeSmall:
          adLoading = provider.buildNativeAd(
            unitId: unitId,
            isLarge: adType == AdType.native,
            firstShow: () {
              log?.call(provider, AdAction.impress, adType, unitId);
              if (autoConsume) _consumeWidgetAd();
            },
            onClick: () {
              log?.call(provider, AdAction.click, adType, unitId);
            },
            colorScheme: colorScheme,
          );
          break;
        case AdType.banner:
        case AdType.bannerSmall:
          adLoading = provider.buildBannerAd(
            unitId: unitId,
            isLarge: adType == AdType.banner,
            firstShow: () {
              log?.call(provider, AdAction.impress, adType, unitId);
              if (autoConsume) _consumeWidgetAd();
            },
            onClick: () {
              log?.call(provider, AdAction.click, adType, unitId);
            },
          );
          break;
        case AdType.interstitial:
        case AdType.rewarded:
        case AdType.appOpen:
          throw FlutterError(
            "loadWidgetAd cannot be called with adType: ${adType.name}",
          );
      }
      _adCachedAt = DateTime.now();
      log?.call(provider, AdAction.request, adType, unitId);
      _widgetAdCache = await adLoading;
      _log(
        "loadWidgetAd load ${_widgetAdCache == null ? "failed" : "success"}",
      );
      if (_widgetAdCache == null) {
        log?.call(provider, AdAction.loadFailed, adType, unitId);
      } else {
        log?.call(provider, AdAction.loaded, adType, unitId);
      }
      // no next unit
      if (unitIds.indexOf(unitId) == unitIds.length - 1) break;
    }
    for (final completer in _widgetAdLoadings) {
      completer.complete(_widgetAdCache);
    }
    _widgetAdLoadings.clear();
    _isWidgetAdLoading = false;
    return _widgetAdCache;
  }

  Object? _fullscreenAdCache;
  AdProvider? _fullscreenCachedAdProvider;
  AdType? _fullscreenCachedType;
  final _fullscreenLoadings = <Completer<Object?>>[];
  bool _isLoadingFullscreenAd = false;

  ///
  /// load Fullscreen ads (Interstitial/Rewarded)
  ///
  Future<Object?> loadFullscreenAd() async {
    if (adCacheValid) {
      _log("loadFullscreenAd cachedAt: $_adCachedAt");
      return _fullscreenAdCache;
    }
    if (_isLoadingFullscreenAd) {
      final completer = Completer<Object?>();
      _fullscreenLoadings.add(completer);
      _log("loadFullscreenAd current is loading, add into queue");
      return await completer.future;
    }
    _isLoadingFullscreenAd = true;
    if (isWaterfall) _unitIndex = 0;
    while (!adCacheValid) {
      final unitId = _nextUnitId();
      final AdProvider provider =
          MonetizationKit.instance.adProviders.firstWhere(
        (provider) => provider.shouldAccept(unitId),
      );
      _log(
        "loadFullscreenAd provider: ${provider.name}, adType: ${adType.name}, unitId: $unitId",
      );
      final Future<Object?> adLoading;
      switch (adType) {
        case AdType.interstitial:
          adLoading = provider.loadInterstitialAd(
            unitId: unitId,
            onClick: () {
              log?.call(provider, AdAction.click, adType, unitId);
            },
            onShow: () {
              _consumeFullscreenAd();
              log?.call(provider, AdAction.impress, adType, unitId);
            },
            onDismiss: () {
              log?.call(provider, AdAction.close, adType, unitId);
            },
          );
          break;
        case AdType.rewarded:
          adLoading = provider.loadRewardedAd(
            unitId: unitId,
            onClick: () {
              log?.call(provider, AdAction.click, adType, unitId);
            },
            onShow: () {
              _consumeFullscreenAd();
              log?.call(provider, AdAction.impress, adType, unitId);
            },
            onDismiss: () {
              log?.call(provider, AdAction.close, adType, unitId);
            },
          );
          break;
        case AdType.appOpen:
          adLoading = provider.loadAppOpenAd(
            unitId: unitId,
            onClick: () {
              log?.call(provider, AdAction.click, adType, unitId);
            },
            onShow: () {
              _consumeFullscreenAd();
              log?.call(provider, AdAction.impress, adType, unitId);
            },
            onDismiss: () {
              log?.call(provider, AdAction.close, adType, unitId);
            },
          );
          break;
        //default:
        case AdType.native:
        case AdType.nativeSmall:
        case AdType.banner:
        case AdType.bannerSmall:
          throw FlutterError(
            "loadFullscreenAd cannot be called with adType: ${adType.name}",
          );
      }
      _adCachedAt = DateTime.now();
      log?.call(provider, AdAction.request, adType, unitId);
      _fullscreenAdCache = await adLoading;
      _log(
        "loadFullscreenAd load ${_fullscreenAdCache == null ? "failed" : "success"}",
      );
      if (_fullscreenAdCache == null) {
        log?.call(provider, AdAction.loadFailed, adType, unitId);
      } else {
        _fullscreenCachedType = adType;
        _fullscreenCachedAdProvider = provider;
        log?.call(provider, AdAction.loaded, adType, unitId);
      }
      // no next unit
      if (unitIds.indexOf(unitId) == unitIds.length - 1) break;
    }
    for (final completer in _fullscreenLoadings) {
      completer.complete(_fullscreenAdCache);
    }
    _fullscreenLoadings.clear();
    _isLoadingFullscreenAd = false;
    return _fullscreenAdCache;
  }

  Future<bool> showFullscreenAd() async {
    if (!adCacheValid) return false;
    bool finished = false;
    switch (_fullscreenCachedType) {
      case AdType.interstitial:
        _fullscreenCachedAdProvider?.showInterstitialAdIfLoaded(
          _fullscreenAdCache!,
        );
        finished = true;
        break;
      case AdType.rewarded:
        finished = await _fullscreenCachedAdProvider?.showRewardedAdIfLoaded(
              _fullscreenAdCache!,
            ) ??
            false;
        break;
      case AdType.appOpen:
        _fullscreenCachedAdProvider?.showAppOpenAdIfLoaded(
          _fullscreenAdCache!,
        );
        finished = true;
        break;
      //default:
      case AdType.native:
      case AdType.nativeSmall:
      case AdType.banner:
      case AdType.bannerSmall:
      case null:
        throw FlutterError(
          "showFullscreenAd cannot be called with adType: ${adType.name}",
        );
    }
    return finished;
  }

  void _consumeFullscreenAd() {
    _fullscreenAdCache = null;
    _fullscreenCachedType = null;
    _fullscreenCachedAdProvider = null;
  }

  void _consumeWidgetAd() {
    _adCachedAt = DateTime.fromMillisecondsSinceEpoch(0);
  }

  double get widgetRatio {
    if (widgetRatioOverride != null) return widgetRatioOverride!;
    switch (adType) {
      case AdType.native:
        return 16 / 9;
      case AdType.nativeSmall:
        return 5;
      case AdType.banner:
        return 6;
      case AdType.bannerSmall:
        return 7;
      case AdType.interstitial:
      case AdType.rewarded:
      case AdType.appOpen:
        return 0;
    }
  }

  _log(Object? object) {
    if (!MonetizationKit.debug) return;
    // ignore: avoid_print
    print("[AdLoader]$object");
  }
}
