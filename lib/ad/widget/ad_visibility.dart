import 'package:flutter/widgets.dart';
import 'package:visibility_detector/visibility_detector.dart';

class AdVisibility extends StatefulWidget {
  final Function(bool isVisible)? visibilityChange;
  final Function() firstShow;
  final Widget child;
  const AdVisibility({
    Key? key,
    this.visibilityChange,
    required this.firstShow,
    required this.child,
  }) : super(key: key);

  @override
  State<AdVisibility> createState() => _AdVisibilityState();
}

class _AdVisibilityState extends State<AdVisibility> {
  bool? currentVisible;
  bool isFirstShow = true;

  @override
  void didUpdateWidget(covariant AdVisibility oldWidget) {
    if (oldWidget.child != widget.child) isFirstShow = true;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ObjectKey(widget.child),
      onVisibilityChanged: (info) {
        final isVisible = info.visibleFraction > 0.01;
        if (currentVisible == isVisible) return;
        currentVisible = isVisible;
        widget.visibilityChange?.call(isVisible);

        if (isVisible && isFirstShow) {
          isFirstShow = false;
          widget.firstShow();
        }
      },
      child: widget.child,
    );
  }
}
