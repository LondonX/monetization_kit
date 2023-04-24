import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'load_result.dart';

class MaxAdHelper {
  static MaxAdHelper instance = MaxAdHelper._();
  late MethodChannel _channel;

  MaxAdHelper._();
  setChannel(MethodChannel channel) {
    _channel = channel;
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case "max_onAdClick":
          final adKey = (call.arguments as Map)["adKey"];
          adClickListeners[adKey]?.call();
          break;
        case "max_onFullscreenAdShow":
          final adKey = (call.arguments as Map)["adKey"];
          fullscreenAdShowListeners[adKey]?.call();
          break;
        case "max_onFullscreenAdDismiss":
          final adKey = (call.arguments as Map)["adKey"];
          fullscreenAdDismissListeners[adKey]?.call();
          break;
        case "max_onRewarded":
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
        error: {"code": -1, "message": "_channel returns null."},
      );
    }
    try {
      return LoadResult.fromMap(Map.from(raw));
    } catch (e) {
      return const LoadResult(
        adKey: null,
        error: {"code": -2, "message": "_channel returns decode failed."},
      );
    }
  }

  Future<Map<String, dynamic>?> initializeSdk() async {
    final raw = await _channel.invokeMapMethod<String, dynamic>(
      "max_initializeSdk",
    );
    return raw == null ? null : Map.from(raw);
  }

  Future<LoadResult> loadBannerAd(String unitId) async {
    final raw = await _channel.invokeMapMethod(
      "max_loadBannerAd",
      {"unitId": unitId},
    );
    return resolveLoadResult(raw);
  }

  Future<LoadResult> loadNativeAd(String unitId) async {
    final raw = await _channel.invokeMapMethod(
      "max_loadNativeAd",
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
        "MaxAdHelper buildNativeAd for ${Platform.operatingSystem} is not implemented.",
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
          "MaxAdHelper buildBanner for ${Platform.operatingSystem} is not implemented.",
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
      "max_loadInterstitialAd",
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
          "max_showInterstitialAd",
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
      "max_loadRewardedAd",
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
          "max_showRewardedAd",
          {"adKey": adKey},
        );
  }

  Future<LoadResult> loadAppOpenAd(
    String unitId, {
    required Function() onClick,
    required Function() onShow,
    required Function() onDismiss,
  }) async {
    final raw = await _channel.invokeMapMethod<String, dynamic>(
      "max_loadAppOpenAd",
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

  Future<bool> showAppOpenAd(
    String adKey, {
    required Function(bool) onAppOpen,
  }) async {
    return true ==
        await _channel.invokeMethod<bool>(
          "max_showAppOpenAd",
          {"adKey": adKey},
        );
  }

  Future<void> showMediationDebugger() async {
    await _channel.invokeMethod("max_showMediationDebugger");
  }
}
