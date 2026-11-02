import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/theme/camp_colors.dart';

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
