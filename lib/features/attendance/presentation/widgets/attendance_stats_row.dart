import 'package:flutter/material.dart';
import 'package:timelay_health/features/attendance/presentation/models/attendance_record_ui_model.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/stat_cards_row.dart';

class AttendanceStatsRow extends StatelessWidget {
  const AttendanceStatsRow({super.key, required this.stats});

  final AttendanceStatsUiModel stats;

  @override
  Widget build(BuildContext context) {
    final cards = <StatCardData>[
      StatCardData(
        title: 'Total Records',
        value: '${stats.totalRecords}',
        subtitle: 'all time',
        iconAsset: 'assets/icons/attendance/stats/ic_att_total_records.svg',
      ),
      StatCardData(
        title: 'Onsite Days',
        value: '${stats.onsiteDays}',
        subtitle: 'office check-ins',
        iconAsset: 'assets/icons/attendance/stats/ic_att_onsite_days.svg',
      ),
      StatCardData(
        title: 'Checked In',
        value: '${stats.checkedIn}',
        subtitle: 'open sessions',
        iconAsset: 'assets/icons/attendance/stats/ic_att_checked_in.svg',
      ),
      StatCardData(
        title: 'Full Days',
        value: '${stats.fullDays}',
        subtitle: '8h+ days',
        iconAsset: 'assets/icons/attendance/stats/ic_att_full_days.svg',
      ),
      StatCardData(
        title: 'OT Hours',
        value: stats.otHoursLabel,
        subtitle: 'accumulated',
        iconAsset: 'assets/icons/attendance/stats/ic_att_ot_hours.svg',
      ),
      StatCardData(
        title: 'Claimed OT',
        value: '${stats.claimedOt}',
        subtitle: 'records claimed',
        iconAsset: 'assets/icons/attendance/stats/ic_att_claimed_ot.svg',
      ),
    ];

    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = ((screenWidth - 23 - 20) / 3.2).clamp(110.0, 130.0);

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
        child: Row(
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              StatCard(data: cards[i], width: cardWidth),
            ],
          ],
        ),
      ),
    );
  }
}
