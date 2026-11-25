import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/admin/dashboard/data/repositories_impl/admin_dashboard_repository_impl.dart';
import 'package:timelay_health/features/admin/dashboard/presentation/models/admin_dashboard_ui.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/dashboard_card.dart';

class AdminTotalStaffCard extends StatelessWidget {
  const AdminTotalStaffCard({
    super.key,
    required this.totalStaff,
    this.onTap,
  });

  final int totalStaff;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: PortalColors.brandGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: PortalColors.brand.withValues(alpha: 0.16),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: radius),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2.5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'TOTAL STAFF',
                                style: portalText(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            '$totalStaff',
                            style: portalText(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.3,
                              height: 1.1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.trending_up_rounded,
                              size: 13,
                              color: Colors.greenAccent.shade200,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'active employees',
                              style: portalText(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.groups_rounded,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AdminStatCardsGrid extends StatelessWidget {
  const AdminStatCardsGrid({
    super.key,
    required this.metrics,
    this.onPresentTap,
    this.onAbsentTap,
    this.onLateTap,
    this.onRateTap,
  });

  final List<AdminStatMetric> metrics;
  final VoidCallback? onPresentTap;
  final VoidCallback? onAbsentTap;
  final VoidCallback? onLateTap;
  final VoidCallback? onRateTap;

  @override
  Widget build(BuildContext context) {
    if (metrics.isEmpty) return const SizedBox.shrink();

    final present = metrics.firstWhere(
      (m) => m.title.toLowerCase().contains('present'),
      orElse: () => const AdminStatMetric(
        title: 'Present Today',
        value: '0',
        subtitle: 'employees present',
        icon: Icons.login_rounded,
        color: Color(0xFF059669),
      ),
    );
    final absent = metrics.firstWhere(
      (m) => m.title.toLowerCase().contains('absent'),
      orElse: () => const AdminStatMetric(
        title: 'Absent Today',
        value: '0',
        subtitle: 'absent employees',
        icon: Icons.person_off_outlined,
        color: Color(0xFFEF4444),
      ),
    );
    final lateM = metrics.firstWhere(
      (m) => m.title.toLowerCase().contains('late'),
      orElse: () => const AdminStatMetric(
        title: 'Late Arrival',
        value: '0',
        subtitle: 'late records',
        icon: Icons.access_time_rounded,
        color: Color(0xFFD97706),
      ),
    );
    final rate = metrics.firstWhere(
      (m) => m.title.toLowerCase().contains('rate'),
      orElse: () => const AdminStatMetric(
        title: 'Attendance Rate',
        value: '0%',
        subtitle: 'overall rate',
        icon: Icons.percent_rounded,
        color: Color(0xFF2563EB),
      ),
    );

    final items = [
      _StatCardItem(
        title: 'PRESENT TODAY',
        value: present.value,
        subtitle: 'employees present',
        icon: Icons.how_to_reg_outlined,
        iconColor: const Color(0xFF10B981),
        bgColor: const Color(0xFFECFDF5),
        onTap: onPresentTap,
      ),
      _StatCardItem(
        title: 'ABSENT TODAY',
        value: absent.value,
        subtitle: 'absent employees',
        icon: Icons.person_remove_outlined,
        iconColor: const Color(0xFFEF4444),
        bgColor: const Color(0xFFFEF2F2),
        onTap: onAbsentTap,
      ),
      _StatCardItem(
        title: 'LATE ARRIVAL',
        value: lateM.value,
        subtitle: 'late arrivals',
        icon: Icons.access_time_rounded,
        iconColor: const Color(0xFFF59E0B),
        bgColor: const Color(0xFFFFFBEB),
        onTap: onLateTap,
      ),
      _StatCardItem(
        title: 'ATTENDANCE RATE',
        value: rate.value,
        subtitle: 'overall rate',
        icon: Icons.trending_up_rounded,
        iconColor: const Color(0xFF3B82F6),
        bgColor: const Color(0xFFEFF6FF),
        onTap: onRateTap,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const horizontalPadding = 32.0;
          const spacing = 8.0;
          final cardWidth =
              ((constraints.maxWidth - horizontalPadding - (2 * spacing)) / 3)
                  .clamp(100.0, 200.0);

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0) const SizedBox(width: spacing),
                  _GridStatCard(
                    item: items[i],
                    width: cardWidth,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCardItem {
  const _StatCardItem({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    this.onTap,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final VoidCallback? onTap;
}

class _GridStatCard extends StatelessWidget {
  const _GridStatCard({
    required this.item,
    required this.width,
  });

  final _StatCardItem item;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          width: width,
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        item.title,
                        style: portalText(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF64748B),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: item.bgColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Icon(item.icon, size: 14, color: item.iconColor),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  item.value,
                  style: portalText(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  item.subtitle,
                  style: portalText(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminTodayAttendanceCard extends StatelessWidget {
  const AdminTodayAttendanceCard({
    super.key,
    required this.slices,
    required this.overallRate,
    this.onMenuTap,
  });

  final List<AdminAttendanceSlice> slices;
  final double overallRate;
  final VoidCallback? onMenuTap;

  @override
  Widget build(BuildContext context) {
    // Show all active slices in the multicolor donut circle
    final activeSlices = slices.where((s) => s.count > 0 || s.fraction > 0).toList();
    final painterSlices = activeSlices.isNotEmpty ? activeSlices : slices;

    return DashboardCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(9),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.pie_chart_outline_rounded,
                  size: 18,
                  color: Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Today's Attendance",
                  style: portalText(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: PortalColors.heading,
                  ),
                ),
              ),
              InkWell(
                onTap: onMenuTap,
                borderRadius: BorderRadius.circular(16),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.more_vert_rounded,
                    size: 20,
                    color: PortalColors.muted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 118,
                height: 118,
                child: CustomPaint(
                  painter: _MultiSegmentDonutPainter(slices: painterSlices),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${overallRate.toStringAsFixed(0)}%',
                          style: portalText(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: PortalColors.heading,
                            height: 1.05,
                          ),
                        ),
                        Text(
                          'Overall',
                          style: portalText(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: PortalColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final s in slices)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3.5),
                        child: Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: s.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                s.label,
                                style: portalText(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: PortalColors.secondaryText,
                                ),
                              ),
                            ),
                            Text(
                              '${s.count} (${s.percentLabel})',
                              style: portalText(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: PortalColors.heading,
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
        ],
      ),
    );
  }
}

class _MultiSegmentDonutPainter extends CustomPainter {
  _MultiSegmentDonutPainter({required this.slices});

  final List<AdminAttendanceSlice> slices;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 8;
    const strokeW = 12.0;

    final bgPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW;
    canvas.drawCircle(c, r, bgPaint);

    final activeSlices =
        slices.where((s) => s.count > 0 || s.fraction > 0).toList();
    final total = activeSlices.fold<int>(0, (sum, s) => sum + s.count);

    if (total <= 0 &&
        (activeSlices.isEmpty || activeSlices.every((s) => s.fraction <= 0))) {
      // Default multicolor segments
      final defaultSlices = [
        (0.27, const Color(0xFF10B981)), // Green
        (0.12, const Color(0xFF06B6D4)), // Cyan
        (0.15, const Color(0xFFF59E0B)), // Amber
        (0.46, const Color(0xFFEF4444)), // Red
      ];
      var start = -math.pi / 2;
      for (final s in defaultSlices) {
        final sweep = s.$1 * math.pi * 2;
        final paint = Paint()
          ..color = s.$2
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW
          ..strokeCap = StrokeCap.butt;
        canvas.drawArc(
          Rect.fromCircle(center: c, radius: r),
          start,
          sweep,
          false,
          paint,
        );
        start += sweep;
      }
      return;
    }

    var startAngle = -math.pi / 2;
    for (final s in activeSlices) {
      final fraction = total > 0 ? (s.count / total) : s.fraction;
      if (fraction <= 0) continue;
      final sweep = fraction * math.pi * 2;
      final paint = Paint()
        ..color = s.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        startAngle,
        sweep,
        false,
        paint,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _MultiSegmentDonutPainter oldDelegate) =>
      oldDelegate.slices != slices;
}

class AdminHeatmapCard extends StatelessWidget {
  const AdminHeatmapCard({
    super.key,
    required this.values,
    required this.month,
    required this.monthLabel,
    this.onMonthTap,
    this.onMenuTap,
  });

  final List<double> values;
  final DateTime month;
  final String monthLabel;
  final VoidCallback? onMonthTap;
  final VoidCallback? onMenuTap;

  static List<List<int?>> _weeksForMonth(DateTime month) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leading = DateTime(month.year, month.month, 1).weekday - 1;
    final cells = <int?>[...List<int?>.filled(leading, null)];
    for (var d = 1; d <= daysInMonth; d++) {
      cells.add(d);
    }
    while (cells.length % 7 != 0) {
      cells.add(null);
    }
    final weeks = <List<int?>>[];
    for (var i = 0; i < cells.length; i += 7) {
      weeks.add(cells.sublist(i, i + 7));
    }
    return weeks;
  }

  static double _rateForDay(List<double> values, int? day) {
    if (day == null || day < 1 || day > values.length) return 0;
    return values[day - 1];
  }

  @override
  Widget build(BuildContext context) {
    final weeks = _weeksForMonth(month);

    return DashboardCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(9),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.calendar_month_outlined,
                  size: 18,
                  color: Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Attendance Heat Map',
                      style: portalText(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: PortalColors.heading,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '$monthLabel weekly patterns',
                      style: portalText(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: PortalColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: onMenuTap ?? onMonthTap,
                borderRadius: BorderRadius.circular(16),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.more_vert_rounded,
                    size: 20,
                    color: PortalColors.muted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              SizedBox(
                width: 26,
                child: Text(
                  'Wk',
                  style: portalText(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.muted,
                  ),
                ),
              ),
              for (final day in const ['M', 'T', 'W', 'T', 'F', 'S', 'S'])
                Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: portalText(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: PortalColors.muted,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          for (var w = 0; w < weeks.length; w++) ...[
            if (w > 0) const SizedBox(height: 5),
            Row(
              children: [
                SizedBox(
                  width: 26,
                  child: Text(
                    'W${w + 1}',
                    style: portalText(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: PortalColors.muted,
                    ),
                  ),
                ),
                for (var d = 0; d < 7; d++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: _HeatmapCell(
                        day: weeks[w][d],
                        rate: _rateForDay(values, weeks[w][d]),
                      ),
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'High Attendance',
                style: portalText(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: PortalColors.muted,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final c in const [
                    Color(0xFF4ADE80),
                    Color(0xFF2DD4BF),
                    Color(0xFFFBBF24),
                    Color(0xFFFED7AA),
                    Color(0xFFDBEAFE),
                  ]) ...[
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 4),
                  ],
                ],
              ),
              Text(
                'Low',
                style: portalText(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: PortalColors.muted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeatmapCell extends StatelessWidget {
  const _HeatmapCell({required this.day, required this.rate});

  final int? day;
  final double rate;

  static Color _colorForRate(double rate) {
    if (rate >= 0.70) return const Color(0xFF4ADE80);
    if (rate >= 0.55) return const Color(0xFF2DD4BF);
    if (rate >= 0.40) return const Color(0xFFFBBF24);
    if (rate > 0) return const Color(0xFFFED7AA);
    return const Color(0xFFDBEAFE);
  }

  @override
  Widget build(BuildContext context) {
    if (day == null) {
      return Container(
        height: 28,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(6),
        ),
      );
    }

    return Container(
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _colorForRate(rate),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$day',
        style: portalText(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1E293B),
        ),
      ),
    );
  }
}

class AdminLiveWorkforceCard extends StatelessWidget {
  const AdminLiveWorkforceCard({
    super.key,
    required this.totalStaff,
    required this.presentNow,
    required this.lateNow,
    required this.onLeaveNow,
    required this.absentNow,
    this.onViewAll,
  });

  final int totalStaff;
  final int presentNow;
  final int lateNow;
  final int onLeaveNow;
  final int absentNow;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final rows = [
      (Icons.groups_rounded, 'Present Now', presentNow, const Color(0xFF059669)),
      (Icons.access_time_rounded, 'Late Arrivals', lateNow, const Color(0xFFD97706)),
      (Icons.work_outline_rounded, 'On Leave', onLeaveNow, const Color(0xFF2563EB)),
      (Icons.person_off_outlined, 'Absent Today', absentNow, const Color(0xFFEF4444)),
    ];

    final outerFrac = totalStaff > 0 ? (presentNow / totalStaff) : 0.0;
    final innerFrac = totalStaff > 0 ? (lateNow / totalStaff) : 0.0;

    return DashboardCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(9),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.badge_outlined,
                  size: 18,
                  color: Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Live Workforce',
                  style: portalText(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: PortalColors.heading,
                  ),
                ),
              ),
              InkWell(
                onTap: onViewAll,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    'View All',
                    style: portalText(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    for (var i = 0; i < rows.length; i++) ...[
                      if (i > 0) const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: rows[i].$4.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Icon(rows[i].$1, size: 16, color: rows[i].$4),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  rows[i].$2,
                                  style: portalText(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: PortalColors.muted,
                                  ),
                                ),
                                Text(
                                  '${rows[i].$3}',
                                  style: portalText(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: PortalColors.heading,
                                    height: 1.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(
                width: 114,
                height: 114,
                child: CustomPaint(
                  painter: _LiveWorkforceDualRingPainter(
                    outerFraction: outerFrac,
                    innerFraction: innerFrac,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$totalStaff',
                          style: portalText(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: PortalColors.heading,
                            height: 1.1,
                          ),
                        ),
                        Text(
                          'TOTAL STAFF',
                          style: portalText(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                            color: PortalColors.muted,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LiveWorkforceDualRingPainter extends CustomPainter {
  const _LiveWorkforceDualRingPainter({
    required this.outerFraction,
    required this.innerFraction,
  });

  final double outerFraction;
  final double innerFraction;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final outerR = size.width / 2 - 8;
    final innerR = outerR - 11;
    const outerW = 7.5;
    const innerW = 7.0;

    final outerTrack = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = outerW;
    canvas.drawCircle(c, outerR, outerTrack);

    final innerTrack = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = innerW;
    canvas.drawCircle(c, innerR, innerTrack);

    final greenSweep = (outerFraction.clamp(0.0, 1.0)) * math.pi * 2;
    if (greenSweep > 0) {
      final greenPaint = Paint()
        ..color = const Color(0xFF00B67A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = outerW
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: outerR),
        -math.pi / 2,
        greenSweep,
        false,
        greenPaint,
      );
    }

    final orangeSweep = (innerFraction.clamp(0.0, 1.0)) * math.pi * 2;
    if (orangeSweep > 0) {
      final orangePaint = Paint()
        ..color = const Color(0xFFF59E0B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = innerW
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: innerR),
        -math.pi / 2,
        -orangeSweep,
        false,
        orangePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LiveWorkforceDualRingPainter oldDelegate) =>
      oldDelegate.outerFraction != outerFraction ||
      oldDelegate.innerFraction != innerFraction;
}

class AdminExceptionsCard extends StatelessWidget {
  const AdminExceptionsCard({
    super.key,
    required this.items,
    this.onViewAll,
  });

  final List<AdminExceptionItem> items;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(9),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.warning_amber_rounded,
                  size: 18,
                  color: Color(0xFFDC2626),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Attendance Exceptions',
                  style: portalText(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: PortalColors.heading,
                  ),
                ),
              ),
              InkWell(
                onTap: onViewAll,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    'View All',
                    style: portalText(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: items[i].color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${items[i].count}',
                      style: portalText(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: items[i].color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      items[i].label,
                      style: portalText(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: PortalColors.heading,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: PortalColors.muted,
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

class AdminPerformersAndStreaksCard extends StatefulWidget {
  const AdminPerformersAndStreaksCard({
    super.key,
    required this.topPerformers,
    required this.streaks,
  });

  final List<AdminPerformerItem> topPerformers;
  final List<AdminStreakItem> streaks;

  @override
  State<AdminPerformersAndStreaksCard> createState() =>
      _AdminPerformersAndStreaksCardState();
}

class _AdminPerformersAndStreaksCardState
    extends State<AdminPerformersAndStreaksCard> {
  bool _isPerformers = true;

  static const _badgeColors = [
    Color(0xFFF59E0B), // 1: orange
    Color(0xFF2563EB), // 2: blue
    Color(0xFFEA580C), // 3: amber
    Color(0xFF7C3AED), // 4: purple
    Color(0xFF0D9488), // 5: teal
  ];

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () => setState(() => _isPerformers = true),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _isPerformers
                              ? const Color(0xFFEFF6FF)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _isPerformers
                                ? const Color(0xFFBFDBFE)
                                : Colors.transparent,
                          ),
                        ),
                        child: Text(
                          '🏆 Top Performers',
                          style: portalText(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _isPerformers
                                ? const Color(0xFF2563EB)
                                : PortalColors.muted,
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => setState(() => _isPerformers = false),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: !_isPerformers
                              ? const Color(0xFFFFF7ED)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: !_isPerformers
                                ? const Color(0xFFFED7AA)
                                : Colors.transparent,
                          ),
                        ),
                        child: Text(
                          'Streaks 🔥',
                          style: portalText(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: !_isPerformers
                                ? const Color(0xFFEA580C)
                                : PortalColors.muted,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 14),
          if (_isPerformers)
            for (var i = 0; i < widget.topPerformers.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _badgeColors[i % _badgeColors.length],
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${i + 1}',
                      style: portalText(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.topPerformers[i].name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: portalText(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: PortalColors.heading,
                          ),
                        ),
                        Text(
                          widget.topPerformers[i].subtitle,
                          style: portalText(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            color: PortalColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 70,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: widget.topPerformers[i].percent / 100,
                            minHeight: 5,
                            backgroundColor: const Color(0xFFF1F5F9),
                            color: const Color(0xFF059669),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.topPerformers[i].percent.toStringAsFixed(2)}%',
                        style: portalText(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: PortalColors.heading,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ]
          else
            for (var i = 0; i < widget.streaks.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF97316),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${i + 1}',
                      style: portalText(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.streaks[i].name,
                      style: portalText(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: PortalColors.heading,
                      ),
                    ),
                  ),
                  Text(
                    '🔥 ${widget.streaks[i].days}d',
                    style: portalText(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFEA580C),
                    ),
                  ),
                ],
              ),
            ],
        ],
      ),
    );
  }
}

class AdminDeptPerformanceCard extends StatelessWidget {
  const AdminDeptPerformanceCard({
    super.key,
    required this.items,
    this.onViewAll,
  });

  final List<AdminDeptItem> items;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final ranked = [...items]..sort((a, b) => b.percent.compareTo(a.percent));

    return DashboardCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(9),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.apartment_rounded,
                  size: 18,
                  color: Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Dept Performance',
                  style: portalText(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: PortalColors.heading,
                  ),
                ),
              ),
              InkWell(
                onTap: onViewAll,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    'View All',
                    style: portalText(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (ranked.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Text(
                'No department data',
                style: portalText(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: PortalColors.muted,
                ),
              ),
            )
          else ...[
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final gap = 6.0;
                final w = (constraints.maxWidth - gap) / 2;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (var i = 0; i < ranked.length; i++)
                      SizedBox(
                        width: w,
                        child: _DeptScoreTile(
                          item: ranked[i],
                          rank: i + 1,
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _DeptScoreTile extends StatelessWidget {
  const _DeptScoreTile({
    required this.item,
    required this.rank,
  });

  final AdminDeptItem item;
  final int rank;

  @override
  Widget build(BuildContext context) {
    final frac = (item.percent / 100).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
      decoration: BoxDecoration(
        color: item.color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: item.color.withValues(alpha: 0.16)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '#$rank',
                  style: portalText(
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    color: item.color,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                rank == 1 ? Icons.emoji_events_rounded : Icons.circle,
                size: rank == 1 ? 11 : 4,
                color: rank == 1
                    ? const Color(0xFFF0A72E)
                    : item.color.withValues(alpha: 0.45),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 40,
            height: 40,
            child: CustomPaint(
              painter: _DeptSoftRingPainter(
                fraction: frac,
                color: item.color,
              ),
              child: Center(
                child: Text(
                  '${item.percent.toStringAsFixed(0)}%',
                  style: portalText(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: PortalColors.heading,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: portalText(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: PortalColors.heading,
            ),
          ),
          Text(
            'attendance',
            style: portalText(
              fontSize: 8,
              fontWeight: FontWeight.w500,
              color: PortalColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeptSoftRingPainter extends CustomPainter {
  const _DeptSoftRingPainter({
    required this.fraction,
    required this.color,
  });

  final double fraction;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 3;
    const stroke = 4.0;
    final bg = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    final fg = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        colors: [color.withValues(alpha: 0.55), color],
        stops: const [0.0, 1.0],
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(Rect.fromCircle(center: c, radius: r))
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(c, r, bg);
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -math.pi / 2,
      2 * math.pi * fraction,
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(covariant _DeptSoftRingPainter oldDelegate) =>
      oldDelegate.fraction != fraction || oldDelegate.color != color;
}

class AdminTrendCard extends StatefulWidget {
  const AdminTrendCard({
    super.key,
    required this.points,
    required this.year,
  });

  final List<AdminTrendPoint> points;
  final int year;

  @override
  State<AdminTrendCard> createState() => _AdminTrendCardState();
}

class _AdminTrendCardState extends State<AdminTrendCard> {
  bool _isThisYear = true;
  bool _loading = false;
  int _selectedIndex = 0;
  List<AdminTrendPoint>? _lastYearPoints;

  List<AdminTrendPoint> get _activePoints =>
      _isThisYear ? widget.points : (_lastYearPoints ?? const []);

  @override
  void initState() {
    super.initState();
    _selectedIndex = _defaultIndex(widget.points);
  }

  int _defaultIndex(List<AdminTrendPoint> points) {
    if (points.isEmpty) return 0;
    final nowMonth = DateTime.now().month;
    if (_isThisYear &&
        widget.year == DateTime.now().year &&
        nowMonth - 1 < points.length) {
      return nowMonth - 1;
    }
    var best = 0;
    for (var i = 1; i < points.length; i++) {
      if (points[i].attendance > points[best].attendance) best = i;
    }
    return best;
  }

  @override
  void didUpdateWidget(covariant AdminTrendCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.year != widget.year || oldWidget.points != widget.points) {
      if (oldWidget.year != widget.year) {
        _isThisYear = true;
        _lastYearPoints = null;
        _loading = false;
      }
      _selectedIndex = _defaultIndex(_activePoints);
    }
  }

  Future<void> _onSelectYear({required bool thisYear}) async {
    if (thisYear) {
      setState(() {
        _isThisYear = true;
        _selectedIndex = _defaultIndex(widget.points);
      });
      return;
    }
    if (_lastYearPoints != null) {
      setState(() {
        _isThisYear = false;
        _selectedIndex = _defaultIndex(_lastYearPoints!);
      });
      return;
    }

    setState(() {
      _loading = true;
      _isThisYear = false;
    });

    try {
      final ui = await AdminDashboardRepositoryImpl().getSummary(
        month: 12,
        year: widget.year - 1,
      );
      if (!mounted) return;
      setState(() {
        _lastYearPoints = ui.trend;
        _loading = false;
        _selectedIndex = _defaultIndex(ui.trend);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _isThisYear = true;
        _selectedIndex = _defaultIndex(widget.points);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load last year trend.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _showYearMenu() async {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final offset = box.localToGlobal(Offset.zero);
    final selected = await showMenu<bool>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx + box.size.width - 140,
        offset.dy + 48,
        16,
        0,
      ),
      items: const [
        PopupMenuItem<bool>(value: true, child: Text('This Year')),
        PopupMenuItem<bool>(value: false, child: Text('Last Year')),
      ],
    );
    if (selected == null || !mounted) return;
    await _onSelectYear(thisYear: selected);
  }

  @override
  Widget build(BuildContext context) {
    final points = _activePoints;
    final index =
        points.isEmpty ? 0 : _selectedIndex.clamp(0, points.length - 1);
    final selected = points.isEmpty ? null : points[index];

    return DashboardCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(9),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.show_chart_rounded,
                  size: 18,
                  color: Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Monthly Trend',
                  style: portalText(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: PortalColors.heading,
                  ),
                ),
              ),
              InkWell(
                onTap: _loading ? null : _showYearMenu,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: PortalColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isThisYear ? 'This Year' : 'Last Year',
                        style: portalText(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: PortalColors.secondaryText,
                        ),
                      ),
                      const SizedBox(width: 2),
                      if (_loading)
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 1.6),
                        )
                      else
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 14,
                          color: PortalColors.muted,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (points.isEmpty || selected == null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 36),
              child: Text(
                'No trend data',
                style: portalText(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: PortalColors.muted,
                ),
              ),
            )
          else ...[
            const SizedBox(height: 12),
            _TrendHeroChart(
              points: points,
              selectedIndex: index,
              onSelect: (i) => setState(() => _selectedIndex = i),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                for (var i = 0; i < points.length; i++) ...[
                  if (i > 0) const SizedBox(width: 3),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _selectedIndex = i),
                      borderRadius: BorderRadius.circular(999),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 2,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: i == index
                              ? const Color(0xFF2563EB)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            points[i].label,
                            maxLines: 1,
                            softWrap: false,
                            style: portalText(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: i == index
                                  ? Colors.white
                                  : PortalColors.muted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            _TrendSelectedDetail(point: selected),
          ],
        ],
      ),
    );
  }
}

class _TrendHeroChart extends StatelessWidget {
  const _TrendHeroChart({
    required this.points,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<AdminTrendPoint> points;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 148,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _HeroTrendPainter(
                values: points.map((p) => p.attendance).toList(),
                selectedIndex: selectedIndex,
              ),
            ),
          ),
          Positioned.fill(
            child: Row(
              children: [
                for (var i = 0; i < points.length; i++)
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onSelect(i),
                      child: const SizedBox.expand(),
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            left: 12,
            top: 10,
            child: Text(
              'ATTENDANCE',
              style: portalText(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: PortalColors.muted,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Positioned(
            right: 12,
            top: 8,
            child: Text(
              '${points[selectedIndex].attendance.toStringAsFixed(0)}%',
              style: portalText(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroTrendPainter extends CustomPainter {
  _HeroTrendPainter({
    required this.values,
    required this.selectedIndex,
  });

  final List<double> values;
  final int selectedIndex;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    const padL = 10.0;
    const padR = 10.0;
    const padT = 34.0;
    const padB = 16.0;
    final w = size.width - padL - padR;
    final h = size.height - padT - padB;

    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1;
    for (var i = 0; i <= 3; i++) {
      final y = padT + h * i / 3;
      canvas.drawLine(Offset(padL, y), Offset(padL + w, y), gridPaint);
    }

    Offset at(int i) {
      final x = values.length == 1
          ? padL + w / 2
          : padL + w * i / (values.length - 1);
      final y = padT + h * (1 - (values[i].clamp(0, 100) / 100));
      return Offset(x, y);
    }

    final pts = [for (var i = 0; i < values.length; i++) at(i)];
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 0; i < pts.length - 1; i++) {
      final p0 = pts[i];
      final p1 = pts[i + 1];
      final cx = (p0.dx + p1.dx) / 2;
      path.cubicTo(cx, p0.dy, cx, p1.dy, p1.dx, p1.dy);
    }

    final fill = Path.from(path)
      ..lineTo(pts.last.dx, padT + h)
      ..lineTo(pts.first.dx, padT + h)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF10B981).withValues(alpha: 0.22),
            const Color(0xFF10B981).withValues(alpha: 0.02),
          ],
        ).createShader(Rect.fromLTWH(padL, padT, w, h)),
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF059669)
        ..strokeWidth = 2.4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    final sel = selectedIndex.clamp(0, pts.length - 1);
    final p = pts[sel];
    canvas.drawLine(
      Offset(p.dx, padT),
      Offset(p.dx, padT + h),
      Paint()
        ..color = const Color(0xFF94A3B8).withValues(alpha: 0.45)
        ..strokeWidth = 1,
    );
    canvas.drawCircle(p, 6.5, Paint()..color = Colors.white);
    canvas.drawCircle(
      p,
      6.5,
      Paint()
        ..color = const Color(0xFF059669)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(p, 3.2, Paint()..color = const Color(0xFF059669));
  }

  @override
  bool shouldRepaint(covariant _HeroTrendPainter oldDelegate) =>
      oldDelegate.values != values ||
      oldDelegate.selectedIndex != selectedIndex;
}

class _TrendSelectedDetail extends StatelessWidget {
  const _TrendSelectedDetail({required this.point});

  final AdminTrendPoint point;

  @override
  Widget build(BuildContext context) {
    final rate = point.attendance.clamp(0, 100).toDouble();
    final leaves = point.leave.round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  point.label,
                  style: portalText(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: PortalColors.heading,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Selected month overview',
                  style: portalText(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: PortalColors.muted,
                  ),
                ),
              ],
            ),
          ),
          _DetailPill(
            label: '${rate.toStringAsFixed(0)}%',
            hint: 'Rate',
            color: const Color(0xFF2563EB),
            bg: const Color(0xFFEFF6FF),
          ),
          const SizedBox(width: 8),
          _DetailPill(
            label: '$leaves',
            hint: 'Leaves',
            color: const Color(0xFFDC2626),
            bg: const Color(0xFFFEF2F2),
          ),
        ],
      ),
    );
  }
}

class _DetailPill extends StatelessWidget {
  const _DetailPill({
    required this.label,
    required this.hint,
    required this.color,
    required this.bg,
  });

  final String label;
  final String hint;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: portalText(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            hint,
            style: portalText(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class AdminHolidaysCard extends StatelessWidget {
  const AdminHolidaysCard({
    super.key,
    required this.month,
    required this.monthLabel,
    required this.holidayDots,
    this.onViewCalendar,
  });

  final DateTime month;
  final String monthLabel;
  final List<AdminHolidayDot> holidayDots;
  final VoidCallback? onViewCalendar;

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leading = DateTime(month.year, month.month, 1).weekday - 1;
    final holidayDays = {for (final h in holidayDots) h.day};
    final cellCount = ((leading + daysInMonth + 6) ~/ 7) * 7;

    return DashboardCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(9),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.event_note_rounded,
                  size: 18,
                  color: Color(0xFFEA580C),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Holidays & Events',
                      style: portalText(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: PortalColors.heading,
                      ),
                    ),
                    Text(
                      monthLabel,
                      style: portalText(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: PortalColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: onViewCalendar,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    'View Calendar',
                    style: portalText(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (final d in const ['M', 'T', 'W', 'T', 'F', 'S', 'S'])
                Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: portalText(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: PortalColors.muted,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cellCount,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 4,
              childAspectRatio: 1.25,
            ),
            itemBuilder: (context, index) {
              final dayNum = index - leading + 1;
              if (dayNum < 1 || dayNum > daysInMonth) {
                return const SizedBox.shrink();
              }
              final isHoliday = holidayDays.contains(dayNum);
              if (isHoliday) {
                return Center(
                  child: Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFED7AA),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$dayNum',
                      style: portalText(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFC2410C),
                      ),
                    ),
                  ),
                );
              }
              return Center(
                child: Text(
                  '$dayNum',
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: PortalColors.heading,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.push_pin_outlined,
                      size: 14,
                      color: PortalColors.muted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      holidayDots.isEmpty
                          ? 'No events/holidays scheduled'
                          : '${holidayDots.length} holiday(s) this month',
                      style: portalText(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: PortalColors.muted,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF97316),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Holiday',
                      style: portalText(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: PortalColors.muted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AdminPendingLeavesCard extends StatelessWidget {
  const AdminPendingLeavesCard({
    super.key,
    required this.items,
    this.onApprove,
    this.onReject,
    this.onViewAll,
  });

  final List<AdminLeaveRequestItem> items;
  final ValueChanged<AdminLeaveRequestItem>? onApprove;
  final ValueChanged<AdminLeaveRequestItem>? onReject;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(9),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.assignment_outlined,
                  size: 18,
                  color: Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      'Pending Requests',
                      style: portalText(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: PortalColors.heading,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFED7AA),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${items.length}',
                        style: portalText(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFC2410C),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: onViewAll,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    'View All',
                    style: portalText(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _RequestCard(
              item: items[i],
              avatarColor: PortalColors.brand,
              onApprove: () => onApprove?.call(items[i]),
              onReject: () => onReject?.call(items[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.item,
    required this.avatarColor,
    required this.onApprove,
    required this.onReject,
  });

  final AdminLeaveRequestItem item;
  final Color avatarColor;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: avatarColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  item.initials,
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: portalText(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: PortalColors.heading,
                      ),
                    ),
                    Text(
                      item.type,
                      style: portalText(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: PortalColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.duration,
                  style: portalText(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.secondaryText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 13,
                color: PortalColors.muted,
              ),
              const SizedBox(width: 6),
              Text(
                item.dates,
                style: portalText(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: PortalColors.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onApprove,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1FAE5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: Color(0xFF059669),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Approve',
                          style: portalText(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF059669),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: onReject,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.close_rounded,
                          size: 14,
                          color: Color(0xFFDC2626),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Reject',
                          style: portalText(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFDC2626),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
