import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/op/dashboard/presentation/models/op_walkin_ui.dart';
import 'package:timelay_health/features/op/dashboard/presentation/theme/op_colors.dart';

Future<void> showOpVitalsSheet({
  required BuildContext context,
  required OpWalkinPatientUi patient,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => OpVitalsSheet(patient: patient),
  );
}

class OpVitalsSheet extends StatefulWidget {
  const OpVitalsSheet({super.key, required this.patient});
  final OpWalkinPatientUi patient;

  @override
  State<OpVitalsSheet> createState() => _OpVitalsSheetState();
}

class _OpVitalsSheetState extends State<OpVitalsSheet> {
  final _temp = TextEditingController();
  final _bp = TextEditingController();
  final _pulse = TextEditingController();
  final _weight = TextEditingController();
  final _glucose = TextEditingController();

  @override
  void dispose() {
    _temp.dispose();
    _bp.dispose();
    _pulse.dispose();
    _weight.dispose();
    _glucose.dispose();
    super.dispose();
  }

  void _save() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Vitals saved for ${widget.patient.name}',
          style: portalText(
            fontSize: 13,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.patient;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: OpColors.primary.withValues(alpha: 0.12),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── drag handle ──────────────────────────────────────────
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0DEE8),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // ── header ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
                child: Row(
                  children: [
                    // icon box — OP primary color (soft)
                    Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: OpColors.primaryTint,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.monitor_heart_rounded,
                        color: OpColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vitals',
                            style: portalText(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: OpColors.heading,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            p.name,
                            style: portalText(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: OpColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFF94A3B8),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              // ── form fields ──────────────────────────────────────────
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _VitalField(
                        label: 'TEMP',
                        unit: '°F',
                        hint: 'e.g. 98.6',
                        controller: _temp,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 14),
                      _VitalField(
                        label: 'BP',
                        unit: 'mmHg',
                        hint: 'e.g. 120/80',
                        controller: _bp,
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(height: 14),
                      _VitalField(
                        label: 'PULSE',
                        unit: 'beats/min',
                        controller: _pulse,
                        hint: 'e.g. 72',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 14),
                      _VitalField(
                        label: 'WEIGHT',
                        unit: 'Kg',
                        hint: 'e.g. 65',
                        controller: _weight,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 14),
                      _VitalField(
                        label: 'GLUCOSE',
                        unit: 'mg/dl',
                        hint: 'e.g. 100',
                        controller: _glucose,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              // ── divider + action buttons ─────────────────────────────
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Row(
                  children: [
                    // Cancel
                    Expanded(
                      child: Material(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            height: 48,
                            alignment: Alignment.center,
                            child: Text(
                              'Cancel',
                              style: portalText(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Save Vitals
                    Expanded(
                      flex: 2,
                      child: Material(
                        color: OpColors.primary,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          onTap: _save,
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            height: 48,
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_circle_outline_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Save Vitals',
                                  style: portalText(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
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
            ],
          ),
        ),
      ),
    );
  }
}

// ── single vital input field ──────────────────────────────────────────────────

class _VitalField extends StatelessWidget {
  const _VitalField({
    required this.label,
    required this.unit,
    required this.hint,
    required this.controller,
    required this.keyboardType,
  });

  final String label;
  final String unit;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label row: "TEMP" bold primary + "(°F)" muted
        Row(
          children: [
            Text(
              label,
              style: portalText(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: OpColors.primary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              '($unit)',
              style: portalText(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Input box
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.centerLeft,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: portalText(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: OpColors.heading,
            ),
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: portalText(
                fontSize: 13,
                color: const Color(0xFFCBD5E1),
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }
}
