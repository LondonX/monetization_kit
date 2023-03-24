import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'load_result.dart';

class MaxAdFlutter {
  static MaxAdFlutter? _instance;
  static MaxAdFlutter get instance => _instance ??= MaxAdFlutter._();
  final _channel = const MethodChannel("max_ad_flutter");

  MaxAdFlutter._() {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case "onAdClick":
          final adKey = (call.arguments as Map)["adKey"];
          adClickListeners[adKey]?.call();
          break;
        case "onFullscreenAdShow":
          final adKey = (call.arguments as Map)["adKey"];
          fullscreenAdShowListeners[adKey]?.call();
          break;
        case "onFullscreenAdDismiss":
          final adKey = (call.arguments as Map)["adKey"];
          fullscreenAdDismissListeners[adKey]?.call();
          break;
        case "onRewarded":
          final adKey = (call.arguments as Map)["adKey"];
          adRewardedListeners[adKey]?.call(true);
          break;
      }
    });
  }

  LoadResult resolveLoadResult(Map? raw) {
    if (raw == null) {
      return const LoadResult(
        adKey: null,
        error: {"code": -1, "message": "channel returns null."},
      );
    }
    try {
      return LoadResult.fromMap(Map.from(raw));
    } catch (e) {
      return const LoadResult(
        adKey: null,
        error: {"code": -2, "message": "channel returns decode failed."},
      );
    }
  }

  Future<Map<String, dynamic>?> initializeSdk() async {
    final raw = await _channel.invokeMapMethod<String, dynamic>(
      "initializeSdk",
    );
    return raw == null ? null : Map.from(raw);
  }

  Future<LoadResult> loadBannerAd(String unitId) async {
    final raw = await _channel.invokeMapMethod(
      "loadBannerAd",
      {"unitId": unitId},
    );
    return resolveLoadResult(raw);
  }

  Future<LoadResult> loadNativeAd(String unitId) async {
    final raw = await _channel.invokeMapMethod(
      "loadNativeAd",
      {"unitId": unitId},
    );
    return resolveLoadResult(raw);
  }

  Widget buildNativeAd(String adKey, {Function()? onClick}) {
    if (onClick != null) {
      adClickListeners[adKey] = onClick;
    } else {
      adClickListeners.remove(adKey);
    }
    final widgetKey = ValueKey(adKey);
    if (Platform.isAndroid) {
      return AndroidView(
        key: widgetKey,
        viewType: "max_native_ad_template",
        creationParams: {"adKey": adKey},
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
    if (Platform.isIOS) {
      return UiKitView(
        key: widgetKey,
        viewType: "max_native_ad_template",
        creationParams: {"adKey": adKey},
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
    return Center(
      child: Text(
        "MaxAdFlutter buildNativeAd for ${Platform.operatingSystem} is not implemented.",
      ),
    );
  }

  final Map<String, Function()> adClickListeners = {};
  final Map<String, Function()> fullscreenAdShowListeners = {};
  final Map<String, Function()> fullscreenAdDismissListeners = {};
  final Map<String, Function(bool)> adRewardedListeners = {};

  Widget buildBanner(String adKey, {Function()? onClick}) {
    if (onClick != null) {
      adClickListeners[adKey] = onClick;
    } else {
      adClickListeners.remove(adKey);
    }
    final params = {"adKey": adKey};
    final widgetKey = ValueKey(adKey);
    final Widget platformView;
    if (Platform.isAndroid) {
      platformView = AndroidView(
        key: widgetKey,
        viewType: "max_banner",
        creationParams: params,
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else if (Platform.isIOS) {
      platformView = UiKitView(
        key: widgetKey,
        viewType: "max_banner",
        creationParams: params,
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else {
      platformView = Center(
        child: Text(
          "MaxAdFlutter buildBanner for ${Platform.operatingSystem} is not implemented.",
        ),
      );
    }
    return SizedBox(
      height: 50,
      child: platformView,
    );
  }

  Future<LoadResult> loadInterstitialAd(
    String unitId, {
    required Function() onClick,
    required Function() onShow,
    required Function() onDismiss,
  }) async {
    final raw = await _channel.invokeMapMethod<String, dynamic>(
      "loadInterstitialAd",
      {"unitId": unitId},
    );
    final result = resolveLoadResult(raw);
    if (result.adKey != null) {
      adClickListeners[result.adKey!] = onClick;
      fullscreenAdShowListeners[result.adKey!] = onShow;
      fullscreenAdDismissListeners[result.adKey!] = onDismiss;
    }
    return result;
  }

  Future<bool> showInterstitialAd(String adKey) async {
    return true ==
        await _channel.invokeMethod<bool>(
          "showInterstitialAd",
          {"adKey": adKey},
        );
  }

  Future<LoadResult> loadRewardedAd(
    String unitId, {
    required Function() onClick,
    required Function() onShow,
    required Function() onDismiss,
  }) async {
    final raw = await _channel.invokeMapMethod<String, dynamic>(
      "loadRewardedAd",
      {"unitId": unitId},
    );
    final result = resolveLoadResult(raw);
    if (result.adKey != null) {
      adClickListeners[result.adKey!] = onClick;
      fullscreenAdShowListeners[result.adKey!] = onShow;
      fullscreenAdDismissListeners[result.adKey!] = onDismiss;
    }
    return result;
  }

  Future<bool> showRewardedAd(
    String adKey, {
    required Function(bool) onRewarded,
  }) async {
    adRewardedListeners[adKey] = onRewarded;
    return true ==
        await _channel.invokeMethod<bool>(
          "showRewardedAd",
          {"adKey": adKey},
        );
  }

  Future showMediationDebugger() async {
    await _channel.invokeMethod("showMediationDebugger");
  }
}
