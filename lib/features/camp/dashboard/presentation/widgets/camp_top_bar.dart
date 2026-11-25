import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/theme/camp_colors.dart';
import 'package:timelay_health/features/notifications/presentation/widgets/top_notification_button.dart';

class CampTopBar extends StatelessWidget {
  const CampTopBar({super.key});

  static const _logoAsset = 'assets/images/camp_timely_health_logo.png';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CampColors.surface,
        border: const Border(bottom: BorderSide(color: CampColors.border)),
        boxShadow: [
          BoxShadow(
            color: PortalColors.brand.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(22, 2, 18, 6),
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
          const SizedBox(width: 4),
          Image.asset(
            _logoAsset,
            height: 44,
            fit: BoxFit.contain,
            alignment: Alignment.centerLeft,
            filterQuality: FilterQuality.high,
          ),
          const Spacer(),
          const TopNotificationButton(),
        ],
      ),
    );
  }
}
