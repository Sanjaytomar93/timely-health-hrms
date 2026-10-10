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
      padding: const EdgeInsets.only(top: 18),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(11, 0, 12, 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              _ShiftStatCard(data: cards[i]),
            ],
          ],
        ),
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
      width: 118,
      padding: const EdgeInsets.fromLTRB(13, 13, 10, 12),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(data.iconAsset, width: 26, height: 26),
          const SizedBox(height: 8),
          Text(
            data.title.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 8.8,
              fontWeight: FontWeight.w700,
              color: PortalColors.muted,
              letterSpacing: 0.4,
              height: 1.15,
            ),
          ),
          Text(
            data.value,
            style: portalText(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: PortalColors.green,
              height: 1.15,
            ),
          ),
          Text(
            data.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 9.5,
              fontWeight: FontWeight.w400,
              color: PortalColors.muted,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }
}
