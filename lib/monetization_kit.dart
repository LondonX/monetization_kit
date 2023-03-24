import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:monetization_kit/ad/provider/ad_provider.dart';
import 'package:monetization_kit/ad/provider/ad_provider_admob.dart';

class MonetizationKit {
  static bool debug = false;
  final _methodChannel = const MethodChannel('monetization_kit');

  static MonetizationKit? _instance;
  static MonetizationKit get instance => _instance ??= MonetizationKit._();
  MonetizationKit._();

  final adProviders = <AdProvider>[];

  T? findAdProvider<T extends AdProvider>() {
    for (var provider in adProviders) {
      if (provider is T) return provider;
    }
    return null;
  }

  Future<bool> init({
    List<AdProvider> adProviders = const [AdProviderAdMob()],
  }) async {
    // init AdProviders
    final withAdmob =
        adProviders.any((provider) => provider is AdProviderAdMob);
    _methodChannel.invokeMethod("initAds", {
      "withAdmob": withAdmob,
    });
    final results = await Future.wait(adProviders.map((e) => e.init()));
    if (results.any((element) => !element)) return false;
    this.adProviders.addAll(adProviders);
    //TODO init iap
    return true;
  }

  Future<void> startAdmobMediationTest() async {
    await _methodChannel.invokeMethod("startAdmobMediationTest");
  }

  Future<void> startAdmobInspector() async {
    MobileAds.instance.openAdInspector((p0) {});
  }
}
