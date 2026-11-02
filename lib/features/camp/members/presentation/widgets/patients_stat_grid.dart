import 'package:flutter/material.dart';
import 'package:timelay_health/features/camp/members/presentation/models/patient_list_ui.dart';
import 'package:timelay_health/features/camp/members/presentation/widgets/member_tokens.dart';

class PatientsStatGrid extends StatelessWidget {
  const PatientsStatGrid({super.key, required this.stats});

  final List<PatientStatUi> stats;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.35,
        ),
        itemCount: stats.length,
        itemBuilder: (_, i) => _StatTile(stat: stats[i]),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.stat});

  final PatientStatUi stat;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kMemberSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kMemberBorder),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: stat.iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(stat.icon, size: 16, color: stat.iconFg),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    stat.value,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: kMemberHeading,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    stat.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 9.5,
                      fontWeight: FontWeight.w400,
                      color: kMemberMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
