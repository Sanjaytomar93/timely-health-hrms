import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/notifications/presentation/widgets/top_notification_button.dart';
import 'package:timelay_health/core/widgets/portal_back_button.dart';
import 'package:timelay_health/core/widgets/portal_safe_area.dart';

class ProfileSectionPlaceholderScreen extends StatelessWidget {
  const ProfileSectionPlaceholderScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PortalColors.background,
      body: PortalSafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: PortalColors.surface,
                border: Border(bottom: BorderSide(color: PortalColors.border)),
              ),
              padding: const EdgeInsets.fromLTRB(16, 10, 18, 10),
              child: Row(
                children: [
                  const PortalBackButton(),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: portalText(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: PortalColors.heading,
                      ),
                    ),
                  ),
                  const TopNotificationButton(),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  '$title coming soon',
                  style: portalText(fontSize: 14, color: PortalColors.muted),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
