import 'package:flutter/material.dart';

import 'package:monetization_kit/ad/ad_loader.dart';
import 'package:monetization_kit/ad/widget/auto_loading_ad_container.dart';

class AdProviderPage extends StatefulWidget {
  final AdLoader native;
  final AdLoader rewarded;
  final AdLoader interstitial;
  final Function()? startMediationTest;
  final Function()? startInspector;

  const AdProviderPage({
    Key? key,
    required this.native,
    required this.rewarded,
    required this.interstitial,
    required this.startMediationTest,
    required this.startInspector,
  }) : super(key: key);

  @override
  State<AdProviderPage> createState() => _AdmobPageState();
}

class _AdmobPageState extends State<AdProviderPage> {
  Object? _rewardedAd;
  Object? _interstitialAd;
  bool _rewardedAdLoading = false;
  bool _interstitialAdLoading = false;

  _loadRewardedAd() async {
    setState(() {
      _rewardedAdLoading = true;
    });
    final rewardedAd = await widget.rewarded.loadFullscreenAd();
    setState(() {
      _rewardedAdLoading = false;
      _rewardedAd = rewardedAd;
    });
  }

  _showRewardedAd() async {
    final rewarded = await widget.rewarded.showFullscreenAd();
    if (!rewarded) return;
    setState(() {
      _rewardedAd = null;
    });
  }

  _loadInterstitialAd() async {
    setState(() {
      _interstitialAdLoading = true;
    });
    final interstitialAd = await widget.interstitial.loadFullscreenAd();
    setState(() {
      _interstitialAdLoading = false;
      _interstitialAd = interstitialAd;
    });
  }

  _showInterstitialAd() async {
    final rewarded = await widget.interstitial.showFullscreenAd();
    if (!rewarded) return;
    setState(() {
      _rewardedAd = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        AutoLoadingAdContainer(
          adLoader: widget.native,
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
          title: const Text("Start mediation test"),
          onTap: widget.startMediationTest,
        ),
        ListTile(
          title: const Text("Start debug"),
          onTap: widget.startInspector,
        ),
      ],
    );
  }
}
