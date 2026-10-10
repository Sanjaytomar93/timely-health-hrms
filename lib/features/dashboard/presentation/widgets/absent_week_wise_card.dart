import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/dashboard/presentation/models/dashboard_home_ui.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/weekly_bar_chart_card.dart';

class AbsentWeekWiseCard extends StatelessWidget {
  const AbsentWeekWiseCard({
    super.key,
    required this.data,
    required this.monthLabel,
    this.onMonthTap,
  });

  static const _weekColors = [
    Color(0xFFE0483E),
    Color(0xFFEC407A),
    Color(0xFF7E57C2),
    Color(0xFF5C6BC0),
    Color(0xFF29B6F6),
  ];
  static const _rowHeight = 26.0;
  static const _rowGap = 4.0;
  static const _minBodyHeight = 146.0;

  final DashboardAbsentUi data;
  final String monthLabel;
  final VoidCallback? onMonthTap;

  static Color _weekColor(int i) => _weekColors[i % _weekColors.length];

  @override
  Widget build(BuildContext context) {
    final weeks = data.weeks;
    final rowsHeight = weeks.isEmpty
        ? 0.0
        : weeks.length * _rowHeight + (weeks.length - 1) * _rowGap;
    final bodyHeight = math.max(_minBodyHeight, rowsHeight);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      padding: const EdgeInsets.fromLTRB(19, 17, 17, 14),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        children: [
          _header(),
          const SizedBox(height: 14),
          SizedBox(
            height: bodyHeight,
            child: Row(
              children: [
                Expanded(flex: 8, child: _donutColumn()),
                Container(
                  width: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  color: PortalColors.border,
                ),
                Expanded(
                  flex: 13,
                  child: weeks.isEmpty
                      ? Center(
                          child: Text(
                            'No data',
                            style: portalText(
                              fontSize: 11,
                              color: PortalColors.muted,
                            ),
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            for (var i = 0; i < weeks.length; i++)
                              SizedBox(
                                height: _rowHeight,
                                child: _WeekRow(
                                  week: weeks[i],
                                  color: _weekColor(i),
                                ),
                              ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: PortalColors.redTint,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.person_remove_outlined,
            size: 18,
            color: PortalColors.red,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  'Absent Days (Week Wise)',
                  maxLines: 1,
                  style: portalText(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 18 / 14,
                  ),
                ),
              ),
              if (data.periodLabel.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  data.periodLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: PortalColors.muted,
                    height: 13 / 10.5,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        DashboardMonthChip(label: monthLabel, onTap: onMonthTap),
      ],
    );
  }

  Widget _donutColumn() {
    final segments = <Color>[];
    for (var i = 0; i < data.weeks.length; i++) {
      final w = data.weeks[i];
      for (var d = 0; d < w.workingDays; d++) {
        segments.add(d < w.absentDays ? _weekColor(i) : PortalColors.border);
      }
    }
    while (segments.length < data.totalWorkingDays) {
      segments.add(PortalColors.border);
    }

    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, c) {
              final size = math.min(c.maxWidth, c.maxHeight);
              return Center(
                child: SizedBox.square(
                  dimension: size,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (context, t, child) => CustomPaint(
                      painter: _DonutPainter(segments: segments, progress: t),
                      child: child,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(size * 0.22),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${data.totalAbsent}',
                              style: portalText(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: PortalColors.heading,
                                height: 1.1,
                              ),
                            ),
                            Text(
                              'Absent Days',
                              style: portalText(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: PortalColors.heading,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'out of ${data.totalWorkingDays}\nWorking Days',
                              textAlign: TextAlign.center,
                              style: portalText(
                                fontSize: 8,
                                fontWeight: FontWeight.w500,
                                color: PortalColors.muted,
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 2,
          children: [
            _legend(
              'Absent',
              const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: _weekColors),
              ),
            ),
            _legend(
              'Working Day',
              const BoxDecoration(
                shape: BoxShape.circle,
                color: PortalColors.border,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _legend(String label, BoxDecoration dot) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: dot),
        const SizedBox(width: 4),
        Text(
          label,
          style: portalText(
            fontSize: 9.5,
            fontWeight: FontWeight.w500,
            color: PortalColors.secondaryText,
            height: 12 / 9.5,
          ),
        ),
      ],
    );
  }
}

class _WeekRow extends StatelessWidget {
  const _WeekRow({required this.week, required this.color});

  final DashboardAbsentWeekUi week;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final slots = math.max(7, week.workingDays);
    final absent = week.absentDays;

    return Row(
      children: [
        SizedBox(
          width: 54,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                week.label,
                maxLines: 1,
                style: portalText(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: PortalColors.heading,
                  height: 14 / 11.5,
                ),
              ),
              if (week.dateRange.isNotEmpty)
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    week.dateRange,
                    maxLines: 1,
                    style: portalText(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w500,
                      color: PortalColors.muted,
                      height: 11 / 8.5,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SizedBox(
            height: 22,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < slots; i++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1.5),
                      child: i >= week.workingDays
                          ? const SizedBox.shrink()
                          : DecoratedBox(
                              decoration: i < absent
                                  ? BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Color.lerp(color, Colors.white, 0.25)!,
                                          color,
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: color.withValues(alpha: 0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1.5),
                                        ),
                                      ],
                                    )
                                  : BoxDecoration(
                                      color: PortalColors.border,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                            ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 18,
          child: Text(
            '$absent',
            textAlign: TextAlign.right,
            style: portalText(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: PortalColors.heading,
              height: 17 / 14,
            ),
          ),
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.segments, required this.progress});

  final List<Color> segments;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.shortestSide * 0.16;
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: (size.shortestSide - stroke) / 2,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    if (segments.isEmpty) {
      paint.color = PortalColors.border;
      canvas.drawArc(rect, 0, 2 * math.pi, false, paint);
      return;
    }

    final sweep = 2 * math.pi / segments.length;
    final gap = segments.length > 1 ? math.min(0.06, sweep * 0.3) : 0.0;
    final limit = 2 * math.pi * progress;
    for (var i = 0; i < segments.length; i++) {
      final start = i * sweep;
      if (start >= limit) break;
      final length = math.min(sweep - gap, limit - start);
      if (length <= 0) continue;
      paint.color = segments[i];
      canvas.drawArc(rect, -math.pi / 2 + start, length, false, paint);
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.progress != progress || old.segments != segments;
}
