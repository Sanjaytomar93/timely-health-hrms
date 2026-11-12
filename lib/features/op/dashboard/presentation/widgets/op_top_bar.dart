import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/routes/app_routes.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/auth/data/auth_session.dart';

class OpTopBar extends StatelessWidget {
  const OpTopBar({
    super.key,
    this.title = 'OP Dashboard',
    this.onMenuTap,
    this.light = true,
    this.showBack = false,
  });

  final String title;
  final VoidCallback? onMenuTap;
  final bool light;
  final bool showBack;

  void _goToHrms(BuildContext context) {
    Navigator.of(context).popUntil(
      (route) => route.isFirst || route.settings.name == AppRoutes.home,
    );
  }

  @override
  Widget build(BuildContext context) {
    final employee = AuthSession.currentEmployee;
    final initial = (employee?.displayName.trim().isNotEmpty ?? false)
        ? employee!.displayName.trim()[0].toUpperCase()
        : 'U';

    return Container(
      height: 58,
      color: PortalColors.brand,
      padding: const EdgeInsets.fromLTRB(16, 0, 12, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: onMenuTap ?? () => _goToHrms(context),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: PortalColors.brandTint,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: showBack
                  ? const Icon(
                      Icons.arrow_back_rounded,
                      size: 18,
                      color: PortalColors.brand,
                    )
                  : SvgPicture.asset(
                      'assets/icons/top_bar/ic_top_menu.svg',
                      width: 18,
                      height: 18,
                    ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: portalText(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              _RoundIcon(
                bg: Colors.white.withValues(alpha: 0.14),
                onTap: () => AppRoutes.push(context, AppRoutes.notifications),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  size: 22,
                  color: Colors.white,
                ),
              ),
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: PortalColors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _goToHrms(context),
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: PortalColors.brandLight,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Text(
                initial,
                style: portalText(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({
    required this.bg,
    required this.onTap,
    required this.child,
  });

  final Color bg;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(width: 42, height: 42, child: Center(child: child)),
      ),
    );
  }
}
