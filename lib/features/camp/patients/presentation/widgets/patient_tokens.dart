import 'package:flutter/material.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/theme/camp_colors.dart';

const kPatientPrimary = Color(0xFF26204A);
const kPatientPrimaryDeep = Color(0xFF26204A);
const kPatientPrimaryDark = Color(0xFF1A1635);
const kPatientPrimaryLight = Color(0xFF4B4285);
const kPatientSurface = CampColors.surface;
const kPatientBorder = CampColors.border;
const kPatientBg = CampColors.background;
const kPatientHeading = CampColors.heading;
const kPatientMuted = CampColors.muted;

const kPatientHeroGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [kPatientPrimaryDark, kPatientPrimary, kPatientPrimaryLight],
  stops: [0.0, 0.55, 1.0],
);
