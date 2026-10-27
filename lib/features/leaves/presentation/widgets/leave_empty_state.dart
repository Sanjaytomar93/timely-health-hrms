import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';

class LeaveEmptyState extends StatelessWidget {
  const LeaveEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PortalColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A1E1640),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  PortalColors.brand.withValues(alpha: 0.12),
                  PortalColors.brandLight.withValues(alpha: 0.18),
                ],
              ),
            ),
            child: Icon(icon, size: 26, color: PortalColors.brand),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: portalText(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: PortalColors.heading,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: portalText(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: PortalColors.muted,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
