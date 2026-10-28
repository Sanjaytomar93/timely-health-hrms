import 'package:flutter/material.dart';
import 'package:timelay_health/core/routes/app_routes.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/camp/presentation/theme/camp_colors.dart';

class CampTopBar extends StatelessWidget {
  const CampTopBar({super.key});

  static const _logoAsset = 'assets/images/camp_timely_health_logo.png';

  void _goToHrms(BuildContext context) {
    Navigator.of(context).popUntil(
      (route) => route.isFirst || route.settings.name == AppRoutes.home,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: CampColors.surface,
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => _goToHrms(context),
                behavior: HitTestBehavior.opaque,
                child: Image.asset(
                  _logoAsset,
                  height: 38,
                  fit: BoxFit.contain,
                  alignment: Alignment.centerLeft,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          ),
          Material(
            color: const Color(0xFFF3F3FA),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () => AppRoutes.push(context, AppRoutes.notifications),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  size: 20,
                  color: CampColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: CampColors.primary,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () => _goToHrms(context),
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 38,
                height: 38,
                child: Center(
                  child: Text(
                    'AD',
                    style: portalText(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
