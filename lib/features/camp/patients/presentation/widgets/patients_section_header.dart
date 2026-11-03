import 'package:flutter/material.dart';
import 'package:timelay_health/features/camp/patients/presentation/widgets/patient_tokens.dart';

class PatientsSectionHeader extends StatelessWidget {
  const PatientsSectionHeader({
    super.key,
    required this.label,
    required this.count,
  });

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: kPatientHeading,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: kPatientPrimary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: kPatientPrimary,
              ),
            ),
          ),
          const Spacer(),
          // thin line
          Expanded(
            flex: 3,
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [kPatientBorder, kPatientBorder.withValues(alpha: 0)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  ACCORDION PATIENT CARD
// ─────────────────────────────────────────────────────────────
