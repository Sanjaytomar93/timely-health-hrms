import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/dashboard/presentation/models/dashboard_home_ui.dart';

class RecentActivityCard extends StatelessWidget {
  const RecentActivityCard({super.key, this.items = const []});

  final List<DashboardActivityUi> items;

  @override
  Widget build(BuildContext context) {
    final rows = items;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(17, 16, 17, 4),
            decoration: BoxDecoration(
              color: PortalColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: PortalColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 2),
                    SvgPicture.asset(
                      'assets/icons/recent_activity/ic_recent_activity.svg',
                      width: 18,
                      height: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Recent Activity',
                      style: portalText(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF000000),
                        height: 16 / 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 17),
                if (rows.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'No recent activity',
                      style: portalText(
                        fontSize: 12,
                        color: PortalColors.muted,
                      ),
                    ),
                  )
                else
                  for (var i = 0; i < rows.length; i++) ...[
                    if (i > 0)
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: PortalColors.border,
                      ),
                    _ActivityRow(item: rows[i]),
                  ],
              ],
            ),
          ),
          const SizedBox(height: 17),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'See All',
                  style: portalText(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.brand,
                    height: 18 / 15,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 11,
                  color: PortalColors.brand,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.item});

  final DashboardActivityUi item;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: LayoutBuilder(
        builder: (context, constraints) => Row(
          children: [
            SizedBox(
              width: constraints.maxWidth * 150 / 386,
              child: Text(
                item.date,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: portalText(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: PortalColors.heading,
                  height: 15 / 12.5,
                ),
              ),
            ),
            Expanded(
              child: Text(
                item.time,
                style: portalText(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w400,
                  color: PortalColors.muted,
                  height: 13 / 10.5,
                ),
              ),
            ),
            Container(
              height: item.isIn ? 19 : 20,
              padding: const EdgeInsets.symmetric(horizontal: 9),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: item.isIn
                    ? PortalColors.greenTint
                    : PortalColors.redTint,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                item.isIn ? '✓ In' : '✕ Checked-out',
                style: portalText(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: item.isIn ? PortalColors.green : PortalColors.red,
                  height: 12 / 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
