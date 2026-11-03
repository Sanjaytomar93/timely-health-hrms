import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/camp/patients/presentation/models/patient_list_ui.dart';

class PatientsStatGrid extends StatelessWidget {
  const PatientsStatGrid({super.key, required this.stats});

  final List<PatientStatUi> stats;

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) return const SizedBox.shrink();

    final rows = <Widget>[];
    for (var i = 0; i < stats.length; i += 2) {
      if (i > 0) rows.add(const SizedBox(height: 10));
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _CompactStatCard(stat: stats[i])),
              const SizedBox(width: 10),
              Expanded(
                child: i + 1 < stats.length
                    ? _CompactStatCard(stat: stats[i + 1])
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(children: rows),
    );
  }
}

class _CompactStatCard extends StatelessWidget {
  const _CompactStatCard({required this.stat});

  final PatientStatUi stat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PortalColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: stat.iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(stat.icon, size: 22, color: stat.iconFg),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.title.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.muted,
                    letterSpacing: 0.4,
                    height: 12 / 10,
                  ),
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: stat.value,
                        style: portalText(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: stat.valueColor,
                          height: 24 / 20,
                        ),
                      ),
                      TextSpan(
                        text: ' ${stat.subtitle}',
                        style: portalText(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: PortalColors.muted,
                          height: 24 / 11,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
