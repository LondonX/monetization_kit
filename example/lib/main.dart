import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:monetization_kit/ad/ad_loader.dart';
import 'package:monetization_kit/ad/entity/ad_enum.dart';
import 'package:monetization_kit/monetization_kit.dart';
import 'package:monetization_kit_example/ad_provider_page.dart';
import 'package:monetization_kit_example/iap_page.dart';
import 'package:monetization_kit_example/settings_page.dart';
import 'package:monetization_kit_example/unit_ids.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  late final _appPages = [
    SettingsPage(
      fakeAnalyticsList: [
        _admobFakeAnalytics,
      ],
    ),
    // Admob
    AdProviderPage(
      native: AdLoader(
        unitIds: [admNativeUnit],
        adType: AdType.nativeSmall,
        log: _admobFakeAnalytics.logAds,
      ),
      banner: AdLoader(
        unitIds: [admBannerUnit],
        adType: AdType.banner,
        log: _admobFakeAnalytics.logAds,
      ),
      appOpen: AdLoader(
        unitIds: [admAppOpenUnit],
        adType: AdType.appOpen,
        log: _admobFakeAnalytics.logAds,
      ),
      rewarded: AdLoader(
        unitIds: [admRewardedUnit],
        adType: AdType.rewarded,
        log: _admobFakeAnalytics.logAds,
      ),
      interstitial: AdLoader(
        unitIds: [admInterstitialUnit],
        adType: AdType.interstitial,
        log: _admobFakeAnalytics.logAds,
      ),
      startMediationTest: MonetizationKit.instance.startAdmobMediationTest,
      startInspector: MonetizationKit.instance.startAdmobInspector,
    ),
    //IAP
    const IAPPage(),
  ];
  final _admobFakeAnalytics = FakeAnalytics(page: "AdmobPage");
  late final _tab = TabController(length: _appPages.length, vsync: this);
  bool _initFinished = false;

  late BuildContext _uiContext;
  Future<bool> _purchaseVerify(
    String productId,
    String serverVerificationData,
  ) async {
    final passed = await showDialog<bool>(
      context: _uiContext,
      builder: (context) {
        return AlertDialog(
          title: const Text("Purchase Verify"),
          content: SelectableText(
            "This is a dummy purchase verifier.\nProductId: $productId\nVerificationData: $serverVerificationData",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text("Pass Verify"),
            ),
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: const Text("Deny Verify"),
            ),
          ],
        );
      },
    );
    return passed == true;
  }

  _init() async {
    MonetizationKit.debug = kDebugMode;
    final initFinished = await MonetizationKit.instance.init(
      verifyPurchase: _purchaseVerify,
    );
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
      home: Builder(builder: (context) {
        _uiContext = context;
        return Scaffold(
          appBar: AppBar(
            title: const Text('MonetizationKit example'),
            bottom: TabBar(
              controller: _tab,
              tabs: const [
                Tab(text: "Settings"),
                Tab(text: "Admob"),
                Tab(text: "IAP."),
              ],
            ),
          ),
          body: _initFinished
              ? _buildPager()
              : const Center(child: CircularProgressIndicator()),
        );
      }),
    );
  }

  Widget _buildPager() {
    return TabBarView(
      controller: _tab,
      children: _appPages,
    );
  }
}
