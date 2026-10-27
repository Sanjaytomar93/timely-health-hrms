import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/attendance/presentation/models/attendance_record_ui_model.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/dashboard_card.dart';

class AttendanceStatsRow extends StatelessWidget {
  const AttendanceStatsRow({super.key, required this.stats});

  final AttendanceStatsUiModel stats;

  static const _blue = Color(0xFF3B6FE0);
  static const _violet = Color(0xFF8E5CD9);

  @override
  Widget build(BuildContext context) {
    final tiles = <_StatTileData>[
      _StatTileData(
        icon: Icons.event_note_rounded,
        label: 'Total',
        value: '${stats.totalRecords}',
        caption: 'records',
        color: PortalColors.brandLight,
      ),
      _StatTileData(
        icon: Icons.apartment_rounded,
        label: 'Onsite',
        value: '${stats.onsiteDays}',
        caption: 'days',
        color: PortalColors.green,
      ),
      _StatTileData(
        icon: Icons.login_rounded,
        label: 'Checked In',
        value: '${stats.checkedIn}',
        caption: 'open',
        color: _blue,
      ),
      _StatTileData(
        icon: Icons.verified_rounded,
        label: 'Full Days',
        value: '${stats.fullDays}',
        caption: '8h+',
        color: PortalColors.red,
      ),
      _StatTileData(
        icon: Icons.timer_rounded,
        label: 'OT Hours',
        value: stats.otHoursLabel,
        caption: 'total',
        color: PortalColors.orange,
      ),
      _StatTileData(
        icon: Icons.task_alt_rounded,
        label: 'Claimed OT',
        value: '${stats.claimedOt}',
        caption: 'records',
        color: _violet,
      ),
    ];

    return DashboardCard(
      child: Column(
        children: [
          const DashboardCardHeader(
            icon: Icons.insights_rounded,
            color: PortalColors.brand,
            title: 'Attendance Overview',
            subtitle: 'Your all-time attendance summary',
          ),
          const SizedBox(height: 14),
          for (var row = 0; row < tiles.length; row += 3) ...[
            if (row > 0) const SizedBox(height: 10),
            Row(
              children: [
                for (var i = row; i < row + 3; i++) ...[
                  if (i > row) const SizedBox(width: 10),
                  Expanded(
                    child: i < tiles.length
                        ? _StatTile(data: tiles[i])
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatTileData {
  const _StatTileData({
    required this.icon,
    required this.label,
    required this.value,
    required this.caption,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final String caption;
  final Color color;
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.data});

  final _StatTileData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
      decoration: BoxDecoration(
        color: data.color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: data.color.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(data.icon, size: 15, color: data.color),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: data.value,
                    style: portalText(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: PortalColors.heading,
                      height: 22 / 18,
                    ),
                  ),
                  TextSpan(
                    text: ' ${data.caption}',
                    style: portalText(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w500,
                      color: PortalColors.muted,
                    ),
                  ),
                ],
              ),
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            data.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: data.color,
              height: 12 / 10,
            ),
          ),
        ],
      ),
    );
  }
}
