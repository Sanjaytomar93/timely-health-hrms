import 'package:flutter/material.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/theme/camp_colors.dart';

const kMemberPrimary = Color(0xFF26204A);
const kMemberPrimaryDeep = Color(0xFF26204A);
const kMemberPrimaryDark = Color(0xFF1A1635);
const kMemberPrimaryLight = Color(0xFF4B4285);
const kMemberSurface = CampColors.surface;
const kMemberBorder = CampColors.border;
const kMemberBg = CampColors.background;
const kMemberHeading = CampColors.heading;
const kMemberMuted = CampColors.muted;

const kMemberHeroGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [kMemberPrimaryDark, kMemberPrimary, kMemberPrimaryLight],
  stops: [0.0, 0.55, 1.0],
);
