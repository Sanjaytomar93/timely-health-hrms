import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/dashboard_card.dart';

class WeeklyBarChartCard extends StatelessWidget {
  const WeeklyBarChartCard({
    super.key,
    required this.title,
    required this.titleIcon,
    required this.barColor,
    required this.values,
    this.subtitle = 'Week Wise Details',
    this.barColors,
    this.monthLabel,
    this.onMonthTap,
    this.topSpacing = kDashboardSectionGap,
  });

  static const _gridSteps = 5;

  final double topSpacing;

  final String title;
  final String subtitle;
  final IconData titleIcon;
  final Color barColor;
  final List<double> values;
  final List<Color>? barColors;
  final String? monthLabel;
  final VoidCallback? onMonthTap;

  @override
  Widget build(BuildContext context) {
    final chip = (monthLabel != null && monthLabel!.trim().isNotEmpty)
        ? monthLabel!.trim()
        : _currentMonthYear();

    final peak = values.fold<double>(0, (a, b) => b > a ? b : a);
    final step = _niceStep(peak / _gridSteps);
    final axisMax = step * _gridSteps;
    final yLabels = [
      for (var i = _gridSteps; i >= 0; i--) _axisLabel(step * i),
    ];
    final total = values.fold<double>(0, (a, b) => a + b);
    final peakIndex = peak > 0 ? values.indexOf(peak) : -1;

    const valueSpace = 14.0;
    const labelHeight = 10.0;
    const lineGap = 15.0;
    const axisWidth = 25.0;
    const axisGap = 6.0;
    const barWidth = 34.0;
    final gridHeight = lineGap * (yLabels.length - 1);

    return DashboardCard(
      topSpacing: topSpacing,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        children: [
          DashboardCardHeader(
            icon: titleIcon,
            color: barColor,
            title: title,
            subtitle: subtitle,
            trailing: DashboardMonthChip(label: chip, onTap: onMonthTap),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: valueSpace + gridHeight + labelHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: axisWidth,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      for (var i = 0; i < yLabels.length; i++)
                        Positioned(
                          top: valueSpace + i * lineGap,
                          right: 0,
                          height: labelHeight,
                          child: Text(
                            yLabels[i],
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.visible,
                            textAlign: TextAlign.right,
                            style: portalText(
                              fontSize: 8,
                              fontWeight: FontWeight.w500,
                              color: PortalColors.muted,
                              height: labelHeight / 8,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: axisGap),
                Expanded(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      for (var i = 0; i < yLabels.length; i++)
                        Positioned(
                          top: valueSpace + labelHeight / 2 + i * lineGap - 0.25,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 0.5,
                            color: PortalColors.muted.withValues(alpha: 0.16),
                          ),
                        ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: labelHeight / 2,
                        height: valueSpace + gridHeight,
                        child: Row(
                          children: [
                            for (var i = 0; i < values.length; i++)
                              Expanded(
                                child: _bar(
                                  value: values[i],
                                  color: _colorAt(i),
                                  height:
                                      gridHeight *
                                      (values[i] / axisMax).clamp(0.0, 1.0),
                                  trackHeight: gridHeight,
                                  width: barWidth,
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
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: axisWidth + axisGap),
            child: Row(
              children: List.generate(values.length, (i) {
                return Expanded(
                  child: Text(
                    'Week ${i + 1}',
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: portalText(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: i == peakIndex
                          ? PortalColors.heading
                          : PortalColors.muted,
                      height: 12 / 10,
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: barColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _summaryItem(
                    icon: titleIcon,
                    value: total.toStringAsFixed(0),
                    label: 'Total $title',
                  ),
                ),
                Container(
                  width: 1,
                  height: 24,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  color: barColor.withValues(alpha: 0.25),
                ),
                Expanded(
                  child: _summaryItem(
                    icon: Icons.trending_up_rounded,
                    value: peakIndex >= 0 ? 'Week ${peakIndex + 1}' : '—',
                    label: 'Highest Week',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bar({
    required double value,
    required Color color,
    required double height,
    required double trackHeight,
    required double width,
  }) {
    final isZero = height <= 0;
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          width: width,
          height: trackHeight,
          decoration: BoxDecoration(
            color: PortalColors.background,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              value.toStringAsFixed(0),
              maxLines: 1,
              style: portalText(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isZero ? PortalColors.secondaryText : PortalColors.heading,
                height: 12 / 10,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              width: width,
              height: isZero ? 6 : height,
              decoration: BoxDecoration(
                borderRadius: isZero
                    ? BorderRadius.circular(3)
                    : const BorderRadius.vertical(top: Radius.circular(14)),
                color: isZero ? PortalColors.border : null,
                gradient: isZero
                    ? null
                    : LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color.lerp(color, Colors.white, 0.3)!, color],
                      ),
                boxShadow: isZero
                    ? null
                    : [
                        BoxShadow(
                          color: color.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _summaryItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: barColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 15, color: barColor),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  maxLines: 1,
                  style: portalText(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    height: 17 / 14,
                  ),
                ),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: portalText(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: PortalColors.secondaryText,
                  height: 11 / 9,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static double _niceStep(double raw) {
    if (raw <= 1) return 1;
    var magnitude = 1.0;
    while (magnitude * 10 <= raw) {
      magnitude *= 10;
    }
    for (final factor in const [1, 2, 5, 10]) {
      if (magnitude * factor >= raw) return magnitude * factor;
    }
    return magnitude * 10;
  }

  static String _axisLabel(double value) {
    if (value >= 1000 && value % 1000 == 0) {
      return '${(value / 1000).toStringAsFixed(0)}k';
    }
    return value.toStringAsFixed(0);
  }

  Color _colorAt(int index) {
    final colors = barColors;
    if (colors == null || colors.isEmpty) return barColor;
    return colors[index % colors.length];
  }
}

class DashboardMonthChip extends StatelessWidget {
  const DashboardMonthChip({super.key, required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(999);
    return Material(
      color: PortalColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: const BorderSide(color: PortalColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          height: 26,
          padding: EdgeInsets.only(left: 10, right: onTap != null ? 6 : 10),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.calendar_month_rounded,
                size: 12,
                color: PortalColors.brandLight,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: portalText(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: PortalColors.secondaryText,
                  height: 13 / 10.5,
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 2),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 14,
                  color: PortalColors.secondaryText,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

String monthYearLabel(DateTime date) => _currentMonthYear(date);

String _currentMonthYear([DateTime? date]) {
  final d = date ?? DateTime.now();
  const months = [
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
  return '${months[d.month - 1]} ${d.year}';
}
