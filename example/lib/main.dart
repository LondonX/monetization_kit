import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:monetization_kit/ad/ad_loader.dart';
import 'package:monetization_kit/ad/entity/ad_enum.dart';
import 'package:monetization_kit/ad/widget/auto_loading_ad_container.dart';
import 'package:monetization_kit/monetization_kit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _adLoaderNative = AdLoader(
    unitIds: ["ca-app-pub-3940256099942544/1044960115"],
    adType: AdType.nativeSmall,
  );
  final _adLoaderRewarded = AdLoader(
    unitIds: ["ca-app-pub-3940256099942544/5224354917"],
    adType: AdType.rewarded,
  );
  final _adLoaderInterstitial = AdLoader(
    unitIds: ["ca-app-pub-3940256099942544/1033173712"],
    adType: AdType.interstitial,
  );

  bool _initFinished = false;
  Object? _rewardedAd;
  Object? _interstitialAd;
  bool _rewardedAdLoading = false;
  bool _interstitialAdLoading = false;

  _loadRewardedAd() async {
    setState(() {
      _rewardedAdLoading = true;
    });
    final rewardedAd = await _adLoaderRewarded.loadFullscreenAd();
    setState(() {
      _rewardedAdLoading = false;
      _rewardedAd = rewardedAd;
    });
  }

  _showRewardedAd() async {
    final rewarded = await _adLoaderRewarded.showFullscreenAd();
    if (!rewarded) return;
    setState(() {
      _rewardedAd = null;
    });
  }

  _loadInterstitialAd() async {
    setState(() {
      _interstitialAdLoading = true;
    });
    final interstitialAd = await _adLoaderInterstitial.loadFullscreenAd();
    setState(() {
      _interstitialAdLoading = false;
      _interstitialAd = interstitialAd;
    });
  }

  _showInterstitialAd() async {
    final rewarded = await _adLoaderInterstitial.showFullscreenAd();
    if (!rewarded) return;
    setState(() {
      _rewardedAd = null;
    });
  }

  _init() async {
    MonetizationKit.debug = kDebugMode;
    final initFinished = await MonetizationKit.instance.init();
    setState(() {
      _initFinished = initFinished;
    });
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          primary: Colors.red,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          primary: Colors.green,
          brightness: Brightness.dark,
        ),
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('MonetizationKit example'),
        ),
        body: _initFinished
            ? ListView(
                children: [
                  ListTile(
                    title: const Text("MonetizationKit initial finished"),
                    subtitle: Text(
                        "${MonetizationKit.instance.adProviders.length} AdProviders."),
                  ),
                  SwitchListTile(
                    title: const Text("MonetizationKit.debug"),
                    value: MonetizationKit.debug,
                    onChanged: (v) {
                      setState(() {
                        MonetizationKit.debug = v;
                      });
                    },
                  ),
                  AutoLoadingAdContainer(
                    adLoader: _adLoaderNative,
                  ),
                  ListTile(
                    title: const Text("Load/Show Rewarded Ad"),
                    onTap: _rewardedAdLoading
                        ? null
                        : _rewardedAd == null
                            ? _loadRewardedAd
                            : _showRewardedAd,
                    subtitle: Text(
                      _rewardedAdLoading
                          ? "Loading..."
                          : _rewardedAd == null
                              ? "Not loaded"
                              : "✅ Loaded",
                    ),
                  ),
                  ListTile(
                    title: const Text("Load/Show Interstitial Ad"),
                    onTap: _interstitialAdLoading
                        ? null
                        : _interstitialAd == null
                            ? _loadInterstitialAd
                            : _showInterstitialAd,
                    subtitle: Text(
                      _interstitialAdLoading
                          ? "Loading..."
                          : _interstitialAd == null
                              ? "Not loaded"
                              : "✅ Loaded",
                    ),
                  ),
                  ListTile(
                    title: const Text("Start Admob mediation test"),
                    onTap: MonetizationKit.instance.startAdmobMediationTest,
                  ),
                  ListTile(
                    title: const Text("Start Admob debug"),
                    onTap: MonetizationKit.instance.startAdmobInspector,
                  ),
                ],
              )
            : const Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }
}
