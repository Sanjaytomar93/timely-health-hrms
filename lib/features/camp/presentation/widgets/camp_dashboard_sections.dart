import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/camp/presentation/models/camp_dashboard_ui.dart';
import 'package:timelay_health/features/camp/presentation/theme/camp_colors.dart';

// ── Hero Banner Carousel ───────────────────────────────────────────────────

class CampHeroBanner extends StatefulWidget {
  const CampHeroBanner({super.key});

  @override
  State<CampHeroBanner> createState() => _CampHeroBannerState();
}

class _CampHeroBannerState extends State<CampHeroBanner> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const _totalPages = 5;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      child: Column(
        children: [
          SizedBox(
            height: 172,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _totalPages,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0F1A1A2E),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/camp_banner.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _totalPages,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _currentPage ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: i == _currentPage
                      ? CampColors.primary
                      : const Color(0xFFD1D5DB),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Combined Date + 5 Stats Card ────────────────────────────────────────────

class CampDateAndStatsCard extends StatelessWidget {
  const CampDateAndStatsCard({super.key, required this.data});

  final CampDashboardUi data;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: CampColors.card(radius: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Row on top left
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.calendar_month_outlined,
                size: 20,
                color: CampColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                data.dateLabel,
                style: portalText(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: CampColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // 5 circular stat items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final s in data.stats)
                _StatColumnItem(
                  data: s,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatColumnItem extends StatelessWidget {
  const _StatColumnItem({required this.data});

  final CampStatUi data;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: data.tint,
            shape: BoxShape.circle,
          ),
          child: data.isPulse
              ? CustomPaint(
                  size: const Size(22, 14),
                  painter: _PulseWavePainter(color: data.accent),
                )
              : Icon(data.icon, size: 21, color: data.accent),
        ),
        const SizedBox(height: 8),
        Text(
          data.value,
          style: portalText(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: CampColors.heading,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          data.title,
          style: portalText(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: CampColors.muted,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}

class _PulseWavePainter extends CustomPainter {
  const _PulseWavePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;
    final midY = h * 0.55;

    final path = Path()
      ..moveTo(0, midY)
      ..lineTo(w * 0.22, midY)
      ..lineTo(w * 0.38, 0)
      ..lineTo(w * 0.58, h)
      ..lineTo(w * 0.74, midY - 3)
      ..lineTo(w * 0.85, midY)
      ..lineTo(w, midY);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PulseWavePainter oldDelegate) =>
      oldDelegate.color != color;
}

// ── Hero With Stats (Clean Wrapper) ─────────────────────────────────────────

class CampHeroWithStats extends StatelessWidget {
  const CampHeroWithStats({super.key, required this.data});

  final CampDashboardUi data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CampHeroBanner(),
        CampDateAndStatsCard(data: data),
      ],
    );
  }
}

// ── Date Range Filter Card ──────────────────────────────────────────────────

class CampDateFilterCard extends StatelessWidget {
  const CampDateFilterCard({
    super.key,
    required this.from,
    required this.to,
    required this.onPickFrom,
    required this.onPickTo,
    required this.onReset,
  });

  final DateTime? from;
  final DateTime? to;
  final VoidCallback onPickFrom;
  final VoidCallback onPickTo;
  final VoidCallback onReset;

  String _fmt(DateTime? d) {
    if (d == null) return 'Select date';
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$day/$m/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      padding: const EdgeInsets.all(16),
      decoration: CampColors.card(radius: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_month_outlined,
                size: 20,
                color: CampColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Date Range',
                  style: portalText(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: CampColors.heading,
                  ),
                ),
              ),
              Material(
                color: CampColors.primaryTint,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: onReset,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: Text(
                      'Reset',
                      style: portalText(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: CampColors.primary,
                      ),
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
                child: _DateFieldBox(
                  label: 'From',
                  value: _fmt(from),
                  onTap: onPickFrom,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: CampColors.muted,
                ),
              ),
              Expanded(
                child: _DateFieldBox(
                  label: 'To',
                  value: _fmt(to),
                  onTap: onPickTo,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateFieldBox extends StatelessWidget {
  const _DateFieldBox({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: CampColors.background,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: CampColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: portalText(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: CampColors.muted,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: portalText(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: CampColors.heading,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: CampColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Export Button Pill ───────────────────────────────────────────────────────

class _CampExportButton extends StatelessWidget {
  const _CampExportButton();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: CampColors.primaryTint,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.file_download_outlined,
                size: 15,
                color: CampColors.primary,
              ),
              const SizedBox(width: 4),
              Text(
                'Export',
                style: portalText(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: CampColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Camp Distribution Card ──────────────────────────────────────────────────

class CampDistributionCard extends StatelessWidget {
  const CampDistributionCard({super.key, required this.data});

  final CampDashboardUi data;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: CampColors.card(radius: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Camp Distribution',
                  style: portalText(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: CampColors.heading,
                  ),
                ),
              ),
              const _CampExportButton(),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              SizedBox(
                width: 132,
                height: 132,
                child: CustomPaint(
                  painter: CampDonutPainter(
                    slices: [
                      for (final e in data.distribution)
                        if (e.percent > 0) (e.percent / 100, e.color),
                    ],
                    gapRadians: 0.05,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${data.distributionTotal}',
                          style: portalText(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: CampColors.heading,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Total',
                          style: portalText(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: CampColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    for (final slice in data.distribution)
                      _DistributionLegendRow(slice: slice),
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

class _DistributionLegendRow extends StatelessWidget {
  const _DistributionLegendRow({required this.slice});

  final CampSliceUi slice;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: slice.color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              slice.label,
              style: portalText(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: CampColors.secondary,
              ),
            ),
          ),
          Text(
            '${slice.count}',
            style: portalText(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: CampColors.heading,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 36,
            padding: const EdgeInsets.symmetric(vertical: 2),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: slice.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${slice.percent.toStringAsFixed(0)}%',
              style: portalText(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: slice.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── BMI Distribution Card ───────────────────────────────────────────────────

class CampBmiCard extends StatelessWidget {
  const CampBmiCard({super.key, required this.items});

  final List<CampBmiUi> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: CampColors.card(radius: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'BMI Distribution',
                  style: portalText(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: CampColors.heading,
                  ),
                ),
              ),
              const _CampExportButton(),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              _BmiLegendDot(color: CampColors.blue, label: 'Under'),
              SizedBox(width: 14),
              _BmiLegendDot(color: CampColors.green, label: 'Healthy'),
              SizedBox(width: 14),
              _BmiLegendDot(color: CampColors.orange, label: 'Over'),
              SizedBox(width: 14),
              _BmiLegendDot(color: CampColors.red, label: 'Obese'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 175,
            width: double.infinity,
            child: CustomPaint(
              painter: CampStackedBarPainter(items: items, maxY: 5),
            ),
          ),
        ],
      ),
    );
  }
}

class _BmiLegendDot extends StatelessWidget {
  const _BmiLegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2.5),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: portalText(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: CampColors.secondary,
          ),
        ),
      ],
    );
  }
}

// ── BP & Sugar Analysis Card ────────────────────────────────────────────────

class CampBpAnalysisCard extends StatelessWidget {
  const CampBpAnalysisCard({
    super.key,
    required this.data,
    required this.showSugar,
    required this.onToggle,
  });

  final CampDashboardUi data;
  final bool showSugar;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final slices = showSugar ? data.sugarSlices : data.bpSlices;
    final patients = showSugar ? data.sugarPatients : data.bpPatients;

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 14, 14, 20),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: CampColors.card(radius: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  showSugar ? 'Sugar Analysis' : 'Blood Pressure',
                  style: portalText(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: CampColors.heading,
                  ),
                ),
              ),
              const _CampExportButton(),
            ],
          ),
          const SizedBox(height: 14),
          // Toggle switcher
          Container(
            height: 42,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: CampColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CampColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _AnalysisSegmentButton(
                    label: 'Blood Pressure',
                    selected: !showSugar,
                    onTap: () => onToggle(false),
                  ),
                ),
                Expanded(
                  child: _AnalysisSegmentButton(
                    label: 'Sugar',
                    selected: showSugar,
                    onTap: () => onToggle(true),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              SizedBox(
                width: 132,
                height: 132,
                child: CustomPaint(
                  painter: CampDonutPainter(
                    slices: slices
                        .map((e) => (e.percent / 100, e.color))
                        .toList(),
                    gapRadians: 0.06,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$patients',
                          style: portalText(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: CampColors.heading,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Patients',
                          style: portalText(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: CampColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    for (final slice in slices)
                      _DistributionLegendRow(slice: slice),
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

class _AnalysisSegmentButton extends StatelessWidget {
  const _AnalysisSegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? CampColors.surface : Colors.transparent,
      borderRadius: BorderRadius.circular(9),
      elevation: selected ? 1 : 0,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          alignment: Alignment.center,
          child: Text(
            label,
            style: portalText(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? CampColors.primary : CampColors.muted,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Chart Painters ──────────────────────────────────────────────────────────

class CampDonutPainter extends CustomPainter {
  CampDonutPainter({required this.slices, this.gapRadians = 0});

  final List<(double, Color)> slices;
  final double gapRadians;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.shortestSide * 0.17;
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: (size.shortestSide - stroke) / 2,
    );

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = const Color(0xFFF1F2F6)
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(rect, 0, 2 * math.pi, false, track);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    var start = -math.pi / 2;
    final total = slices.fold<double>(0, (a, e) => a + e.$1);
    if (total <= 0) return;

    final gapCount = slices.where((e) => e.$1 > 0).length;
    final usable = 2 * math.pi - (gapCount * gapRadians);

    for (final slice in slices) {
      if (slice.$1 <= 0) continue;
      final sweep = (slice.$1 / total) * usable;
      if (sweep <= 0) continue;
      paint.color = slice.$2;
      canvas.drawArc(rect, start + gapRadians / 2, sweep, false, paint);
      start += sweep + gapRadians;
    }
  }

  @override
  bool shouldRepaint(covariant CampDonutPainter oldDelegate) =>
      oldDelegate.slices != slices || oldDelegate.gapRadians != gapRadians;
}

class CampStackedBarPainter extends CustomPainter {
  CampStackedBarPainter({required this.items, this.maxY = 5});

  final List<CampBmiUi> items;
  final double maxY;

  static const _leftAxis = 20.0;
  static const _bottomLabels = 22.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (items.isEmpty) return;
    final chartTop = 8.0;
    final chartBottom = size.height - _bottomLabels;
    final chartLeft = _leftAxis;
    final chartRight = size.width;
    final chartH = chartBottom - chartTop;
    final chartW = chartRight - chartLeft;
    final peak = maxY <= 0 ? 1.0 : maxY;

    final grid = Paint()
      ..color = CampColors.border
      ..strokeWidth = 1;

    for (var i = 0; i <= 5; i++) {
      final t = i / 5;
      final y = chartBottom - chartH * t;
      canvas.drawLine(Offset(chartLeft, y), Offset(chartRight, y), grid);
      final tp = TextPainter(
        text: TextSpan(
          text: '$i',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: CampColors.muted,
            height: 1,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(2, y - tp.height / 2));
    }

    final groupW = chartW / items.length;
    final barW = groupW * 0.44;

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final left = chartLeft + groupW * i + (groupW - barW) / 2;
      var y = chartBottom;

      void stack(double value, Color color, {bool isTop = false}) {
        if (value <= 0) return;
        final h = (value / peak) * chartH;
        y -= h;
        final r = isTop ? const Radius.circular(3) : Radius.zero;
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTWH(left, y, barW, h),
            topLeft: r,
            topRight: r,
          ),
          Paint()..color = color,
        );
      }

      final hasObese = item.obese > 0;
      final hasOver = item.over > 0;
      final hasHealthy = item.healthy > 0;

      stack(
        item.under,
        CampColors.blue,
        isTop: !hasHealthy && !hasOver && !hasObese,
      );
      stack(
        item.healthy,
        CampColors.green,
        isTop: !hasOver && !hasObese,
      );
      stack(
        item.over,
        CampColors.orange,
        isTop: !hasObese,
      );
      stack(
        item.obese,
        CampColors.red,
        isTop: true,
      );

      final label = TextPainter(
        text: TextSpan(
          text: item.label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: CampColors.muted,
            height: 1.2,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout(maxWidth: groupW);
      label.paint(
        canvas,
        Offset(
          chartLeft + groupW * i + (groupW - label.width) / 2,
          chartBottom + 6,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CampStackedBarPainter oldDelegate) =>
      oldDelegate.items != items || oldDelegate.maxY != maxY;
}
