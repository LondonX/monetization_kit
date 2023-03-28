import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:monetization_kit/ad/max/max_ad_helper.dart';
import '../widget/ad_visibility.dart';
import 'ad_provider.dart';

class AdProviderMax extends AdProvider {
  const AdProviderMax({super.name = "Max"});

  MaxAdHelper get _maxAd => MaxAdHelper.instance;

  @override
  Future<bool> init() async {
    final result = await _maxAd.initializeSdk();
    debugLog(
      "Initialize finish with result: ${jsonEncode(result)}",
    );
    return true;
  }

  @override
  bool shouldAccept(String unitId) {
    return unitId.length == 16;
  }

  @override
  Future<Widget?> buildBannerAd({
    required String unitId,
    required bool isLarge,
    required Function() firstShow,
    required Function() onClick,
  }) async {
    debugLog(
      "buildBannerAd isLarge: $isLarge(ignored, max banner only supported 50 height)",
    );
    final loadResult = await _maxAd.loadBannerAd(unitId);
    if (loadResult.errorJson() != null) {
      debugLog(
        "Banner load failed. unitId: $unitId, error: ${loadResult.errorJson()}",
      );
      return null;
    }
    debugLog(
      "Banner loaded. unitId: $unitId, isLarge: $isLarge",
    );
    // Max Banner固定只有50高度
    return AdVisibility(
      firstShow: firstShow,
      child: _maxAd.buildBanner(
        loadResult.adKey!,
        onClick: onClick,
      ),
    );
  }

  @override
  Future<Widget?> buildNativeAd({
    required String unitId,
    required bool isLarge,
    required Function() firstShow,
    required Function() onClick,
    ColorScheme? colorScheme,
  }) async {
    debugLog("buildNativeAd isLarge: $isLarge(ignored colorScheme)");
    final loadResult = await _maxAd.loadNativeAd(unitId);
    if (loadResult.errorJson() != null) {
      debugLog(
        "Native load failed. unitId: $unitId, error: ${loadResult.errorJson()}",
      );
      return null;
    }
    debugLog(
      "Native loaded. unitId: $unitId, isLarge: $isLarge",
    );
    return AdVisibility(
      firstShow: firstShow,
      child: _maxAd.buildNativeAd(
        loadResult.adKey!,
        onClick: onClick,
      ),
    );
  }

  @override
  Future<Object?> loadInterstitialAd({
    required String unitId,
    required Function() onClick,
    required Function() onShow,
    required Function() onDismiss,
  }) async {
    debugLog("loadInterstitialAd unitId: $unitId");
    final loadResult = await _maxAd.loadInterstitialAd(
      unitId,
      onClick: onClick,
      onShow: onShow,
      onDismiss: onDismiss,
    );
    if (loadResult.error != null) {
      debugLog(
        "Interstitial load failed. unitId: $unitId, error: ${loadResult.errorJson()}",
      );
      return null;
    }
    debugLog("InterstitialAd loaded. unitId: $unitId");
    return loadResult.adKey;
  }

  @override
  showInterstitialAdIfLoaded(dynamic interstitialAd) {
    if (interstitialAd == null) return;
    if (interstitialAd is! String) return;
    _maxAd.showInterstitialAd(interstitialAd);
  }

  @override
  Future<Object?> loadRewardedAd({
    required String unitId,
    required Function() onClick,
    required Function() onShow,
    required Function() onDismiss,
  }) async {
    debugLog("loadRewardedAd unitId: $unitId");
    final loadResult = await _maxAd.loadRewardedAd(
      unitId,
      onClick: onClick,
      onShow: onShow,
      onDismiss: onDismiss,
    );
    if (loadResult.error != null) {
      debugLog(
        "Rewarded load failed. unitId: $unitId, error: ${loadResult.errorJson()}",
      );
      return null;
    }
    debugLog(
      "Rewarded loaded. unitId: $unitId",
    );
    return loadResult.adKey;
  }

  @override
  Future<bool> showRewardedAdIfLoaded(dynamic rewardedAd) async {
    if (rewardedAd == null) return false;
    if (rewardedAd is! String) return false;
    final completer = Completer<bool>();
    _maxAd.showRewardedAd(
      rewardedAd,
      onRewarded: (isRewarded) {
        debugLog("Rewarded finish, isRewarded: $isRewarded");
        completer.complete(isRewarded);
      },
    );
    return await completer.future;
  }
}
