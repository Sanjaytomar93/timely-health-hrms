import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/op/dashboard/presentation/models/op_dashboard_ui.dart';
import 'package:timelay_health/features/op/dashboard/presentation/theme/op_colors.dart';
import 'package:timelay_health/features/op/dashboard/presentation/widgets/op_top_bar.dart';

class OpHeroHeader extends StatelessWidget {
  const OpHeroHeader({
    super.key,
    required this.greeting,
    required this.fyLabel,
    required this.onFyTap,
    this.onMenuTap,
  });

  final String greeting;
  final String fyLabel;
  final VoidCallback onFyTap;
  final VoidCallback? onMenuTap;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: const _WaveClipper(),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: OpColors.heroGradient,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OpTopBar(
              title: 'OP Dashboard',
              light: true,
              onMenuTap: onMenuTap,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 6, 18, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: portalText(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.92),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Clinic overview & performance',
                    style: portalText(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: onFyTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            fyLabel,
                            style: portalText(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
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

class _WaveClipper extends CustomClipper<Path> {
  const _WaveClipper();

  @override
  Path getClip(Size size) {
    final path = Path()..lineTo(0, size.height - 26);
    path.quadraticBezierTo(
      size.width * 0.28,
      size.height + 4,
      size.width * 0.55,
      size.height - 16,
    );
    path.quadraticBezierTo(
      size.width * 0.8,
      size.height - 34,
      size.width,
      size.height - 10,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class OpSearchBar extends StatelessWidget {
  const OpSearchBar({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      child: Container(
        height: 48,
        decoration: OpColors.card(radius: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: OpColors.blueTint,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.search_rounded,
                size: 18,
                color: OpColors.blue,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: portalText(fontSize: 13, color: OpColors.muted),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OpPeriodFilters extends StatelessWidget {
  const OpPeriodFilters({
    super.key,
    required this.filters,
    required this.selected,
    required this.onSelected,
    required this.onRegister,
  });

  final List<String> filters;
  final String selected;
  final ValueChanged<String> onSelected;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      child: Column(
        children: [
          SizedBox(
            height: 34,
            child: Row(
              children: [
                for (var i = 0; i < filters.length; i++) ...[
                  if (i > 0) const SizedBox(width: 4),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onSelected(filters[i]),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: filters[i] == selected
                              ? OpColors.primary
                              : OpColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: filters[i] == selected
                                ? OpColors.primary
                                : OpColors.border,
                          ),
                        ),
                        child: Text(
                          filters[i],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: portalText(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: filters[i] == selected
                                ? Colors.white
                                : OpColors.secondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: onRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: OpColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(
                'Register New OP',
                style: portalText(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Design: 4 square quick-action cards in one row.
class OpQuickActionsRow extends StatelessWidget {
  const OpQuickActionsRow({
    super.key,
    required this.actions,
    this.onTap,
  });

  final List<OpQuickActionUi> actions;
  final ValueChanged<OpQuickActionUi>? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      child: Row(
        children: [
          for (var i = 0; i < actions.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: onTap == null ? null : () => onTap!(actions[i]),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: OpColors.card(radius: 18),
                  child: Column(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: actions[i].tint,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          actions[i].icon,
                          size: 22,
                          color: actions[i].accent,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        actions[i].label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: portalText(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: OpColors.heading,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Stats grid — same style as HRMS home StatCardsRow (2 per row).
class OpMetricsGrid extends StatelessWidget {
  const OpMetricsGrid({super.key, required this.metrics});

  final List<OpMetricUi> metrics;

  @override
  Widget build(BuildContext context) {
    if (metrics.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      child: Column(
        children: [
          for (var i = 0; i < metrics.length; i += 2) ...[
            if (i > 0) const SizedBox(height: 10),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _StatCard(data: metrics[i])),
                  const SizedBox(width: 10),
                  Expanded(
                    child: i + 1 < metrics.length
                        ? _StatCard(data: metrics[i + 1])
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

class _StatCard extends StatelessWidget {
  const _StatCard({required this.data});

  final OpMetricUi data;

  String get _subtitle {
    if (data.activeLabel != null) {
      final inactive = data.inactiveLabel ?? '';
      return inactive.isEmpty
          ? data.activeLabel!
          : '${data.activeLabel} · $inactive';
    }
    if (data.breakdown.isNotEmpty) {
      return data.breakdown.map((b) => '${b.label} ${b.value}').join(' · ');
    }
    return data.subtitle;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: OpColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: OpColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: data.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(data.icon, size: 22, color: data.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title.toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    color: OpColors.muted,
                    letterSpacing: 0.2,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  data.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: data.accent,
                    height: 1.15,
                  ),
                ),
                if (_subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    _subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: portalText(
                      fontSize: 9,
                      fontWeight: FontWeight.w400,
                      color: OpColors.muted,
                      height: 1.2,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum OpChartType { composed, area, bar, line }

class OpRevenueTrendCard extends StatelessWidget {
  const OpRevenueTrendCard({
    super.key,
    required this.trend,
    this.title = 'Bookings & Revenue Trend',
    this.fyLabel = 'FY 2025-26',
    this.subtitle = 'Monthly booking volume and collected revenue',
    this.onFyTap,
    this.showExpand = false,
  });

  final List<OpMonthRevenueUi> trend;
  final String title;
  final String fyLabel;
  final String subtitle;
  final VoidCallback? onFyTap;
  final bool showExpand;

  @override
  Widget build(BuildContext context) {
    return _OpTrendCardBody(
      trend: trend,
      title: title,
      subtitle: subtitle,
      fyLabel: fyLabel,
      onFyTap: onFyTap,
      chartType: OpChartType.bar,
    );
  }
}

/// Shared card chrome — same style for Bookings trend & FY trend.
class _OpTrendCardBody extends StatelessWidget {
  const _OpTrendCardBody({
    required this.trend,
    required this.title,
    required this.subtitle,
    required this.fyLabel,
    this.onFyTap,
    this.chartType = OpChartType.bar,
    this.chartTypeToggle,
  });

  final List<OpMonthRevenueUi> trend;
  final String title;
  final String subtitle;
  final String fyLabel;
  final VoidCallback? onFyTap;
  final OpChartType chartType;
  final Widget? chartTypeToggle;

  static const clinic = Color(0xFF60A5FA);
  static const lab = Color(0xFFA78BFA);
  static const pharmacy = Color(0xFF34D399);
  static const _axisLabels = ['₹2.6L', '₹1.9L', '₹1.3L', '₹65K', '0'];

  @override
  Widget build(BuildContext context) {
    const chartH = 200.0;
    const labelH = 24.0;
    const totalH = chartH + labelH;
    final barsWidth = math.max(trend.length * 46.0, 320.0);

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEAE8F3)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F2A2456),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.show_chart_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: portalText(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1C1B29),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: portalText(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF8A879E),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onFyTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        fyLabel,
                        style: portalText(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF3B82F6),
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: Color(0xFF3B82F6),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (chartTypeToggle != null) ...[
            const SizedBox(height: 12),
            chartTypeToggle!,
          ],
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(color: clinic, label: 'Clinic'),
              SizedBox(width: 18),
              _LegendDot(color: lab, label: 'Lab'),
              SizedBox(width: 18),
              _LegendDot(color: pharmacy, label: 'Pharmacy'),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: totalH,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 48,
                  height: chartH,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (final label in _axisLabels)
                        Text(
                          label,
                          style: portalText(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF9A97AD),
                            height: 1,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: barsWidth,
                      height: totalH,
                      child: CustomPaint(
                        painter: _TrendChartPainter(
                          items: trend,
                          type: chartType,
                        ),
                      ),
                    ),
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

/// REVENUE BREAKDOWN — Show expands Clinic / Lab / Pharmacy / Total cards.
class OpRevenueBreakdownHeader extends StatefulWidget {
  const OpRevenueBreakdownHeader({
    super.key,
    required this.patientsLabel,
    required this.channels,
    this.onPatientsTap,
  });

  final String patientsLabel;
  final List<OpRevenueChannelUi> channels;
  final VoidCallback? onPatientsTap;

  @override
  State<OpRevenueBreakdownHeader> createState() =>
      _OpRevenueBreakdownHeaderState();
}

class _OpRevenueBreakdownHeaderState extends State<OpRevenueBreakdownHeader> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F6FC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4E0F5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                size: 20,
                color: Color(0xFF6D5CE7),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'REVENUE BREAKDOWN ',
                        style: portalText(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1C1B29),
                          letterSpacing: 0.2,
                        ),
                      ),
                      TextSpan(
                        text: '(based on current filters)',
                        style: portalText(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF7C7A91),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Pill(
                label: widget.patientsLabel,
                onTap: widget.onPatientsTap,
              ),
              const SizedBox(width: 8),
              _Pill(
                label: _expanded ? 'Hide' : 'Show',
                showChevron: true,
                chevronUp: _expanded,
                onTap: () => setState(() => _expanded = !_expanded),
              ),
            ],
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                children: [
                  for (var i = 0; i < widget.channels.length; i++) ...[
                    if (i > 0) const SizedBox(height: 8),
                    _RevenueChannelCard(channel: widget.channels[i]),
                  ],
                ],
              ),
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
            sizeCurve: Curves.easeOut,
          ),
        ],
      ),
    );
  }
}

class _RevenueChannelCard extends StatelessWidget {
  const _RevenueChannelCard({required this.channel});

  final OpRevenueChannelUi channel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
      decoration: BoxDecoration(
        color: channel.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: channel.isTotal
              ? const Color(0xFFD9D4F5)
              : channel.accent.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(channel.icon, size: 16, color: channel.accent),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  channel.title,
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: channel.accent,
                    letterSpacing: 0.25,
                  ),
                ),
              ),
              Text(
                'FootFall: ${channel.footfall}',
                style: portalText(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: channel.accent.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              channel.amount,
              style: portalText(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: channel.accent,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              for (final line in channel.lines)
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${line.label}: ',
                        style: portalText(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6B6880),
                        ),
                      ),
                      TextSpan(
                        text: line.value,
                        style: portalText(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: line.color,
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

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    this.showChevron = false,
    this.chevronUp = false,
    this.onTap,
  });

  final String label;
  final bool showChevron;
  final bool chevronUp;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD9D4F5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: portalText(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF6D5CE7),
                ),
              ),
              if (showChevron) ...[
                const SizedBox(width: 2),
                Icon(
                  chevronUp
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 17,
                  color: const Color(0xFF6D5CE7),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class OpSummaryCard extends StatelessWidget {
  const OpSummaryCard({super.key, required this.rows});

  final List<OpSummaryRowUi> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
      decoration: OpColors.card(radius: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: OpColors.greenTint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  size: 18,
                  color: OpColors.green,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Summary',
                style: portalText(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: OpColors.heading,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final row in rows)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: row.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(_summaryIcon(row.label), size: 18, color: row.color),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      row.label,
                      style: portalText(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: OpColors.secondary,
                      ),
                    ),
                  ),
                  Text(
                    row.value,
                    style: portalText(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: row.color,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  IconData _summaryIcon(String label) {
    final l = label.toLowerCase();
    if (l.contains('patient')) return Icons.people_alt_outlined;
    if (l.contains('collective') || l.contains('collect')) {
      return Icons.payments_outlined;
    }
    if (l.contains('due')) return Icons.warning_amber_rounded;
    if (l.contains('refund') || l.contains('review')) {
      return Icons.replay_rounded;
    }
    return Icons.local_offer_outlined;
  }
}

class OpPaymentStatusCard extends StatelessWidget {
  const OpPaymentStatusCard({super.key, required this.slices});

  final List<OpSliceUi> slices;

  @override
  Widget build(BuildContext context) {
    return _HBarCard(
      title: 'Payment Status',
      titleIcon: Icons.verified_outlined,
      slices: slices,
      iconFor: _paymentStatusIcon,
    );
  }

  static IconData _paymentStatusIcon(String label) {
    final l = label.toLowerCase();
    if (l.contains('paid') && !l.contains('partial')) {
      return Icons.check_circle_rounded;
    }
    if (l.contains('partial')) return Icons.timelapse_rounded;
    if (l.contains('pending') || l.contains('due')) {
      return Icons.schedule_rounded;
    }
    return Icons.payments_outlined;
  }
}

class OpPaymentModeCard extends StatelessWidget {
  const OpPaymentModeCard({super.key, required this.slices});

  final List<OpSliceUi> slices;

  @override
  Widget build(BuildContext context) {
    return _HBarCard(
      title: 'Payment Mode (Paid)',
      titleIcon: Icons.account_balance_wallet_outlined,
      slices: slices,
      iconFor: _paymentModeIcon,
    );
  }

  static IconData _paymentModeIcon(String label) {
    final l = label.toLowerCase();
    if (l.contains('cash')) return Icons.payments_rounded;
    if (l.contains('online') || l.contains('upi')) {
      return Icons.phone_android_rounded;
    }
    if (l.contains('insurance')) return Icons.health_and_safety_outlined;
    if (l.contains('card')) return Icons.credit_card_rounded;
    return Icons.payment_rounded;
  }
}

class _HBarCard extends StatelessWidget {
  const _HBarCard({
    required this.title,
    required this.slices,
    required this.iconFor,
    this.titleIcon,
  });

  final String title;
  final IconData? titleIcon;
  final List<OpSliceUi> slices;
  final IconData Function(String label) iconFor;

  @override
  Widget build(BuildContext context) {
    final total = slices.fold<int>(0, (s, e) => s + e.count);
    final maxCount = slices.fold<int>(1, (m, e) => math.max(m, e.count));

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      padding: const EdgeInsets.all(14),
      decoration: OpColors.card(radius: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (titleIcon != null) ...[
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: OpColors.primaryTint,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(titleIcon, size: 17, color: OpColors.primary),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  title,
                  style: portalText(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: OpColors.heading,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  for (final s in slices)
                    if (total > 0 && s.count > 0)
                      Expanded(
                        flex: math.max(1, s.count),
                        child: ColoredBox(color: s.color),
                      ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          for (final s in slices) ...[
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: s.color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(iconFor(s.label), size: 16, color: s.color),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    s.label,
                    style: portalText(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: OpColors.secondary,
                    ),
                  ),
                ),
                Text(
                  '${s.count}',
                  style: portalText(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: OpColors.heading,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: s.count / maxCount,
                minHeight: 8,
                backgroundColor: s.color.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation(s.color),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class OpGenderCard extends StatelessWidget {
  const OpGenderCard({
    super.key,
    required this.slices,
    required this.total,
  });

  final List<OpSliceUi> slices;
  final int total;

  IconData _genderIcon(String label) {
    final l = label.toLowerCase();
    if (l.contains('male') && !l.contains('female')) {
      return Icons.male_rounded;
    }
    if (l.contains('female')) return Icons.female_rounded;
    return Icons.transgender_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      padding: const EdgeInsets.all(14),
      decoration: OpColors.card(radius: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: OpColors.pinkTint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.groups_rounded,
                  size: 17,
                  color: OpColors.pink,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Gender Demographics',
                style: portalText(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: OpColors.heading,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 130,
                height: 130,
                child: CustomPaint(
                  painter: _DonutPainter(slices: slices),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$total',
                          style: portalText(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: OpColors.heading,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Patients',
                          style: portalText(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: OpColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  children: [
                    for (final s in slices)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: s.color.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: s.color.withValues(alpha: 0.16),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: s.color.withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _genderIcon(s.label),
                                  size: 16,
                                  color: s.color,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  s.label,
                                  style: portalText(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: OpColors.secondary,
                                  ),
                                ),
                              ),
                              Text(
                                '${s.count}',
                                style: portalText(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: OpColors.heading,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${s.percent.toStringAsFixed(0)}%)',
                                style: portalText(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: OpColors.muted,
                                ),
                              ),
                            ],
                          ),
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

class OpFinancialYearTrendCard extends StatefulWidget {
  const OpFinancialYearTrendCard({
    super.key,
    required this.trend,
    required this.footer,
    this.fyLabel = 'FY 2025-26',
    this.onFyTap,
  });

  final List<OpMonthRevenueUi> trend;
  final List<OpSummaryRowUi> footer;
  final String fyLabel;
  final VoidCallback? onFyTap;

  @override
  State<OpFinancialYearTrendCard> createState() =>
      _OpFinancialYearTrendCardState();
}

class _OpFinancialYearTrendCardState extends State<OpFinancialYearTrendCard> {
  OpChartType _type = OpChartType.composed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Same style as Bookings & Revenue Trend — only toggle added
        _OpTrendCardBody(
          trend: widget.trend,
          title: 'Financial Year Trend (2026)',
          subtitle:
              'Month-by-month (Apr–Mar) breakdown of Clinic, Lab & Pharmacy Revenue.',
          fyLabel: widget.fyLabel,
          onFyTap: widget.onFyTap,
          chartType: _type,
          chartTypeToggle: _ChartTypeToggle(
            selected: _type,
            onChanged: (t) => setState(() => _type = t),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final f in widget.footer)
                SizedBox(
                  width: (MediaQuery.sizeOf(context).width - 36) / 2 - 4,
                  child: _FyFooterChip(data: f),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChartTypeToggle extends StatelessWidget {
  const _ChartTypeToggle({
    required this.selected,
    required this.onChanged,
  });

  final OpChartType selected;
  final ValueChanged<OpChartType> onChanged;

  static const _items = <(OpChartType, String)>[
    (OpChartType.composed, 'Composed'),
    (OpChartType.area, 'Area'),
    (OpChartType.bar, 'Bar'),
    (OpChartType.line, 'Line'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          for (final item in _items)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(item.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: selected == item.$1
                        ? const Color(0xFF2563EB)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    item.$2,
                    style: portalText(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: selected == item.$1
                          ? Colors.white
                          : const Color(0xFF4B5563),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FyFooterChip extends StatelessWidget {
  const _FyFooterChip({required this.data});

  final OpSummaryRowUi data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: data.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: data.color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: OpColors.muted,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: data.color,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

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
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: OpColors.muted,
          ),
        ),
      ],
    );
  }
}

class _TrendChartPainter extends CustomPainter {
  const _TrendChartPainter({
    required this.items,
    required this.type,
  });

  final List<OpMonthRevenueUi> items;
  final OpChartType type;

  static const clinic = Color(0xFF3B82F6);
  static const lab = Color(0xFF8B5CF6);
  static const pharmacy = Color(0xFF10B981);
  static const axisMax = 260000.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (items.isEmpty) return;

    const labelH = 24.0;
    final chartH = size.height - labelH;
    final groupW = size.width / items.length;

    final gridPaint = Paint()
      ..color = const Color(0xFFD9D7E6)
      ..strokeWidth = 1;

    for (var i = 0; i <= 4; i++) {
      final y = chartH - (chartH * i / 4);
      _dash(canvas, Offset(0, y), Offset(size.width, y), gridPaint);
    }
    canvas.drawLine(
      Offset(0, chartH),
      Offset(size.width, chartH),
      Paint()
        ..color = const Color(0xFFD9D7E6)
        ..strokeWidth = 1.2,
    );

    switch (type) {
      case OpChartType.bar:
        _drawBars(canvas, chartH, groupW);
      case OpChartType.line:
        _drawLines(canvas, chartH, groupW, fill: false);
      case OpChartType.area:
        _drawLines(canvas, chartH, groupW, fill: true);
      case OpChartType.composed:
        _drawBars(canvas, chartH, groupW, alpha: 0.55);
        _drawLines(canvas, chartH, groupW, fill: false, stroke: 2.2);
    }

    for (var i = 0; i < items.length; i++) {
      final cx = groupW * i + groupW / 2;
      final tp = TextPainter(
        text: TextSpan(
          text: items[i].label,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF6B6880),
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(cx - tp.width / 2, chartH + 6));
    }
  }

  void _drawBars(Canvas canvas, double chartH, double groupW, {double alpha = 1}) {
    final barW = items.length >= 10 ? 7.0 : 11.0;
    final colors = [
      [const Color(0xFF93C5FD), const Color(0xFF3B82F6)],
      [const Color(0xFFC4B5FD), const Color(0xFF8B5CF6)],
      [const Color(0xFF6EE7B7), const Color(0xFF10B981)],
    ];

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final cx = groupW * i + groupW / 2;
      final values = [item.opd, item.lab, item.pharmacy];
      final startX = cx - (3 * barW) / 2;
      for (var b = 0; b < 3; b++) {
        final h = values[b] <= 0 ? 0.0 : (values[b] / axisMax) * (chartH - 4);
        if (h <= 0) continue;
        final left = startX + b * barW;
        final top = chartH - h;
        final r = RRect.fromRectAndCorners(
          Rect.fromLTWH(left, top, barW, h),
          topLeft: Radius.circular(barW / 2),
          topRight: Radius.circular(barW / 2),
        );
        final paint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colors[b][0].withValues(alpha: alpha),
              colors[b][1].withValues(alpha: alpha),
            ],
          ).createShader(Rect.fromLTWH(left, top, barW, h));
        canvas.drawRRect(r, paint);
      }
    }
  }

  void _drawLines(
    Canvas canvas,
    double chartH,
    double groupW, {
    required bool fill,
    double stroke = 2.5,
  }) {
    final series = [
      (clinic, (OpMonthRevenueUi e) => e.opd),
      (lab, (OpMonthRevenueUi e) => e.lab),
      (pharmacy, (OpMonthRevenueUi e) => e.pharmacy),
    ];

    for (final s in series) {
      final points = <Offset>[];
      for (var i = 0; i < items.length; i++) {
        final v = s.$2(items[i]);
        final x = groupW * i + groupW / 2;
        final y = chartH - (v / axisMax) * (chartH - 4);
        points.add(Offset(x, y));
      }
      if (points.isEmpty) continue;

      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (var i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }

      if (fill) {
        final area = Path.from(path)
          ..lineTo(points.last.dx, chartH)
          ..lineTo(points.first.dx, chartH)
          ..close();
        canvas.drawPath(
          area,
          Paint()
            ..color = s.$1.withValues(alpha: 0.18)
            ..style = PaintingStyle.fill,
        );
      }

      canvas.drawPath(
        path,
        Paint()
          ..color = s.$1
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );

      for (final p in points) {
        canvas.drawCircle(p, 3.2, Paint()..color = s.$1);
        canvas.drawCircle(p, 1.6, Paint()..color = Colors.white);
      }
    }
  }

  void _dash(Canvas canvas, Offset a, Offset b, Paint paint) {
    const dash = 4.0;
    const gap = 3.0;
    final dx = b.dx - a.dx;
    final dy = b.dy - a.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len == 0) return;
    final ux = dx / len;
    final uy = dy / len;
    var drawn = 0.0;
    while (drawn < len) {
      final next = math.min(drawn + dash, len);
      canvas.drawLine(
        Offset(a.dx + ux * drawn, a.dy + uy * drawn),
        Offset(a.dx + ux * next, a.dy + uy * next),
        paint,
      );
      drawn = next + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _TrendChartPainter oldDelegate) =>
      oldDelegate.items != items || oldDelegate.type != type;
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter({required this.slices});

  final List<OpSliceUi> slices;

  @override
  void paint(Canvas canvas, Size size) {
    final total = slices.fold<int>(0, (s, e) => s + e.count);
    final center = Offset(size.width / 2, size.height / 2);
    final stroke = size.shortestSide * 0.16;
    final radius = (size.shortestSide - stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..color = const Color(0xFFF1F2F6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );

    if (total <= 0) return;

    var start = -math.pi / 2;
    for (final s in slices) {
      if (s.count <= 0) continue;
      final sweep = (s.count / total) * math.pi * 2;
      canvas.drawArc(
        rect,
        start,
        sweep,
        false,
        Paint()
          ..color = s.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.butt,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.slices != slices;
}
