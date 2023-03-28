import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:monetization_kit/ad/max/max_ad_helper.dart';
import 'package:monetization_kit/ad/provider/ad_provider.dart';
import 'package:monetization_kit/ad/provider/ad_provider_admob.dart';
import 'package:monetization_kit/ad/provider/ad_provider_max.dart';
import 'package:monetization_kit/iap/consuming_manager.dart';
import 'package:monetization_kit/iap/iap.dart';

class MonetizationKit {
  static bool debug = false;
  final _methodChannel = const MethodChannel('monetization_kit');

  static MonetizationKit instance = MonetizationKit._();
  MonetizationKit._();

  final adProviders = <AdProvider>[];
  final _maxAdHelper = MaxAdHelper.instance;
  IAP? _iap;

  T? findAdProvider<T extends AdProvider>() {
    for (var provider in adProviders) {
      if (provider is T) return provider;
    }
    return null;
  }

  Future<bool> init({
    List<AdProvider> adProviders = const [
      AdProviderAdMob(),
      AdProviderMax(),
    ],
    Future<bool> Function(String productId, String serverVerificationData)?
        verifyPurchase,
  }) async {
    // init AdProviders
    final withAdmob = adProviders.any(
      (provider) => provider is AdProviderAdMob,
    );
    final withMax = adProviders.any(
      (provider) => provider is AdProviderMax,
    );
    await _methodChannel.invokeMethod("initAds", {
      "withAdmob": withAdmob,
      "withMax": withMax, //not used in native
    });
    _maxAdHelper.setChannel(_methodChannel);
    final results = await Future.wait(adProviders.map((e) => e.init()));
    if (results.any((element) => !element)) return false;
    this.adProviders.addAll(adProviders);
    // init iap
    await ConsumingManager.instance.init();
    _iap = IAP(verifyPurchase: verifyPurchase);
    return true;
  }

  Future<void> startAdmobMediationTest() async {
    await _methodChannel.invokeMethod("startAdmobMediationTest");
  }

  Future<void> startAdmobInspector() async {
    MobileAds.instance.openAdInspector((p0) {});
  }

  Future<void> startMaxMediationTest() async {
    await _maxAdHelper.showMediationDebugger();
  }

  IAP get iap => _iap!;
}
