import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/models/camp_dashboard_ui.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/theme/camp_colors.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/widgets/camp_chart_painters.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/widgets/camp_distribution_legend_row.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/widgets/camp_export_button.dart';

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
              const CampExportButton(),
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
                      CampDistributionLegendRow(slice: slice),
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
