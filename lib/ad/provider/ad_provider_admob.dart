import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:user_messaging_platform/user_messaging_platform.dart' as ump;
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../widget/ad_visibility.dart';
import 'ad_provider.dart';

const _adRequest = AdManagerAdRequest(httpTimeoutMillis: 5000);

class AdProviderAdMob extends AdProvider {
  const AdProviderAdMob({super.name = "Admob"});

  @override
  Future<bool> init() async {
    await _updateUmpConsent();
    final initStatus = await MobileAds.instance.initialize();
    debugLog(
      "Initialize finish with ${initStatus.adapterStatuses.length} adapter(s)",
    );
    initStatus.adapterStatuses.forEach((key, value) {
      debugLog('Adapter status for $key: ${value.state}');
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
    debugLog("buildBannerAd isLarge: $isLarge");
    final myBanner = BannerAd(
      adUnitId: unitId,
      size: adSize,
      request: _adRequest,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugLog(
            "Banner loaded. unitId: $unitId, size: ${adSize.width}x${adSize.height}",
          );
          completer.complete(true);
        },
        onAdFailedToLoad: (ad, error) {
          debugLog(
            "Banner load failed. unitId: $unitId, size: ${adSize.width}x${adSize.height}, error: $error",
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
    debugLog("buildNativeAd isLarge: $isLarge");
    final nativeAd = NativeAd.fromAdManagerRequest(
      adUnitId: unitId,
      factoryId: "admobNative",
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          debugLog(
            "Native loaded. unitId: $unitId, size: $size",
          );
          completer.complete(true);
        },
        onAdFailedToLoad: (ad, error) {
          debugLog(
            "Native load failed. unitId: $unitId, size: $size, error: $error",
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
    debugLog("loadInterstitialAd");
    InterstitialAd.load(
      adUnitId: unitId,
      request: _adRequest,
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugLog(
            "Interstitial loaded. unitId: $unitId, time consume: ${getTimeConsume()}s",
          );
          completer.complete(ad);
        },
        onAdFailedToLoad: (error) {
          debugLog(
            "Interstitial load failed. unitId: $unitId, error: $error, time consume: ${getTimeConsume()}s",
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
    debugLog("loadRewardedAd");
    RewardedAd.load(
      adUnitId: unitId,
      request: _adRequest,
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugLog(
            "rewarded loaded. unitId: $unitId, time consume: ${getTimeConsume()}s",
          );
          completer.complete(ad);
        },
        onAdFailedToLoad: (error) {
          debugLog(
            "rewarded load failed. unitId: $unitId, error: $error, time consume: ${getTimeConsume()}s",
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
        final isRewarded = rewarded.amount > 0;
        debugLog("Rewarded finish, isRewarded: $isRewarded");
        completer.complete(isRewarded);
      },
    );
    return await completer.future;
  }

  @override
  Future<Object?> loadAppOpenAd({
    required String unitId,
    required Function() onClick,
    required Function() onShow,
    required Function() onDismiss,
  }) async {
    final completer = Completer<AppOpenAd?>();
    final startAt = DateTime.now();
    int getTimeConsume() => DateTime.now().difference(startAt).inSeconds;
    debugLog("loadAppOpenAd");
    AppOpenAd.load(
      adUnitId: unitId,
      request: _adRequest,
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          debugLog(
            "appOpenAd loaded. unitId: $unitId, time consume: ${getTimeConsume()}s",
          );
          completer.complete(ad);
        },
        onAdFailedToLoad: (error) {
          debugLog(
            "appOpenAd load failed. unitId: $unitId, error: $error, time consume: ${getTimeConsume()}s",
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
  void showAppOpenAdIfLoaded(Object appOpenAd) {
    if (appOpenAd is! AppOpenAd) return;
    appOpenAd.show();
  }

  Future<void> _updateUmpConsent() async {
    try {
      final info =
          await ump.UserMessagingPlatform.instance.requestConsentInfoUpdate();
      debugLog("current UMP info: $info");
      if (info.consentStatus == ump.ConsentStatus.required) {
        final result =
            await ump.UserMessagingPlatform.instance.showConsentForm();
        debugLog("result UMP info: $result");
      }
    } catch (e, stack) {
      debugLog("UMP not config");
      log(
        "UMP not config",
        error: e,
        stackTrace: stack,
      );
    }
  }
}
