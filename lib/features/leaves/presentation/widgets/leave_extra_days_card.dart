import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/leaves/presentation/models/leave_ui_model.dart';

class LeaveExtraDaysCard extends StatelessWidget {
  const LeaveExtraDaysCard({
    super.key,
    this.stats = LeaveStatsUiModel.empty,
    this.month,
  });

  final LeaveStatsUiModel stats;
  final DateTime? month;

  @override
  Widget build(BuildContext context) {
    final extra = stats.extraDays;
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 12, 18, 0),
      padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '⇄  Extra Days Details',
                style: portalText(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: PortalColors.heading,
                ),
              ),
              const Spacer(),
              Container(
                height: 20,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: PortalColors.background,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: PortalColors.border),
                ),
                alignment: Alignment.center,
                child: Text(
                  _currentMonthYear(month),
                  style: portalText(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.secondaryText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _currentMonthKey(month),
            style: portalText(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: PortalColors.muted,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _DayTile(
                  value: '${stats.assignedDays}',
                  label: 'Assigned Days',
                  background: PortalColors.purpleTint,
                  valueColor: PortalColors.purple,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DayTile(
                  value: '${stats.presentDays}',
                  label: 'Present Days',
                  background: PortalColors.orangeTint,
                  valueColor: PortalColors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: 28,
            decoration: BoxDecoration(
              color: PortalColors.background,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: PortalColors.border),
            ),
            alignment: Alignment.center,
            child: Text(
              extra == 0
                  ? 'No Extra Days'
                  : '$extra Extra ${extra == 1 ? 'Day' : 'Days'} Worked',
              style: portalText(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: extra == 0 ? PortalColors.muted : PortalColors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayTile extends StatelessWidget {
  const _DayTile({
    required this.value,
    required this.label,
    required this.background,
    required this.valueColor,
  });

  final String value;
  final String label;
  final Color background;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: portalText(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: portalText(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: PortalColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

String _currentMonthYear([DateTime? date]) {
  final d = (date ?? DateTime.now()).toLocal();
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${months[d.month - 1]} ${d.year}';
}

String _currentMonthKey([DateTime? date]) {
  final d = (date ?? DateTime.now()).toLocal();
  final m = d.month.toString().padLeft(2, '0');
  return '${d.year}-$m';
}
