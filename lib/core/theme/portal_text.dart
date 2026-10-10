import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';

final Map<FontWeight, TextStyle> _interByWeight = {};

TextStyle portalText({
  double fontSize = 14,
  FontWeight fontWeight = FontWeight.w400,
  Color color = PortalColors.heading,
  double? height,
  double? letterSpacing,
}) {
  final base = _interByWeight.putIfAbsent(
    fontWeight,
    () => GoogleFonts.inter(fontWeight: fontWeight),
  );
  return base.copyWith(
    fontSize: fontSize,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
  );
}
