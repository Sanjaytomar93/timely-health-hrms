import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/routes/app_routes.dart';
import 'package:timelay_health/features/auth/data/auth_session.dart';
import 'package:timelay_health/features/dashboard/presentation/screens/employee_home_shell.dart';

class TopCalendarButton extends StatelessWidget {
  const TopCalendarButton({
    super.key,
    this.width = 34,
    this.height = 34,
    this.asset = 'assets/icons/top_bar/ic_top_calendar.svg',
    this.onTap,
  });

  final double width;
  final double height;
  final String asset;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ??
            () {
              final isAdmin = kForceAdminHome ||
                  (AuthSession.currentEmployee?.isAdmin ?? false);
              final target = isAdmin
                  ? AppRoutes.holidayCalendar
                  : AppRoutes.workRoster;
              final currentRoute = ModalRoute.of(context)?.settings.name;
              if (currentRoute == target) return;
              AppRoutes.push(context, target);
            },
        borderRadius: BorderRadius.circular(17),
        child: SvgPicture.asset(asset, width: width, height: height),
      ),
    );
  }
}
