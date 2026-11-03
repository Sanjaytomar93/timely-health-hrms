import 'package:flutter/material.dart';
import 'package:timelay_health/features/camp/patients/presentation/widgets/patient_tokens.dart';

class PatientsEmptyState extends StatelessWidget {
  const PatientsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: kPatientPrimary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.people_alt_outlined,
              size: 34,
              color: kPatientPrimary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No patients found',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: kPatientHeading,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try adjusting your search or filter',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: kPatientMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  ADD NEW PATIENT FAB-STYLE BUTTON
// ─────────────────────────────────────────────────────────────
