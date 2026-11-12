import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';

/// OP Management tokens — app bar / brand match main HRMS app.
abstract final class OpColors {
  static const Color background = PortalColors.background;
  static const Color surface = PortalColors.surface;
  static const Color border = PortalColors.border;

  static const Color primary = PortalColors.brand;
  static const Color primaryDark = PortalColors.brand;
  static const Color primaryLight = PortalColors.brandLight;
  static const Color primaryTint = PortalColors.brandTint;

  static const Color heading = PortalColors.heading;
  static const Color muted = PortalColors.muted;
  static const Color secondary = PortalColors.secondaryText;

  static const Color green = PortalColors.green;
  static const Color greenTint = PortalColors.greenTint;
  static const Color orange = PortalColors.orange;
  static const Color orangeTint = PortalColors.orangeTint;
  static const Color red = PortalColors.red;
  static const Color redTint = PortalColors.redTint;

  static const Color blue = Color(0xFF3B82F6);
  static const Color blueTint = Color(0xFFEAF2FF);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color purpleTint = Color(0xFFF3EEFF);
  static const Color pink = Color(0xFFEC4899);
  static const Color pinkTint = Color(0xFFFCE7F3);
  static const Color cyan = Color(0xFF06B6D4);

  static const List<Color> heroGradient = [
    PortalColors.brand,
    PortalColors.brandLight,
  ];

  static BoxDecoration card({double radius = 18}) => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F2A2456),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
          BoxShadow(
            color: Color(0x061C1B29),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      );

  static BoxDecoration softIcon({
    required Color tint,
    double size = 44,
  }) =>
      BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(size * 0.32),
      );
}
