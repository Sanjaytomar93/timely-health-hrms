import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/models/camp_dashboard_ui.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/theme/camp_colors.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/widgets/camp_chart_painters.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/widgets/camp_export_button.dart';

class CampParticipationCard extends StatelessWidget {
  const CampParticipationCard({super.key, required this.items});

  final List<CampParticipationUi> items;

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
                  'Camp Participation',
                  style: portalText(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: CampColors.heading,
                  ),
                ),
              ),
              const CampExportButton(),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              _LegendDot(color: CampColors.primary, label: 'Pending'),
              SizedBox(width: 14),
              _LegendDot(color: CampColors.green, label: 'Screened'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 175,
            width: double.infinity,
            child: CustomPaint(
              painter: CampParticipationBarPainter(items: items, maxY: 5),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

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
