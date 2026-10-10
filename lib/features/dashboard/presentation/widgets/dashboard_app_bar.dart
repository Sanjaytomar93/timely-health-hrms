import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/features/holidays/presentation/widgets/top_calendar_button.dart';
import 'package:timelay_health/features/notifications/presentation/widgets/top_notification_button.dart';

class DashboardAppBar extends StatelessWidget {
  const DashboardAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PortalColors.surface,
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
      child: Row(
        children: [
          const Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Image(
                image: AssetImage('assets/images/timely_health_logo.png'),
                height: 32,
                fit: BoxFit.contain,
              ),
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
