import 'package:flutter/material.dart';

import 'package:monetization_kit/ad/ad_loader.dart';
import 'package:monetization_kit/ad/widget/auto_loading_ad_container.dart';

class AdProviderPage extends StatefulWidget {
  final AdLoader? native;
  final AdLoader? banner;
  final AdLoader? appOpen;
  final AdLoader? interstitial;
  final AdLoader? rewarded;
  final Function()? startMediationTest;
  final Function()? startInspector;

  const AdProviderPage({
    Key? key,
    required this.native,
    required this.banner,
    required this.appOpen,
    required this.interstitial,
    required this.rewarded,
    required this.startMediationTest,
    required this.startInspector,
  }) : super(key: key);

  @override
  State<AdProviderPage> createState() => _AdmobPageState();
}

class _AdmobPageState extends State<AdProviderPage>
    with AutomaticKeepAliveClientMixin {
  final _loadings = <AdLoader>{};

  _loadFullscreenAd(AdLoader adLoader) async {
    if (_loadings.contains(adLoader)) return;
    setState(() {
      _loadings.add(adLoader);
    });
    await adLoader.loadFullscreenAd();
    setState(() {
      _loadings.remove(adLoader);
    });
  }

  _showFullscreenAd(AdLoader adLoader) async {
    final rewarded = await adLoader.showFullscreenAd();
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Fullscreen Ad"),
        content: Text("type: ${adLoader.adType} rewarded: $rewarded"),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text("OK"),
          ),
        ],
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final native = widget.native;
    final banner = widget.banner;
    final appOpen = widget.appOpen;
    final rewarded = widget.rewarded;
    final interstitial = widget.interstitial;
    return ListView(
      children: [
        native == null
            ? const ListTile(
                title: Text("widget.native is null"),
                enabled: false,
              )
            : AutoLoadingAdContainer(adLoader: native),
        banner == null
            ? const ListTile(
                title: Text("widget.banner is null"),
                enabled: false,
              )
            : AutoLoadingAdContainer(adLoader: banner),
        _buildFullscreenAdLoaderTile(
          context,
          displayName: "appOpen",
          adLoader: appOpen,
        ),
        _buildFullscreenAdLoaderTile(
          context,
          displayName: "rewarded",
          adLoader: rewarded,
        ),
        _buildFullscreenAdLoaderTile(
          context,
          displayName: "interstitial",
          adLoader: interstitial,
        ),
        ListTile(
          title: const Text("Start mediation test"),
          subtitle: widget.startMediationTest == null
              ? const Text("Not implemented")
              : null,
          onTap: widget.startMediationTest,
          enabled: widget.startMediationTest != null,
        ),
        ListTile(
          title: const Text("Start inspector"),
          subtitle: widget.startInspector == null
              ? const Text("Not implemented")
              : null,
          onTap: widget.startInspector,
          enabled: widget.startInspector != null,
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;

  Widget _buildFullscreenAdLoaderTile(
    BuildContext context, {
    required String displayName,
    required AdLoader? adLoader,
  }) {
    if (adLoader == null) {
      return ListTile(
        title: Text("widget.$displayName is null"),
        enabled: false,
      );
    }
    final isLoading = _loadings.contains(adLoader);
    final isLoaded = adLoader.adCacheValid;
    return ListTile(
      title: Text("Load/Show $displayName Ad"),
      onTap: isLoading
          ? null
          : () {
              isLoaded
                  ? _showFullscreenAd(adLoader)
                  : _loadFullscreenAd(adLoader);
            },
      subtitle: Text(
        isLoading
            ? "Loading..."
            : isLoaded
                ? "✅ Loaded"
                : "Not loaded",
      ),
    );
  }
}
