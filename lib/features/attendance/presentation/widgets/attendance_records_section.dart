import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/attendance/presentation/mappers/attendance_ui_mapper.dart';
import 'package:timelay_health/features/attendance/presentation/models/attendance_record_ui_model.dart';
import 'package:timelay_health/features/attendance/presentation/widgets/ot_available_banner.dart';

class AttendanceRecordsSection extends StatelessWidget {
  const AttendanceRecordsSection({
    super.key,
    required this.records,
    this.selectedOtIds = const {},
    this.onToggleOt,
  });

  final List<AttendanceRecordUiModel> records;
  final Set<String> selectedOtIds;
  final ValueChanged<String>? onToggleOt;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _TodayCalendarBadge(),
              const SizedBox(width: 7),
              Text(
                'Attendance Records',
                style: portalText(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: PortalColors.heading,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            records.isEmpty
                ? 'No attendance records found yet.'
                : 'Your daily check-in/out history with OT tracking.',
            style: portalText(fontSize: 10.5, color: PortalColors.muted),
          ),
          const SizedBox(height: 12),
          if (records.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: PortalColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: PortalColors.border),
              ),
              child: Text(
                'Check in to see your attendance history here.',
                textAlign: TextAlign.center,
                style: portalText(fontSize: 12, color: PortalColors.muted),
              ),
            )
          else
            for (final record in records) ...[
              AttendanceRecordCard(
                data: record,
                otSelected: selectedOtIds.contains(record.id),
                onToggleOt: record.hasClaimableOt && onToggleOt != null
                    ? () => onToggleOt!(record.id)
                    : null,
              ),
              const SizedBox(height: 10),
            ],
          if (records.isNotEmpty) ...[
            const SizedBox(height: 4),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0D6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'View all ${records.length} records ›',
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.purple,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _TodayCalendarBadge extends StatelessWidget {
  const _TodayCalendarBadge();

  static const _months = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
  ];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Container(
      width: 20,
      height: 21,
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: PortalColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            height: 7,
            width: double.infinity,
            color: PortalColors.red,
            alignment: Alignment.center,
            child: Text(
              _months[now.month - 1],
              style: portalText(
                fontSize: 5,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                '${now.day}',
                style: portalText(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: PortalColors.heading,
                  height: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AttendanceRecordCard extends StatelessWidget {
  const AttendanceRecordCard({
    super.key,
    required this.data,
    this.otSelected = false,
    this.onToggleOt,
  });

  final AttendanceRecordUiModel data;
  final bool otSelected;
  final VoidCallback? onToggleOt;

  @override
  Widget build(BuildContext context) {
    final statusColor = data.isActive ? PortalColors.green : PortalColors.red;
    final statusBg = data.isActive
        ? PortalColors.greenTint
        : PortalColors.redTint;
    final timeColor = data.isActive
        ? const Color(0xFF3B6FE0)
        : PortalColors.green;
    final outColor = data.isActive
        ? const Color(0xFFB7B5C7)
        : PortalColors.green;

    final selectable = onToggleOt != null;
    final highlighted = selectable && otSelected;

    final card = Container(
      padding: const EdgeInsets.fromLTRB(13, 13, 13, 12),
      decoration: BoxDecoration(
        color: highlighted ? OtColors.bg : PortalColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlighted ? OtColors.accent : PortalColors.border,
          width: highlighted ? 1.3 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (selectable) ...[
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Checkbox(
                    value: otSelected,
                    onChanged: (_) => onToggleOt!(),
                    activeColor: OtColors.accent,
                    side: const BorderSide(color: OtColors.accent, width: 1.4),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  data.date,
                  style: portalText(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.heading,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      data.statusLabel,
                      style: portalText(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: data.checkIn,
                  style: portalText(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: timeColor,
                  ),
                ),
                TextSpan(
                  text: '  /  ',
                  style: portalText(
                    fontSize: 12.5,
                    color: const Color(0xFFB7B5C7),
                  ),
                ),
                TextSpan(
                  text: data.checkOut,
                  style: portalText(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: outColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _Tag(
                text: data.shiftTag,
                bg: PortalColors.purpleTint,
                color: PortalColors.purple,
              ),
              _Tag(
                text: data.durationTag,
                bg: PortalColors.redTint,
                color: PortalColors.red,
              ),
              _Tag(
                text: data.locationTag,
                bg: PortalColors.orangeTint,
                color: PortalColors.orange,
              ),
              _Tag(
                text: data.distanceTag,
                bg: PortalColors.background,
                color: PortalColors.muted,
                bordered: true,
              ),
              if (data.claimableOtHours > 0)
                _Tag(
                  text: data.otClaimed
                      ? '✓ OT ${AttendanceUiMapper.hoursLabel(data.claimableOtHours)} claimed'
                      : '+${AttendanceUiMapper.hoursLabel(data.claimableOtHours)} OT',
                  bg: data.otClaimed ? PortalColors.greenTint : OtColors.tint,
                  color: data.otClaimed ? PortalColors.green : OtColors.text,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            data.note,
            style: portalText(fontSize: 11, color: PortalColors.muted),
          ),
        ],
      ),
    );

    if (!selectable) return card;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onToggleOt,
      child: card,
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.text,
    required this.bg,
    required this.color,
    this.bordered = false,
  });

  final String text;
  final Color bg;
  final Color color;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(7),
        border: bordered ? Border.all(color: PortalColors.border) : null,
      ),
      child: Text(
        text,
        style: portalText(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
