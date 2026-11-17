import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/routes/app_routes.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/notifications/presentation/widgets/top_notification_button.dart';

class OpTopBar extends StatelessWidget {
  const OpTopBar({
    super.key,
    this.title = 'OP Dashboard',
    this.onMenuTap,
    this.light = true,
    this.showBack = false,
    this.bottom,
  });

  final String title;
  final VoidCallback? onMenuTap;
  final bool light;
  final bool showBack;
  final Widget? bottom;

  void _goToHrms(BuildContext context) {
    Navigator.of(context).popUntil(
      (route) => route.isFirst || route.settings.name == AppRoutes.home,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(22, 2, 18, bottom == null ? 6 : 12),
      decoration: const BoxDecoration(
        color: PortalColors.brand,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onMenuTap ?? () => _goToHrms(context),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: PortalColors.brandTint,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: showBack
                      ? SvgPicture.asset(
                          'assets/icons/payslips/ic_back.svg',
                          width: 20,
                          height: 20,
                        )
                      : SvgPicture.asset(
                          'assets/icons/top_bar/ic_top_menu.svg',
                          width: 18,
                          height: 18,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.3,
                    height: 1.1,
                  ),
                ),
              ),
              const TopNotificationButton(),
            ],
          ),
          if (bottom != null) ...[
            const SizedBox(height: 10),
            bottom!,
          ],
        ],
      ),
    );
  }
}
