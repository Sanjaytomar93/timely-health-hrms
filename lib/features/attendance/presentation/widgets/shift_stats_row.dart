import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/attendance/presentation/models/shift_ui_model.dart';

class ShiftStatsRow extends StatelessWidget {
  const ShiftStatsRow({super.key, required this.stats});

  final ShiftStatsUiModel stats;

  @override
  Widget build(BuildContext context) {
    final cards = <_ShiftStatData>[
      _ShiftStatData(
        title: 'Total Shifts',
        value: '${stats.totalShifts}',
        subtitle: 'listed',
        iconAsset: 'assets/icons/attendance/stats/ic_att_total_records.svg',
      ),
      _ShiftStatData(
        title: 'Ongoing',
        value: '${stats.ongoing}',
        subtitle: 'Right now',
        iconAsset: 'assets/icons/attendance/stats/ic_att_onsite_days.svg',
      ),
      _ShiftStatData(
        title: 'Upcoming',
        value: '${stats.upcoming}',
        subtitle: 'next',
        iconAsset: 'assets/icons/attendance/stats/ic_att_checked_in.svg',
      ),
      _ShiftStatData(
        title: 'Scheduled',
        value: '${stats.scheduled}',
        subtitle: 'Changes',
        iconAsset: 'assets/icons/attendance/stats/ic_att_full_days.svg',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          for (var i = 0; i < cards.length; i += 2) ...[
            if (i > 0) const SizedBox(height: 10),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _ShiftStatCard(data: cards[i])),
                  const SizedBox(width: 10),
                  Expanded(
                    child: i + 1 < cards.length
                        ? _ShiftStatCard(data: cards[i + 1])
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ShiftStatData {
  const _ShiftStatData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.iconAsset,
  });

  final String title;
  final String value;
  final String subtitle;
  final String iconAsset;
}

class _ShiftStatCard extends StatelessWidget {
  const _ShiftStatCard({required this.data});

  final _ShiftStatData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PortalColors.border),
      ),
      child: Row(
        children: [
          SvgPicture.asset(data.iconAsset, width: 44, height: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.muted,
                    letterSpacing: 0.4,
                    height: 12 / 10,
                  ),
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: data.value,
                        style: portalText(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: PortalColors.green,
                          height: 24 / 20,
                        ),
                      ),
                      TextSpan(
                        text: ' ${data.subtitle}',
                        style: portalText(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: PortalColors.muted,
                          height: 24 / 11,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
