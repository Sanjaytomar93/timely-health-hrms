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
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PortalColors.border),
        boxShadow: [
          BoxShadow(
            color: PortalColors.brand.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: PortalColors.purpleTint,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.person_outline_rounded,
                    size: 16,
                    color: PortalColors.brand,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Profile overview',
                  style: portalText(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.heading,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Column(
              children: [
                _SummaryRow(
                  icon: Icons.mail_outline_rounded,
                  label: 'Email',
                  value: employee.email,
                ),
                _SummaryRow(
                  icon: Icons.apartment_rounded,
                  label: 'Department',
                  value:
                      employee.department.isEmpty ? '—' : employee.department,
                ),
                _SummaryRow(
                  icon: Icons.verified_outlined,
                  label: 'Status',
                  trailing: _StatusBadge(
                    label: employee.statusLabel,
                    active: employee.isActive,
                  ),
                ),
                _SummaryRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Joined',
                  value: employee.joinDateLong,
                  showDivider: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    this.value,
    this.trailing,
    this.showDivider = true,
  });

  final IconData icon;
  final String label;
  final String? value;
  final Widget? trailing;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
      decoration: showDivider
          ? const BoxDecoration(
              border: Border(bottom: BorderSide(color: PortalColors.border)),
            )
          : null,
      child: Row(
        children: [
          Icon(icon, size: 16, color: PortalColors.muted),
          const SizedBox(width: 10),
          Text(
            label,
            style: portalText(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: PortalColors.muted,
              height: 1.2,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: trailing ??
                  Text(
                    value ?? '',
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: portalText(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: PortalColors.heading,
                      height: 1.2,
                    ),
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
      padding: const EdgeInsets.fromLTRB(9, 3, 9, 3),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFE7F7F0) : PortalColors.redTint,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: portalText(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: active ? const Color(0xFF1FA971) : PortalColors.red,
          height: 1.2,
        ),
      ),
    );
  }
}
