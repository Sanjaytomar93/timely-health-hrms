import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';

/// Camp Management design tokens matching HRMS theme tokens.
abstract final class CampColors {
  static const Color background = PortalColors.background;
  static const Color surface = PortalColors.surface;
  static const Color border = PortalColors.border;

  // HRMS Signature Brand Color
  static const Color primary = PortalColors.brand;
  static const Color primaryLight = PortalColors.brandLight;
  static const Color primaryTint = Color(0xFFEBE9F5);

  static const Color heading = PortalColors.heading;
  static const Color muted = PortalColors.muted;
  static const Color secondary = PortalColors.secondaryText;

  static const Color green = PortalColors.green;
  static const Color greenTint = PortalColors.greenTint;

  static const Color orange = PortalColors.orange;
  static const Color orangeTint = PortalColors.orangeTint;

  static const Color red = PortalColors.red;
  static const Color redTint = PortalColors.redTint;

  static const Color blue = Color(0xFF378ADD);
  static const Color blueTint = Color(0xFFE8F3FC);

  static const Color slate = Color(0xFF5B6B82);
  static const Color slateTint = Color(0xFFEFF2F6);

  static BoxDecoration card({double radius = 18}) => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x081C1B29),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      );
}
