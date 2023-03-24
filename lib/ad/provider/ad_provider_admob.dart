import 'dart:async';
import 'package:flutter/material.dart';

import '../widget/ad_visibility.dart';
import 'ad_provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

const _adRequest = AdManagerAdRequest(httpTimeoutMillis: 5000);

class AdProviderAdMob extends AdProvider {
  const AdProviderAdMob({super.name = "admob"});

  @override
  Future<bool> init() async {
    final initStatus = await MobileAds.instance.initialize();
    initStatus.adapterStatuses.forEach((key, value) {
      debugLog('Adapter status for $key: ${value.description}');
    });
    return true;
  }

  @override
  bool shouldAccept(String unitId) {
    return unitId.startsWith("ca-app-pub-");
  }

  @override
  Future<Widget?> buildBannerAd({
    required String unitId,
    required bool isLarge,
    required Function() firstShow,
    required Function() onClick,
  }) async {
    final adSize = isLarge ? AdSize.largeBanner : AdSize.banner;
    final completer = Completer<bool>();
    debugLog("buildBannerAd");
    final myBanner = BannerAd(
      adUnitId: unitId,
      size: adSize,
      request: _adRequest,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugLog(
            "Admob Banner onAdLoaded. unitId: $unitId, size: ${adSize.width}x${adSize.height}",
          );
          completer.complete(true);
        },
        onAdFailedToLoad: (ad, error) {
          debugLog(
            "Admob Banner onAdFailedToLoad. unitId: $unitId, size: ${adSize.width}x${adSize.height}, error: $error",
          );
          completer.complete(false);
        },
        onAdClicked: (ad) {
          onClick();
        },
      ),
    );
    myBanner.load();
    final loaded = await completer.future;
    if (!loaded) return null;
    return AdVisibility(
      firstShow: firstShow,
      child: SizedBox(
        width: myBanner.size.width.toDouble(),
        height: myBanner.size.height.toDouble(),
        child: AdWidget(
          key: ObjectKey(myBanner),
          ad: myBanner,
        ),
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
    final size = isLarge ? "large" : "small";
    final completer = Completer<bool>();
    debugLog("Admob buildNativeAd");
    final nativeAd = NativeAd.fromAdManagerRequest(
      adUnitId: unitId,
      factoryId: "admobNative",
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          debugLog(
            "Admob Native onAdLoaded. unitId: $unitId, size: $size",
          );
          completer.complete(true);
        },
        onAdFailedToLoad: (ad, error) {
          debugLog(
            "Admob Native onAdFailedToLoad. unitId: $unitId, size: $size, error: $error",
          );
          completer.complete(false);
        },
        onAdClicked: (ad) {
          onClick();
        },
      ),
      adManagerRequest: _adRequest,
      customOptions: {
        "adSize": size,
        if (colorScheme != null) "colorScheme": colorSchemeToMap(colorScheme),
      },
    );
    nativeAd.load();
    final loaded = await completer.future;
    if (!loaded) return null;
    return AdVisibility(
      firstShow: firstShow,
      child: AdWidget(
        key: ObjectKey(nativeAd),
        ad: nativeAd,
      ),
    );
  }

  @override
  Future<InterstitialAd?> loadInterstitialAd({
    required String unitId,
    required Function() onClick,
    required Function() onShow,
    required Function() onDismiss,
  }) async {
    final completer = Completer<InterstitialAd?>();
    final startAt = DateTime.now();
    int getTimeConsume() => DateTime.now().difference(startAt).inSeconds;
    debugLog("Admob loadInterstitialAd");
    InterstitialAd.load(
      adUnitId: unitId,
      request: _adRequest,
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugLog(
            "Admob Interstitial onAdLoaded. unitId: $unitId, time consume: ${getTimeConsume()}s",
          );
          completer.complete(ad);
        },
        onAdFailedToLoad: (error) {
          debugLog(
            "Admob Interstitial onAdFailedToLoad. unitId: $unitId, error: $error, time consume: ${getTimeConsume()}s",
          );
          completer.complete(null);
        },
      ),
    );
    final ad = await completer.future;
    ad?.fullScreenContentCallback = FullScreenContentCallback(
      onAdClicked: (ad) {
        onClick();
      },
      onAdShowedFullScreenContent: (ad) {
        onShow();
      },
      onAdDismissedFullScreenContent: (ad) {
        onDismiss();
      },
    );
    return ad;
  }

  @override
  showInterstitialAdIfLoaded(Object interstitialAd) {
    if (interstitialAd is! InterstitialAd) return;
    interstitialAd.show();
  }

  @override
  Future<RewardedAd?> loadRewardedAd({
    required String unitId,
    required Function() onClick,
    required Function() onShow,
    required Function() onDismiss,
  }) async {
    final completer = Completer<RewardedAd?>();
    final startAt = DateTime.now();
    int getTimeConsume() => DateTime.now().difference(startAt).inSeconds;
    debugLog("Admob loadRewardedAd");
    RewardedAd.load(
      adUnitId: unitId,
      request: _adRequest,
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugLog(
            "Admob rewarded onAdLoaded. unitId: $unitId, time consume: ${getTimeConsume()}s",
          );
          completer.complete(ad);
        },
        onAdFailedToLoad: (error) {
          debugLog(
            "Admob rewarded onAdFailedToLoad. unitId: $unitId, error: $error, time consume: ${getTimeConsume()}s",
          );
          completer.complete(null);
        },
      ),
    );
    final ad = await completer.future;
    ad?.fullScreenContentCallback = FullScreenContentCallback(
      onAdClicked: (ad) {
        onClick();
      },
      onAdShowedFullScreenContent: (ad) {
        onShow();
      },
      onAdDismissedFullScreenContent: (ad) {
        onDismiss();
      },
    );
    return ad;
  }

  @override
  Future<bool> showRewardedAdIfLoaded(Object rewardedAd) async {
    if (rewardedAd is! RewardedAd) return false;
    final completer = Completer<bool>();
    rewardedAd.show(
      onUserEarnedReward: (ad, rewarded) {
        debugLog("Admob RewardedAd onUserEarnedReward");
        completer.complete(true);
      },
    );
    return await completer.future;
  }
}
