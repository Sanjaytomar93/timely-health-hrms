import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';

class NavIcons {
  const NavIcons._();

  static const Color active = PortalColors.brand;
  static const Color inactive = Color(0xFF939393);
  static const Color activeBg = PortalColors.brandTint;

  static Widget dashboard({required bool selected, double size = 38}) =>
      _icon('ic_nav_dashboard', selected, size);

  static Widget calendar({required bool selected, double size = 38}) =>
      _icon('ic_nav_attendance', selected, size);

  static Widget calendarAdd({required bool selected, double size = 38}) =>
      _icon('ic_nav_leave', selected, size);

  static Widget profile({required bool selected, double size = 38}) =>
      _icon('ic_nav_account', selected, size);

  static Widget _icon(String name, bool selected, double size) {
    return SvgPicture.asset(
      'assets/icons/nav/$name.svg',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(
        selected ? active : inactive,
        BlendMode.srcIn,
      ),
    );
  }
}
