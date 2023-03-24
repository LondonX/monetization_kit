import 'package:flutter/material.dart';
import 'package:monetization_kit/monetization_kit.dart';

abstract class AdProvider {
  final String name;
  const AdProvider({required this.name});

  void debugLog(Object? object) {
    if (!MonetizationKit.debug) return;
    // ignore: avoid_print
    print("[AdProvider]($name)$object");
  }

  Map<String, dynamic> colorSchemeToMap(ColorScheme colorScheme) {
    return {
      "brightness": colorScheme.brightness.name,
      "primary": colorScheme.primary.value,
      "onPrimary": colorScheme.onPrimary.value,
      "secondary": colorScheme.secondary.value,
      "onSecondary": colorScheme.onSecondary.value,
      "error": colorScheme.error.value,
      "onError": colorScheme.onError.value,
      "background": colorScheme.background.value,
      "onBackground": colorScheme.onBackground.value,
      "surface": colorScheme.surface.value,
      "onSurface": colorScheme.onSurface.value,
    };
  }

  Future<bool> init();

  bool shouldAccept(String unitId);

  ///
  /// build native ad
  ///
  Future<Widget?> buildNativeAd({
    required String unitId,
    required bool isLarge,
    required Function() firstShow,
    required Function() onClick,
    ColorScheme? colorScheme,
  });

  ///
  /// build banner ad
  ///
  Future<Widget?> buildBannerAd({
    required String unitId,
    required bool isLarge,
    required Function() firstShow,
    required Function() onClick,
  });

  ///
  /// load interstitial ad
  /// call [showInterstitialAdIfLoaded] to show
  /// return loaded ad
  ///
  Future<Object?> loadInterstitialAd({
    required String unitId,
    required Function() onClick,
    required Function() onShow,
    required Function() onDismiss,
  });

  ///
  /// show interstitial ad
  /// call [loadInterstitialAd] to load
  ///
  void showInterstitialAdIfLoaded(Object interstitialAd);

  ///
  /// load rewarded ad
  /// call [showRewardedAdIfLoaded] to show
  /// return loaded ad
  ///
  Future<Object?> loadRewardedAd({
    required String unitId,
    required Function() onClick,
    required Function() onShow,
    required Function() onDismiss,
  });

  ///
  /// show rewarded ad
  /// return true if finish and got reward
  ///
  Future<bool> showRewardedAdIfLoaded(Object rewardedAd);
}
