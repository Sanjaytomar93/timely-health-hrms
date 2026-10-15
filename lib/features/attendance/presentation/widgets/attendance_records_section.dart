import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/attendance/presentation/mappers/attendance_ui_mapper.dart';
import 'package:timelay_health/features/attendance/presentation/models/attendance_record_ui_model.dart';
import 'package:timelay_health/features/attendance/presentation/widgets/ot_available_banner.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/dashboard_card.dart';

const _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

const _weekdays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

const _activeBlue = Color(0xFF3B6FE0);
const _outGrey = Color(0xFFB7B5C7);
const _shiftViolet = Color(0xFF7C4DDB);
const _shiftTint = Color(0xFFF1EBFD);

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
    final entries = _buildEntries(records);

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 24),
      sliver: SliverList.builder(
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          return switch (entry) {
            _HeaderEntry() => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _SectionHeader(count: records.length),
            ),
            _EmptyEntry() => const _EmptyRecords(),
            _MonthEntry(:final label, :final count) => Padding(
              padding: EdgeInsets.only(top: index == 1 ? 0 : 6, bottom: 10),
              child: _MonthHeader(label: label, count: count),
            ),
            _RecordEntry(:final record) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: RepaintBoundary(
                child: AttendanceRecordCard(
                  key: ValueKey(record.id),
                  data: record,
                  otSelected: selectedOtIds.contains(record.id),
                  onToggleOt: record.hasClaimableOt && onToggleOt != null
                      ? () => onToggleOt!(record.id)
                      : null,
                ),
              ),
            ),
            _EndEntry() => Padding(
              padding: const EdgeInsets.only(top: 6),
              child: _EndOfList(count: records.length),
            ),
          };
        },
      ),
    );
  }

  static List<_Entry> _buildEntries(List<AttendanceRecordUiModel> list) {
    final entries = <_Entry>[const _HeaderEntry()];
    if (list.isEmpty) {
      entries.add(const _EmptyEntry());
      return entries;
    }

    final counts = <String, int>{};
    for (final record in list) {
      final key = _monthLabel(record);
      counts[key] = (counts[key] ?? 0) + 1;
    }

    String? current;
    for (final record in list) {
      final label = _monthLabel(record);
      if (label != current) {
        current = label;
        entries.add(_MonthEntry(label, counts[label]!));
      }
      entries.add(_RecordEntry(record));
    }
    entries.add(const _EndEntry());
    return entries;
  }

  static String _monthLabel(AttendanceRecordUiModel record) {
    final d = record.checkInDate;
    return d == null ? 'Other' : '${_months[d.month - 1]} ${d.year}';
  }
}

sealed class _Entry {
  const _Entry();
}

class _HeaderEntry extends _Entry {
  const _HeaderEntry();
}

class _EmptyEntry extends _Entry {
  const _EmptyEntry();
}

class _MonthEntry extends _Entry {
  const _MonthEntry(this.label, this.count);

  final String label;
  final int count;
}

class _RecordEntry extends _Entry {
  const _RecordEntry(this.record);

  final AttendanceRecordUiModel record;
}

class _EndEntry extends _Entry {
  const _EndEntry();
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _TodayCalendarBadge(),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Attendance Records',
                style: portalText(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: PortalColors.heading,
                  height: 18 / 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Daily check-in/out history with OT tracking',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: portalText(
                  fontSize: 10.5,
                  color: PortalColors.muted,
                  height: 13 / 10.5,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: PortalColors.brandTint,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$count ${count == 1 ? 'record' : 'records'}',
            style: portalText(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: PortalColors.brand,
            ),
          ),
        ),
      ],
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 14,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: PortalColors.brandGradient,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: portalText(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: PortalColors.secondaryText,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Container(height: 1, color: PortalColors.border)),
        const SizedBox(width: 8),
        Text(
          '$count',
          style: portalText(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: PortalColors.muted,
          ),
        ),
      ],
    );
  }
}

class _EmptyRecords extends StatelessWidget {
  const _EmptyRecords();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: dashboardCardDecoration(),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  PortalColors.brandTint,
                  PortalColors.brandLight.withValues(alpha: 0.18),
                ],
              ),
            ),
            child: const Icon(
              Icons.event_busy_rounded,
              size: 30,
              color: PortalColors.brandLight,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No attendance records yet',
            style: portalText(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: PortalColors.heading,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Check in to see your attendance history here, or adjust your filters.',
            textAlign: TextAlign.center,
            style: portalText(
              fontSize: 11.5,
              color: PortalColors.muted,
              height: 16 / 11.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _EndOfList extends StatelessWidget {
  const _EndOfList({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: PortalColors.border)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  size: 13,
                  color: PortalColors.green,
                ),
                const SizedBox(width: 5),
                Text(
                  "You're all caught up · $count shown",
                  style: portalText(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: PortalColors.muted,
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: Container(height: 1, color: PortalColors.border)),
        ],
      ),
    );
  }
}

class _TodayCalendarBadge extends StatelessWidget {
  const _TodayCalendarBadge();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Container(
      width: 36,
      height: 38,
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: PortalColors.border),
        boxShadow: [
          BoxShadow(
            color: PortalColors.brand.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            height: 12,
            width: double.infinity,
            color: PortalColors.red,
            alignment: Alignment.center,
            child: Text(
              _months[now.month - 1].substring(0, 3).toUpperCase(),
              style: portalText(
                fontSize: 7.5,
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
                  fontSize: 15,
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
    final selectable = onToggleOt != null;
    final highlighted = selectable && otSelected;
    final statusColor = data.isActive ? PortalColors.green : PortalColors.red;
    final timeColor = data.isActive ? _activeBlue : PortalColors.green;
    final outColor = data.isActive ? _outGrey : PortalColors.green;

    final card = Container(
      decoration: BoxDecoration(
        color: highlighted ? OtColors.bg : PortalColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlighted ? OtColors.accent : PortalColors.border,
          width: highlighted ? 1.4 : 1,
        ),
        boxShadow: highlighted
            ? [
                BoxShadow(
                  color: OtColors.accent.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(11, 11, 11, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DateTile(date: data.checkInDate, fallback: data.date),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: _LocationLabel(data: data)),
                          const SizedBox(width: 6),
                          _StatusPill(
                            label: data.statusLabel,
                            color: statusColor,
                            pulsing: data.isActive,
                          ),
                          if (selectable) ...[
                            const SizedBox(width: 6),
                            _OtCheck(selected: otSelected),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _TimeBlock(
                              icon: Icons.login_rounded,
                              label: 'Check In',
                              value: data.checkIn,
                              color: timeColor,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 22,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            color: PortalColors.border,
                          ),
                          Expanded(
                            child: _TimeBlock(
                              icon: Icons.logout_rounded,
                              label: 'Check Out',
                              value: data.checkOut,
                              color: outColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            _HoursProgress(data: data),
            const SizedBox(height: 8),
            Wrap(
              spacing: 5,
              runSpacing: 5,
              children: [
                _Tag(
                  icon: Icons.schedule_rounded,
                  text: data.shiftTag,
                  bg: _shiftTint,
                  color: _shiftViolet,
                ),
                _Tag(
                  icon: Icons.near_me_rounded,
                  text: data.distanceTag,
                  bg: PortalColors.background,
                  color: PortalColors.muted,
                  bordered: true,
                ),
                if (data.claimableOtHours > 0)
                  _Tag(
                    icon: data.otClaimed
                        ? Icons.task_alt_rounded
                        : Icons.timer_rounded,
                    text: data.otClaimed
                        ? 'OT ${AttendanceUiMapper.hoursLabel(data.claimableOtHours)} claimed'
                        : '+${AttendanceUiMapper.hoursLabel(data.claimableOtHours)} OT',
                    bg: data.otClaimed ? PortalColors.greenTint : OtColors.tint,
                    color: data.otClaimed ? PortalColors.green : OtColors.text,
                  ),
              ],
            ),
            if (data.note.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
                decoration: BoxDecoration(
                  color: PortalColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 1),
                      child: Icon(
                        Icons.sticky_note_2_outlined,
                        size: 12,
                        color: PortalColors.muted,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        data.note,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: portalText(
                          fontSize: 10.5,
                          color: PortalColors.secondaryText,
                          height: 14 / 10.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
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

class _DateTile extends StatelessWidget {
  const _DateTile({required this.date, required this.fallback});

  final DateTime? date;
  final String fallback;

  @override
  Widget build(BuildContext context) {
    final d = date;
    final now = DateTime.now();
    final isToday =
        d != null &&
        d.year == now.year &&
        d.month == now.month &&
        d.day == now.day;

    final fg = isToday ? Colors.white : PortalColors.brand;
    final sub = isToday
        ? Colors.white.withValues(alpha: 0.8)
        : PortalColors.muted;

    return Container(
      width: 46,
      padding: const EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(
        color: isToday ? null : PortalColors.brandTint,
        gradient: isToday
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: PortalColors.brandGradient,
              )
            : null,
        borderRadius: BorderRadius.circular(11),
      ),
      child: d == null
          ? Text(
              fallback,
              textAlign: TextAlign.center,
              style: portalText(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            )
          : Column(
              children: [
                Text(
                  isToday ? 'TODAY' : _weekdays[d.weekday - 1],
                  style: portalText(
                    fontSize: 7.5,
                    fontWeight: FontWeight.w800,
                    color: sub,
                    letterSpacing: 0.5,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  d.day.toString().padLeft(2, '0'),
                  style: portalText(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: fg,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _months[d.month - 1].substring(0, 3),
                  style: portalText(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: sub,
                    height: 1,
                  ),
                ),
              ],
            ),
    );
  }
}

class _LocationLabel extends StatelessWidget {
  const _LocationLabel({required this.data});

  final AttendanceRecordUiModel data;

  @override
  Widget build(BuildContext context) {
    final parts = data.locationTag.split(' ');
    final stripped = parts.length > 1 ? parts.skip(1).join(' ') : '';
    final label = stripped.isEmpty
        ? (data.onsite ? 'Onsite' : 'WFH')
        : stripped;
    const color = PortalColors.orange;

    return Row(
      children: [
        Icon(
          data.onsite ? Icons.apartment_rounded : Icons.home_rounded,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.color,
    required this.pulsing,
  });

  final String label;
  final Color color;
  final bool pulsing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: pulsing
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: portalText(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _OtCheck extends StatelessWidget {
  const _OtCheck({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: selected ? OtColors.accent : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: OtColors.accent, width: 1.5),
      ),
      child: selected
          ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
          : null,
    );
  }
}

class _TimeBlock extends StatelessWidget {
  const _TimeBlock({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(icon, size: 12, color: color),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                style: portalText(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w600,
                  color: PortalColors.muted,
                  height: 10 / 8.5,
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: portalText(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: color,
                    height: 14 / 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HoursProgress extends StatelessWidget {
  const _HoursProgress({required this.data});

  final AttendanceRecordUiModel data;

  @override
  Widget build(BuildContext context) {
    final shift = data.assignedShiftHours > 0 ? data.assignedShiftHours : 9.0;
    final ratio = (data.workingHours / shift).clamp(0.0, 1.0);
    final hasOt = data.claimableOtHours > 0;
    final shiftDone = data.workingHours >= shift;
    final workedColor = hasOt
        ? OtColors.text
        : shiftDone
        ? PortalColors.green
        : PortalColors.red;
    final barColors = hasOt
        ? OtColors.gradient
        : [workedColor.withValues(alpha: 0.7), workedColor];

    return Column(
      children: [
        Row(
          children: [
            Text(
              'Worked ',
              style: portalText(fontSize: 9.5, color: PortalColors.muted),
            ),
            Text(
              data.durationTag,
              style: portalText(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: workedColor,
              ),
            ),
            const Spacer(),
            Text(
              '${(ratio * 100).round()}% of ${AttendanceUiMapper.hoursLabel(shift)}',
              style: portalText(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: PortalColors.muted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 4,
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: PortalColors.background,
            borderRadius: BorderRadius.circular(999),
          ),
          child: FractionallySizedBox(
            widthFactor: ratio,
            heightFactor: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: barColors),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.icon,
    required this.text,
    required this.bg,
    required this.color,
    this.bordered = false,
  });

  final IconData icon;
  final String text;
  final Color bg;
  final Color color;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(7),
        border: bordered ? Border.all(color: PortalColors.border) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            text,
            style: portalText(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
