import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/models/camp_dashboard_ui.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/theme/camp_colors.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/widgets/camp_chart_painters.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/widgets/camp_distribution_legend_row.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/widgets/camp_export_button.dart';

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
              const CampExportButton(),
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
