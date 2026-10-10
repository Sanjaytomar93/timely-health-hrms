import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: PortalColors.purple,
        primary: PortalColors.purple,
        surface: PortalColors.surface,
      ),
      scaffoldBackgroundColor: PortalColors.background,
      textTheme: GoogleFonts.interTextTheme(),
    );
  }
}
