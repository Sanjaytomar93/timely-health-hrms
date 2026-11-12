import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/dashboard/presentation/models/admin_dashboard_ui.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/dashboard_card.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/weekly_bar_chart_card.dart';

/// Stats grid — employee StatCardsRow style; last card full width.
class AdminMetricsGrid extends StatelessWidget {
  const AdminMetricsGrid({super.key, required this.metrics});

  final List<AdminStatMetric> metrics;

  @override
  Widget build(BuildContext context) {
    if (metrics.isEmpty) return const SizedBox.shrink();
    final leading = metrics.length > 1
        ? metrics.sublist(0, metrics.length - 1)
        : const <AdminStatMetric>[];
    final last = metrics.last;

    final rows = <Widget>[];
    for (var i = 0; i < leading.length; i += 2) {
      if (i > 0) rows.add(const SizedBox(height: 10));
      final hasSecond = i + 1 < leading.length;
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _StatCard(data: leading[i])),
              const SizedBox(width: 10),
              Expanded(
                child: hasSecond
                    ? _StatCard(data: leading[i + 1])
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          ...rows,
          if (leading.isNotEmpty) const SizedBox(height: 10),
          _StatCard(data: last, wide: true),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.data, this.wide = false});

  final AdminStatMetric data;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: wide ? double.infinity : null,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PortalColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(data.icon, size: 22, color: data.color),
          ),
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
                          color: data.color,
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

/// Live summary banner — compact but premium.
class AdminLiveBanner extends StatelessWidget {
  const AdminLiveBanner({
    super.key,
    required this.present,
    required this.absent,
    required this.lateCount,
    required this.total,
    required this.rateLabel,
  });

  final int present;
  final int absent;
  final int lateCount;
  final int total;
  final String rateLabel;

  double get _rate {
    final raw = rateLabel.replaceAll('%', '').trim();
    return double.tryParse(raw) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            begin: Alignment(-0.55, -1),
            end: Alignment(1, 1),
            colors: [
              Color(0xFF1E1842),
              Color(0xFF2F2870),
              Color(0xFF4B4285),
            ],
            stops: [0.0, 0.55, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: PortalColors.brand.withValues(alpha: 0.22),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              right: -28,
              top: -36,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.14),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.16),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const _LivePulse(),
                            const SizedBox(width: 5),
                            Text(
                              'LIVE',
                              style: portalText(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.7,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '$present of $total present · $rateLabel',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: portalText(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        rateLabel,
                        style: portalText(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF5DFFC4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: (_rate / 100).clamp(0.0, 1.0),
                      minHeight: 5,
                      backgroundColor: Colors.white.withValues(alpha: 0.14),
                      valueColor:
                          const AlwaysStoppedAnimation(Color(0xFF5DFFC4)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _BannerGlassStat(
                          icon: Icons.check_circle_rounded,
                          label: 'Present',
                          value: '$present',
                          accent: const Color(0xFF5DFFC4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _BannerGlassStat(
                          icon: Icons.cancel_rounded,
                          label: 'Absent',
                          value: '$absent',
                          accent: const Color(0xFFFF8A80),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _BannerGlassStat(
                          icon: Icons.schedule_rounded,
                          label: 'Late',
                          value: '$lateCount',
                          accent: const Color(0xFFFFD180),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LivePulse extends StatefulWidget {
  const _LivePulse();

  @override
  State<_LivePulse> createState() => _LivePulseState();
}

class _LivePulseState extends State<_LivePulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) {
        final t = Curves.easeInOut.transform(_c.value);
        return Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: const Color(0xFF5DFFC4),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5DFFC4).withValues(alpha: 0.45 * t),
                blurRadius: 3 + 4 * t,
                spreadRadius: 0.5 + 1.5 * t,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BannerGlassStat extends StatelessWidget {
  const _BannerGlassStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: accent),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: portalText(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Quick actions — Locations / Hire (like employee quick actions).
class AdminQuickActions extends StatelessWidget {
  const AdminQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: _QuickTile(
              icon: Icons.location_on_outlined,
              label: 'Locations',
              color: PortalColors.green,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _QuickTile(
              icon: Icons.person_add_alt_1_rounded,
              label: 'Hire',
              color: PortalColors.brandLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PortalColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: portalText(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: PortalColors.heading,
            ),
          ),
        ],
      ),
    );
  }
}

/// Today's Attendance donut — same layout as AbsentWeekWiseCard.
class AdminTodayAttendanceCard extends StatelessWidget {
  const AdminTodayAttendanceCard({super.key, required this.slices});

  final List<AdminAttendanceSlice> slices;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        children: [
          const DashboardCardHeader(
            icon: Icons.donut_large_rounded,
            color: PortalColors.green,
            title: "Today's Attendance",
            subtitle: 'Status breakdown',
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 148,
            child: Row(
              children: [
                Expanded(
                  flex: 8,
                  child: CustomPaint(
                    painter: _RingPainter(
                      values: slices.map((e) => e.count.toDouble()).toList(),
                      colors: slices.map((e) => e.color).toList(),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${slices.fold<int>(0, (s, e) => s + e.count)}',
                            style: portalText(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: PortalColors.heading,
                            ),
                          ),
                          Text(
                            'Tracked',
                            style: portalText(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: PortalColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  color: PortalColors.border,
                ),
                Expanded(
                  flex: 13,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (final s in slices)
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
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
                              '${s.count}  ${s.percentLabel}',
                              style: portalText(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: PortalColors.heading,
                              ),
                            ),
                          ],
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
}

/// Exact Attendance Heatmap style from design (W1–W5 · Mon–Sun).
class AdminHeatmapCard extends StatelessWidget {
  const AdminHeatmapCard({
    super.key,
    required this.values,
    required this.month,
    required this.monthLabel,
    this.onMonthTap,
  });

  final List<double> values;
  final DateTime month;
  final String monthLabel;
  final VoidCallback? onMonthTap;

  static const _lowBg = Color(0xFFE8F1FB);
  static const _lowFg = Color(0xFF3B6FA0);
  static const _midBg = Color(0xFFFDE9B0);
  static const _midFg = Color(0xFF8A6A1A);
  static const _highBg = Color(0xFFF6C344);
  static const _highFg = Color(0xFF744210);

  static const _legend = [
    Color(0xFF0F766E),
    Color(0xFF5EEAD4),
    Color(0xFFF6C344),
    Color(0xFFFDE9B0),
    Color(0xFFFECACA),
    Color(0xFFE8F1FB),
  ];

  @override
  Widget build(BuildContext context) {
    // Monday-first week rows (matches design: Mon … Sun).
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstWeekday = DateTime(month.year, month.month, 1).weekday; // 1=Mon
    final leading = firstWeekday - 1;
    final totalCells = leading + daysInMonth;
    final weekCount = ((totalCells + 6) ~/ 7).clamp(1, 6);

    return DashboardCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Attendance Heatmap',
                  style: portalText(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: PortalColors.heading,
                  ),
                ),
              ),
              DashboardMonthChip(
                label: monthLabel,
                onTap: onMonthTap,
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: PortalColors.border),
          const SizedBox(height: 12),
          for (var w = 0; w < weekCount; w++) ...[
            if (w > 0) const SizedBox(height: 6),
            Row(
              children: [
                SizedBox(
                  width: 26,
                  child: Text(
                    'W${w + 1}',
                    style: portalText(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: PortalColors.muted,
                    ),
                  ),
                ),
                for (var d = 0; d < 7; d++) ...[
                  if (d > 0) const SizedBox(width: 5),
                  Expanded(
                    child: _heatCell(
                      cellIndex: w * 7 + d,
                      leading: leading,
                      daysInMonth: daysInMonth,
                    ),
                  ),
                ],
              ],
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              const SizedBox(width: 26),
              for (final day in const [
                'Mon',
                'Tue',
                'Wed',
                'Thu',
                'Fri',
                'Sat',
                'Sun',
              ])
                Expanded(
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: portalText(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: PortalColors.muted,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: PortalColors.border),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'High',
                style: portalText(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: PortalColors.muted,
                ),
              ),
              const Spacer(),
              for (final c in _legend) ...[
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                ),
              ],
              const Spacer(),
              Text(
                'Low',
                style: portalText(
                  fontSize: 11,
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

  Widget _heatCell({
    required int cellIndex,
    required int leading,
    required int daysInMonth,
  }) {
    final dayNum = cellIndex - leading + 1;
    final inMonth = dayNum >= 1 && dayNum <= daysInMonth;
    if (!inMonth) {
      return AspectRatio(
        aspectRatio: 1.15,
        child: Container(
          decoration: BoxDecoration(
            color: _lowBg,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
    final t = (dayNum - 1 < values.length ? values[dayNum - 1] : 0.3)
        .clamp(0.0, 1.0);
    final Color bg;
    final Color fg;
    if (t >= 0.7) {
      bg = _highBg;
      fg = _highFg;
    } else if (t >= 0.4) {
      bg = _midBg;
      fg = _midFg;
    } else {
      bg = _lowBg;
      fg = _lowFg;
    }
    return AspectRatio(
      aspectRatio: 1.15,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '$dayNum',
          style: portalText(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: fg,
          ),
        ),
      ),
    );
  }
}

/// Live Workforce — left stats + concentric rings (design match).
class AdminLiveWorkforceCard extends StatelessWidget {
  const AdminLiveWorkforceCard({
    super.key,
    required this.totalStaff,
    required this.presentNow,
    required this.lateNow,
    required this.onLeaveNow,
    required this.absentNow,
  });

  final int totalStaff;
  final int presentNow;
  final int lateNow;
  final int onLeaveNow;
  final int absentNow;

  @override
  Widget build(BuildContext context) {
    final rows = [
      (
        Icons.groups_rounded,
        'Present Now',
        presentNow,
        PortalColors.green,
        PortalColors.greenTint,
      ),
      (
        Icons.schedule_rounded,
        'Late Arrivals',
        lateNow,
        PortalColors.orange,
        PortalColors.orangeTint,
      ),
      (
        Icons.work_outline_rounded,
        'On Leave',
        onLeaveNow,
        const Color(0xFF3B82F6),
        const Color(0xFFDBEAFE),
      ),
      (
        Icons.person_off_outlined,
        'Absent Today',
        absentNow,
        PortalColors.red,
        PortalColors.redTint,
      ),
    ];

    return DashboardCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Live Workforce',
                  style: portalText(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: PortalColors.heading,
                  ),
                ),
              ),
              Text(
                'View All',
                style: portalText(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF3B82F6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: PortalColors.border),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  children: [
                    for (var i = 0; i < rows.length; i++) ...[
                      if (i > 0) const SizedBox(height: 14),
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: rows[i].$5,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              rows[i].$1,
                              size: 18,
                              color: rows[i].$4,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  rows[i].$2,
                                  style: portalText(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                    color: PortalColors.muted,
                                  ),
                                ),
                                Text(
                                  '${rows[i].$3}',
                                  style: portalText(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: PortalColors.heading,
                                    height: 1.15,
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
              const SizedBox(width: 8),
              SizedBox(
                width: 118,
                height: 118,
                child: CustomPaint(
                  painter: _ConcentricRingPainter(
                    outer: totalStaff == 0 ? 0 : presentNow / totalStaff,
                    inner: totalStaff == 0 ? 0 : lateNow / totalStaff,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$totalStaff',
                          style: portalText(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: PortalColors.heading,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 2),
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

class _ConcentricRingPainter extends CustomPainter {
  _ConcentricRingPainter({required this.outer, required this.inner});

  final double outer;
  final double inner;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final track = Paint()
      ..color = const Color(0xFFE8E7F0)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final outerR = size.width / 2 - 7;
    final innerR = size.width / 2 - 20;

    track.strokeWidth = 8;
    canvas.drawCircle(c, outerR, track);
    track.strokeWidth = 7;
    canvas.drawCircle(c, innerR, track);

    canvas.drawArc(
      Rect.fromCircle(center: c, radius: outerR),
      -math.pi / 2,
      (outer.clamp(0.0, 1.0)) * math.pi * 2,
      false,
      Paint()
        ..color = PortalColors.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: innerR),
      -math.pi / 2,
      (inner.clamp(0.0, 1.0)) * math.pi * 2,
      false,
      Paint()
        ..color = PortalColors.orange
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _ConcentricRingPainter old) =>
      old.outer != outer || old.inner != inner;
}

class AdminExceptionsCard extends StatelessWidget {
  const AdminExceptionsCard({super.key, required this.items});

  final List<AdminExceptionItem> items;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Column(
        children: [
          const DashboardCardHeader(
            icon: Icons.warning_amber_rounded,
            color: PortalColors.orange,
            title: 'Attendance Exceptions',
            subtitle: 'Needs attention',
          ),
          const SizedBox(height: 8),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(item.icon, size: 18, color: item.color),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.label,
                      style: portalText(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: PortalColors.heading,
                      ),
                    ),
                  ),
                  Text(
                    '${item.count}',
                    style: portalText(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: item.color,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class AdminTopPerformersCard extends StatelessWidget {
  const AdminTopPerformersCard({super.key, required this.items});

  final List<AdminPerformerItem> items;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Column(
        children: [
          const DashboardCardHeader(
            icon: Icons.emoji_events_outlined,
            color: PortalColors.orange,
            title: 'Top Performers',
            subtitle: 'Attendance %',
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < items.length; i++) ...[
            Row(
              children: [
                _Avatar(items[i].initials),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        items[i].name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: portalText(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: PortalColors.heading,
                        ),
                      ),
                      const SizedBox(height: 5),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: (items[i].percent / 100).clamp(0.0, 1.0),
                          minHeight: 5,
                          backgroundColor: PortalColors.background,
                          color: PortalColors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${items[i].percent.toStringAsFixed(1)}%',
                  style: portalText(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: PortalColors.green,
                  ),
                ),
              ],
            ),
            if (i < items.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class AdminStreaksCard extends StatelessWidget {
  const AdminStreaksCard({super.key, required this.items});

  final List<AdminStreakItem> items;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Column(
        children: [
          const DashboardCardHeader(
            icon: Icons.local_fire_department_outlined,
            color: PortalColors.orange,
            title: 'Attendance Streaks',
            subtitle: 'Consecutive present days',
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < items.length; i++) ...[
            Row(
              children: [
                _Avatar(items[i].initials),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    items[i].name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: portalText(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: PortalColors.heading,
                    ),
                  ),
                ),
                Text(
                  '🔥 ${items[i].days}d',
                  style: portalText(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: PortalColors.orange,
                  ),
                ),
              ],
            ),
            if (i < items.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class AdminDeptPerformanceCard extends StatelessWidget {
  const AdminDeptPerformanceCard({super.key, required this.items});

  final List<AdminDeptItem> items;

  @override
  Widget build(BuildContext context) {
    final max = items.fold<double>(0, (m, e) => math.max(m, e.percent));
    return DashboardCard(
      child: Column(
        children: [
          const DashboardCardHeader(
            icon: Icons.apartment_outlined,
            color: PortalColors.brand,
            title: 'Dept Performance',
            subtitle: 'By department',
          ),
          const SizedBox(height: 12),
          for (final d in items) ...[
            Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    d.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: portalText(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: PortalColors.secondaryText,
                    ),
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: max <= 0 ? 0 : d.percent / max,
                      minHeight: 7,
                      backgroundColor: PortalColors.background,
                      color: d.color,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${d.percent.toStringAsFixed(1)}%',
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: PortalColors.heading,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
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
  });

  final List<AdminLeaveRequestItem> items;
  final ValueChanged<AdminLeaveRequestItem>? onApprove;
  final ValueChanged<AdminLeaveRequestItem>? onReject;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Column(
        children: [
          const DashboardCardHeader(
            icon: Icons.pending_actions_outlined,
            color: PortalColors.brand,
            title: 'Pending Leave Requests',
            subtitle: 'Approve or reject',
          ),
          const SizedBox(height: 4),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'No pending requests',
                style: portalText(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: PortalColors.muted,
                ),
              ),
            )
          else
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const Divider(height: 20, color: PortalColors.border),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Avatar(items[i].initials),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          items[i].name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: portalText(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: PortalColors.heading,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${items[i].type} · ${items[i].dates}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: portalText(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: PortalColors.muted,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _LeaveTextAction(
                              label: 'Reject',
                              color: PortalColors.red,
                              onTap: () => onReject?.call(items[i]),
                            ),
                            const SizedBox(width: 16),
                            _LeaveTextAction(
                              label: 'Approve',
                              color: PortalColors.green,
                              onTap: () => onApprove?.call(items[i]),
                            ),
                          ],
                        ),
                      ],
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

class _LeaveTextAction extends StatelessWidget {
  const _LeaveTextAction({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Text(
          label,
          style: portalText(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ),
    );
  }
}

/// Holidays & Events — calendar + legend (design match).
class AdminHolidaysCard extends StatelessWidget {
  const AdminHolidaysCard({
    super.key,
    required this.month,
    required this.monthLabel,
  });

  final DateTime month;
  final String monthLabel;

  @override
  Widget build(BuildContext context) {
    final days = DateTime(month.year, month.month + 1, 0).day;
    // Monday-first grid
    final firstWeekday = DateTime(month.year, month.month, 1).weekday;
    final leading = firstWeekday - 1;

    return DashboardCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Holidays & Events',
                      style: portalText(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: PortalColors.heading,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      monthLabel,
                      style: portalText(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: PortalColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'View Calendar',
                style: portalText(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF3B82F6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (final d in const [
                'MON',
                'TUE',
                'WED',
                'THU',
                'FRI',
                'SAT',
                'SUN',
              ])
                Expanded(
                  child: Text(
                    d,
                    textAlign: TextAlign.center,
                    style: portalText(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: PortalColors.muted,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: leading + days,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 4,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              if (index < leading) return const SizedBox.shrink();
              final day = index - leading + 1;
              final date = DateTime(month.year, month.month, day);
              final isSunday = date.weekday == DateTime.sunday;
              if (isSunday) {
                return Center(
                  child: Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: PortalColors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$day',
                      style: portalText(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              }
              return Center(
                child: Text(
                  '$day',
                  style: portalText(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: PortalColors.heading,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: PortalColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.flag_outlined,
                  size: 22,
                  color: PortalColors.muted.withValues(alpha: 0.7),
                ),
                const SizedBox(height: 6),
                Text(
                  'No events.',
                  style: portalText(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: PortalColors.muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 14,
            runSpacing: 6,
            children: [
              _DotLegend(label: 'FESTIVAL', color: Color(0xFFF6C344)),
              _DotLegend(label: 'NATIONAL', color: PortalColors.green),
              _DotLegend(label: 'COMPANY', color: Color(0xFF7E57C2)),
              _DotLegend(label: 'RESTRICTED', color: PortalColors.red),
            ],
          ),
        ],
      ),
    );
  }
}

class _DotLegend extends StatelessWidget {
  const _DotLegend({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: portalText(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: PortalColors.muted,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

/// Monthly Attendance Trend — attendance rate + leaves taken.
class AdminTrendCard extends StatelessWidget {
  const AdminTrendCard({super.key, required this.points});

  final List<AdminTrendPoint> points;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Monthly Attendance Trend',
                  style: portalText(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: PortalColors.heading,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: PortalColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: PortalColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'This Year',
                      style: portalText(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: PortalColors.secondaryText,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: PortalColors.muted,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 160,
            width: double.infinity,
            child: CustomPaint(painter: _TrendPainter(points: points)),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 14,
                height: 3,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'ATTENDANCE RATE',
                style: portalText(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: PortalColors.muted,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 14,
                height: 3,
                decoration: BoxDecoration(
                  color: const Color(0xFFE91E8C),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'LEAVES TAKEN',
                style: portalText(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: PortalColors.muted,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  _TrendPainter({required this.points});

  final List<AdminTrendPoint> points;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    const labelH = 16.0;
    final chartH = size.height - labelH;
    final dx = size.width / math.max(1, points.length - 1);

    Offset pt(int i, double pct) =>
        Offset(i * dx, chartH - (pct / 100) * (chartH - 8) - 4);

    final grid = Paint()
      ..color = PortalColors.border
      ..strokeWidth = 1;
    for (var i = 0; i < 5; i++) {
      final y = chartH * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    void drawLine(Color color, double Function(AdminTrendPoint) pick) {
      final path = Path();
      for (var i = 0; i < points.length; i++) {
        final p = pt(i, pick(points[i]));
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
      for (var i = 0; i < points.length; i++) {
        canvas.drawCircle(pt(i, pick(points[i])), 3.2, Paint()..color = color);
      }
    }

    // attendance = rate %, leave scaled as % of max leave* for visual
    final maxLeave = points.fold<double>(
      1,
      (m, p) => math.max(m, p.leave),
    );
    drawLine(const Color(0xFF3B82F6), (p) => p.attendance);
    drawLine(
      const Color(0xFFE91E8C),
      (p) => (p.leave / maxLeave) * 100,
    );

    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (var i = 0; i < points.length; i++) {
      tp.text = TextSpan(
        text: points[i].label,
        style: portalText(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: PortalColors.muted,
        ),
      );
      tp.layout();
      tp.paint(canvas, Offset(i * dx - tp.width / 2, chartH + 2));
    }
  }

  @override
  bool shouldRepaint(covariant _TrendPainter old) => old.points != points;
}

class _Avatar extends StatelessWidget {
  const _Avatar(this.initials);

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: PortalColors.avatarGradient),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        initials,
        style: portalText(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.values, required this.colors});

  final List<double> values;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 12.0;
    final total = values.fold<double>(0, (s, v) => s + v);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - stroke / 2;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = PortalColors.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );
    if (total <= 0) return;
    var start = -math.pi / 2;
    for (var i = 0; i < values.length; i++) {
      final sweep = (values[i] / total) * math.pi * 2;
      if (sweep <= 0) continue;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        false,
        Paint()
          ..color = colors[i % colors.length]
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.values != values || old.colors != colors;
}
