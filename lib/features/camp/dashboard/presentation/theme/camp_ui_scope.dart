import 'package:flutter/material.dart';

/// Mildly scales Camp Management UI to keep density readable.
class CampUiScope extends StatelessWidget {
  const CampUiScope({super.key, required this.child});

  final Widget child;

  /// Between previous 0.88 (too small) and 1.0 (too large).
  static const double scale = 0.94;

  static EdgeInsets _scaleInsets(EdgeInsets insets) {
    return EdgeInsets.only(
      left: insets.left / scale,
      top: insets.top / scale,
      right: insets.right / scale,
      bottom: insets.bottom / scale,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mq = MediaQuery.of(context);
        final maxW = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : mq.size.width;
        final maxH = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : mq.size.height;
        final width = maxW / scale;
        final height = maxH / scale;

        return OverflowBox(
          alignment: Alignment.topLeft,
          minWidth: width,
          maxWidth: width,
          minHeight: height,
          maxHeight: height,
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: width,
              height: height,
              child: MediaQuery(
                data: mq.copyWith(
                  size: Size(width, height),
                  padding: _scaleInsets(mq.padding),
                  viewPadding: _scaleInsets(mq.viewPadding),
                  viewInsets: _scaleInsets(mq.viewInsets),
                ),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}
