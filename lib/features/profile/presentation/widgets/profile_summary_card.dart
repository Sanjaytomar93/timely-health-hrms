import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/auth/domain/entities/employee.dart';

class ProfileSummaryCard extends StatelessWidget {
  const ProfileSummaryCard({super.key, required this.employee});

  final Employee employee;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.fromLTRB(14, 22, 14, 14),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        children: [
          _SummaryRow(label: 'Email', value: employee.email),
          _SummaryRow(
            label: 'Department',
            value: employee.department.isEmpty ? '—' : employee.department,
          ),
          _SummaryRow(
            label: 'Status',
            trailing: _StatusBadge(
              label: employee.statusLabel,
              active: employee.isActive,
            ),
          ),
          _SummaryRow(
            label: 'Joined',
            value: employee.joinDateLong,
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    this.value,
    this.trailing,
    this.showDivider = true,
  });

  final String label;
  final String? value;
  final Widget? trailing;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final textStyle = portalText(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      height: 15 / 12,
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: showDivider
          ? const BoxDecoration(
              border: Border(bottom: BorderSide(color: PortalColors.border)),
            )
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label, style: textStyle.copyWith(color: PortalColors.muted)),
          const SizedBox(width: 12),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child:
                  trailing ??
                  Text(
                    value ?? '',
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textStyle.copyWith(color: PortalColors.heading),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(9, 2, 9, 2),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFE7F7F0) : PortalColors.redTint,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        textHeightBehavior: const TextHeightBehavior(
          applyHeightToFirstAscent: false,
          applyHeightToLastDescent: false,
        ),
        style: portalText(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: active ? const Color(0xFF1FA971) : PortalColors.red,
          height: 12 / 10,
        ),
      ),
    );
  }
}
