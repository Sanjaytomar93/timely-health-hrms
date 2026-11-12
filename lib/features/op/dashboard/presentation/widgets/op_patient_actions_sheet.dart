import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/op/dashboard/presentation/models/op_walkin_ui.dart';
import 'package:timelay_health/features/op/dashboard/presentation/theme/op_colors.dart';

Future<void> showOpPatientActionsSheet({
  required BuildContext context,
  required OpWalkinPatientUi patient,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => OpPatientActionsSheet(patient: patient),
  );
}

class OpPatientActionsSheet extends StatelessWidget {
  const OpPatientActionsSheet({super.key, required this.patient});

  final OpWalkinPatientUi patient;

  void _tap(BuildContext context, String label) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          label,
          style: portalText(
            fontSize: 13,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = patient;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: OpColors.primary.withValues(alpha: 0.14),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0DEE8),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // Patient header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 12, 0),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: OpColors.heroGradient,
                      ),
                    ),
                    child: Text(
                      p.initial,
                      style: portalText(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: portalText(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: OpColors.heading,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${p.age} yrs · ${p.gender}  ·  ${p.phone}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: portalText(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: OpColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    color: OpColors.muted,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Quick actions grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _QuickTile(
                      icon: Icons.visibility_rounded,
                      label: 'View',
                      color: OpColors.purple,
                      onTap: () => _tap(context, 'View'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _QuickTile(
                      icon: Icons.edit_rounded,
                      label: 'Edit',
                      color: OpColors.blue,
                      onTap: () => _tap(context, 'Edit'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _QuickTile(
                      icon: Icons.medication_liquid_rounded,
                      label: 'Rx',
                      color: OpColors.cyan,
                      onTap: () => _tap(context, 'Prescription'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _QuickTile(
                      icon: Icons.monitor_heart_rounded,
                      label: 'Vitals',
                      color: OpColors.pink,
                      onTap: () => _tap(context, 'Vitals'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _ActionRow(
                    icon: Icons.receipt_long_rounded,
                    label: 'Generate Bill',
                    subtitle: 'Print or share invoice',
                    color: OpColors.green,
                    onTap: () => _tap(context, 'Generate Bill'),
                  ),
                  const SizedBox(height: 8),
                  _ActionRow(
                    icon: Icons.star_rounded,
                    label: 'Mark Review',
                    subtitle: 'Flag for doctor review',
                    color: OpColors.orange,
                    onTap: () => _tap(context, 'Mark Review'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Material(
                color: OpColors.redTint,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () => _tap(context, 'Mark Inactive'),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.toggle_on_rounded,
                            color: OpColors.red,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mark Inactive',
                                style: portalText(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: OpColors.red,
                                ),
                              ),
                              Text(
                                'Hide this patient from active list',
                                style: portalText(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: OpColors.red.withValues(alpha: 0.75),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: OpColors.red.withValues(alpha: 0.7),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.18),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: portalText(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF7F6FC),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: portalText(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: OpColors.heading,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: portalText(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: OpColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: OpColors.muted.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
