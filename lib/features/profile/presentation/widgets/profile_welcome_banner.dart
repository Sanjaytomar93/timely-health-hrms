import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/auth/domain/entities/employee.dart';

/// Compact tip strip kept for reuse; profile screen no longer mounts it
/// (greeting lives in [ProfileHeroCard]).
class ProfileWelcomeBanner extends StatelessWidget {
  const ProfileWelcomeBanner({super.key, required this.employee});

  final Employee employee;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: PortalColors.purpleTint,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PortalColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: PortalColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.info_outline_rounded,
              size: 16,
              color: PortalColors.brand,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Keep experience, documents, letters, and medical records updated in one place.',
              style: portalText(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: PortalColors.secondaryText,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
