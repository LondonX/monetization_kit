import 'dart:async';

import 'package:flutter/material.dart';
import 'package:monetization_kit/monetization_kit.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../ad_loader.dart';

class AutoLoadingAdContainer extends StatefulWidget {
  final AdLoader adLoader;
  final Duration? reloadInterval;
  final bool initAdLoading;
  final ColorScheme? colorScheme;
  final bool keepSizeWhenNoAds;
  final bool autoConsume;

  const AutoLoadingAdContainer({
    Key? key,
    required this.adLoader,
    this.reloadInterval,
    this.initAdLoading = true,
    this.colorScheme,
    this.keepSizeWhenNoAds = true,
    this.autoConsume = true,
  }) : super(key: key);

  @override
  State<AutoLoadingAdContainer> createState() => _AutoLoadingAdContainerState();
}

final _loadedPool = <AdLoader, DateTime>{};

class _AutoLoadingAdContainerState extends State<AutoLoadingAdContainer>
    with WidgetsBindingObserver {
  final _key = GlobalKey();
  DateTime get _loadedAt =>
      _loadedPool[widget.adLoader] ??= DateTime.fromMillisecondsSinceEpoch(0);
  set _loadedAt(DateTime value) {
    _loadedPool[widget.adLoader] = value;
  }

  bool _appActive = true;
  late bool _visibility = widget.initAdLoading;
  bool get _adsInit => MonetizationKit.instance.adsInit.value;

  Duration get _reloadInterval =>
      widget.reloadInterval ?? widget.adLoader.reloadInterval;

  Future<void> _loadAdIfNeeded([Timer? _]) async {
    if (!_appActive || !_visibility || !_adsInit) return;
    // 小于间隔时间
    if (DateTime.now().difference(_loadedAt) < _reloadInterval) return;
    _loadedAt = DateTime.now();
    // 缓存已在loadWidgetAd中处理
    final ad = await widget.adLoader.loadWidgetAd(
      colorScheme: widget.colorScheme ?? Theme.of(context).colorScheme,
      autoConsume: widget.autoConsume,
    );
    if (ad == null) return;
    setState(() {});
  }

  Timer? _widgetAdLoading;
  _startAutoLoading() {
    if (_widgetAdLoading != null) return;
    _widgetAdLoading?.cancel();
    _widgetAdLoading = Timer.periodic(
      const Duration(seconds: 1),
      _loadAdIfNeeded,
    );
  }

  _stopLoading() {
    _widgetAdLoading?.cancel();
    _widgetAdLoading = null;
  }

  _adsInitChange() {
    if (_adsInit) _loadAdIfNeeded();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    MonetizationKit.instance.adsInit.addListener(_adsInitChange);
    super.initState();
    _startAutoLoading();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // setState(() {}); // update width
    });
  }

  @override
  void dispose() {
    _stopLoading();
    WidgetsBinding.instance.removeObserver(this);
    MonetizationKit.instance.adsInit.removeListener(_adsInitChange);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _appActive = state == AppLifecycleState.resumed;
  }

  @override
  Widget build(BuildContext context) {
    final ratio = widget.adLoader.widgetRatio;
    if (ratio == 0) return const SizedBox();
    return VisibilityDetector(
      key: _key,
      onVisibilityChanged: (info) {
        _visibility = info.visibleFraction > 0.5;
      },
      child: widget.adLoader.widgetAdCache != null || widget.keepSizeWhenNoAds
          ? AspectRatio(
              aspectRatio: ratio,
              child: widget.adLoader.widgetAdCache,
            )
          : const SizedBox(height: 0.01),
    );
  }
}
