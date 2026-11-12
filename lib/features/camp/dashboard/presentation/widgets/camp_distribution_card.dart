import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/models/camp_dashboard_ui.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/theme/camp_colors.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/utils/camp_distribution_export.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/widgets/camp_chart_painters.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/widgets/camp_distribution_legend_row.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/widgets/camp_export_button.dart';

class CampDistributionCard extends StatefulWidget {
  const CampDistributionCard({
    super.key,
    required this.data,
    this.from,
    this.to,
  });

  final CampDashboardUi data;
  final DateTime? from;
  final DateTime? to;

  @override
  State<CampDistributionCard> createState() => _CampDistributionCardState();
}

class _CampDistributionCardState extends State<CampDistributionCard> {
  bool _isExporting = false;

  Future<void> _onExport() => CampExportButton.run(
        this,
        isLoading: _isExporting,
        setLoading: (v) => setState(() => _isExporting = v),
        action: () async {
          final camps = await CampDistributionExport.fetchCamps(
            from: widget.from,
            to: widget.to,
          );
          if (!mounted) return;
          if (camps.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No camp records found to export.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
            return;
          }
          await CampDistributionExport.exportPdf(preloadedCamps: camps);
        },
      );

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
              CampExportButton(
                onTap: _onExport,
                isLoading: _isExporting,
              ),
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
                      for (final e in widget.data.distribution)
                        if (e.percent > 0) (e.percent / 100, e.color),
                    ],
                    gapRadians: 0.05,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${widget.data.distributionTotal}',
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
                    for (final slice in widget.data.distribution)
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
