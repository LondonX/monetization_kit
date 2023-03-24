import 'dart:async';

import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../ad_loader.dart';

class AutoLoadingAdContainer extends StatefulWidget {
  final AdLoader adLoader;
  final Duration? reloadInterval;
  final bool initAdLoading;
  final ColorScheme? colorScheme;

  const AutoLoadingAdContainer({
    Key? key,
    required this.adLoader,
    this.reloadInterval,
    this.initAdLoading = true,
    this.colorScheme,
  }) : super(key: key);

  @override
  State<AutoLoadingAdContainer> createState() => _AutoLoadingAdContainerState();
}

class _AutoLoadingAdContainerState extends State<AutoLoadingAdContainer>
    with WidgetsBindingObserver {
  Widget? _ad;
  final _key = GlobalKey();
  DateTime _loadedAt = DateTime.fromMillisecondsSinceEpoch(0);
  bool _appActive = true;
  late bool _visibility = widget.initAdLoading;

  Duration get _reloadInterval =>
      widget.reloadInterval ?? widget.adLoader.reloadInterval;

  Future<void> _loadAdIfNeeded([Timer? _]) async {
    if (!_appActive || !_visibility) return;
    // 小于间隔时间
    if (DateTime.now().difference(_loadedAt) < _reloadInterval) return;
    _loadedAt = DateTime.now();
    // 缓存已在loadWidgetAd中处理
    final ad = await widget.adLoader.loadWidgetAd(
      colorScheme: widget.colorScheme ?? Theme.of(context).colorScheme,
    );
    if (ad == null) return;
    setState(() {
      _ad = ad;
    });
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

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    _startAutoLoading();
  }

  @override
  void dispose() {
    _stopLoading();
    WidgetsBinding.instance.removeObserver(this);
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
    final width = MediaQuery.of(context).size.width;
    final height = width / ratio;
    return VisibilityDetector(
      key: _key,
      onVisibilityChanged: (info) {
        _visibility = info.visibleFraction > 0.5;
      },
      child: SizedBox(
        width: width,
        height: height,
        child: _ad,
      ),
    );
  }
}
