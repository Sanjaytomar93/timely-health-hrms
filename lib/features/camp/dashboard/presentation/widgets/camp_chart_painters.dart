import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/models/camp_dashboard_ui.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/theme/camp_colors.dart';

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
