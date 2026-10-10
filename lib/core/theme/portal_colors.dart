import 'package:flutter/material.dart';

class PortalColors {
  const PortalColors._();

  static const Color background = Color(0xFFF6F5FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE9E7F2);

  static const Color heading = Color(0xFF1C1B29);
  static const Color muted = Color(0xFF7C7A91);
  static const Color secondaryText = Color(0xFF47455C);

  static const Color brand = Color(0xFF26204A);
  static const Color brandTint = Color(0xFFEEEDF0);
  static const Color brandLight = Color(0xFF4B4285);

  static const Color purple = brand;
  static const Color purpleDeep = brand;
  static const Color purpleLight = brandLight;
  static const Color purpleMid = brand;
  static const Color purpleSoft = brandLight;
  static const Color purpleTint = brandTint;
  static const Color purpleNav = brand;
  static const Color purpleNavBg = Color(0x3026204A);

  static const Color green = Color(0xFF18AC96);
  static const Color greenTint = Color(0xFFE7F7F0);
  static const Color red = Color(0xFFE0483E);
  static const Color redTint = Color(0xFFFDECEB);
  static const Color redSoft = Color(0xFFFF8A80);
  static const Color orange = Color(0xFFF0A72E);
  static const Color orangeTint = Color(0xFFFDF3E3);

  static const List<Color> avatarGradient = [purpleMid, purpleSoft];
  static const List<Color> attendanceGradient = [purpleDeep, purpleLight];
  static const List<Color> menuGradient = [purpleMid, purpleSoft];
  static const List<Color> brandGradient = [brand, brandLight];
}
