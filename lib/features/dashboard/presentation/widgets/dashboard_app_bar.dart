import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/auth/data/auth_session.dart';
import 'package:timelay_health/features/dashboard/presentation/screens/employee_home_shell.dart';
import 'package:timelay_health/features/holidays/presentation/widgets/top_calendar_button.dart';
import 'package:timelay_health/features/notifications/presentation/widgets/top_notification_button.dart';

class DashboardAppBar extends StatelessWidget {
  const DashboardAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isAdmin = kForceAdminHome ||
        (AuthSession.currentEmployee?.isAdmin ?? false);
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 2, 18, 6),
      decoration: const BoxDecoration(
        color: PortalColors.brand,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: PortalColors.brandTint,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                'assets/icons/top_bar/ic_top_menu.svg',
                width: 18,
                height: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Timely Health',
                  style: portalText(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.3,
                    height: 1.1,
                  ),
                ),
                Text(
                  isAdmin ? 'ADMIN PORTAL' : 'EMPLOYEE PORTAL',
                  style: portalText(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.72),
                    letterSpacing: 1.4,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const TopNotificationButton(),
          const SizedBox(width: 14),
          const TopCalendarButton(),
        ],
      ),
    );
  }
}
