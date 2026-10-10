import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';

class PortalSafeArea extends StatelessWidget {
  const PortalSafeArea({
    super.key,
    this.bottom = true,
    this.statusBarColor = PortalColors.surface,
    required this.child,
  });

  final bool bottom;
  final Color statusBarColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Column(
      children: [
        ColoredBox(
          color: statusBarColor,
          child: SizedBox(width: double.infinity, height: top),
        ),
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: SafeArea(bottom: bottom, child: child),
          ),
        ),
      ],
    );
  }
}
