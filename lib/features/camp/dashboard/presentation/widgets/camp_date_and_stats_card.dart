import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/models/camp_dashboard_ui.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/theme/camp_colors.dart';

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
