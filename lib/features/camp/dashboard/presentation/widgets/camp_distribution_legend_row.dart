import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/models/camp_dashboard_ui.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/theme/camp_colors.dart';

class CampDistributionLegendRow extends StatelessWidget {
  const CampDistributionLegendRow({super.key, required this.slice});

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
