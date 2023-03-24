import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:monetization_kit/ad/ad_loader.dart';
import 'package:monetization_kit/ad/entity/ad_enum.dart';
import 'package:monetization_kit/monetization_kit.dart';
import 'package:monetization_kit_example/ad_provider_page.dart';
import 'package:monetization_kit_example/settings_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  late final _tab = TabController(length: 3, vsync: this);
  bool _initFinished = false;

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
          bottom: TabBar(
            controller: _tab,
            tabs: const [
              Tab(text: "Settings"),
              Tab(text: "Admob"),
              Tab(text: "Max"),
            ],
          ),
        ),
        body: _initFinished
            ? _buildPager()
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildPager() {
    return TabBarView(
      controller: _tab,
      children: [
        const SettingsPage(),
        AdProviderPage(
          native: AdLoader(
            unitIds: ["ca-app-pub-3940256099942544/1044960115"],
            adType: AdType.nativeSmall,
          ),
          rewarded: AdLoader(
            unitIds: ["ca-app-pub-3940256099942544/5224354917"],
            adType: AdType.rewarded,
          ),
          interstitial: AdLoader(
            unitIds: ["ca-app-pub-3940256099942544/1033173712"],
            adType: AdType.interstitial,
          ),
          startMediationTest: MonetizationKit.instance.startAdmobMediationTest,
          startInspector: MonetizationKit.instance.startAdmobInspector,
        ),
        //TODO max
        AdProviderPage(
          native: AdLoader(
            unitIds: ["ca-app-pub-3940256099942544/1044960115"],
            adType: AdType.nativeSmall,
          ),
          rewarded: AdLoader(
            unitIds: ["ca-app-pub-3940256099942544/5224354917"],
            adType: AdType.rewarded,
          ),
          interstitial: AdLoader(
            unitIds: ["ca-app-pub-3940256099942544/1033173712"],
            adType: AdType.interstitial,
          ),
          startMediationTest: MonetizationKit.instance.startAdmobMediationTest,
          startInspector: MonetizationKit.instance.startAdmobInspector,
        ),
      ],
    );
  }
}
