import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/auth/domain/entities/employee.dart';

class ProfileHeroCard extends StatelessWidget {
  const ProfileHeroCard({super.key, required this.employee, this.onTap});

  final Employee employee;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Material(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: PortalColors.border),
            ),
            child: _content(),
          ),
        ),
      ),
    );
  }

  Widget _content() {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: PortalColors.avatarGradient,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            employee.avatarLetter,
            style: portalText(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 29 / 24,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          employee.displayName,
          textAlign: TextAlign.center,
          style: portalText(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: PortalColors.heading,
            height: 21 / 17,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          employee.role.toUpperCase(),
          textAlign: TextAlign.center,
          style: portalText(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: PortalColors.purple,
            letterSpacing: 0.6,
            height: 14 / 11.5,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 8,
          children: [
            _MetaChip(color: PortalColors.green, label: employee.email),
            _MetaChip(
              color: const Color(0xFF3B6FE0),
              label: employee.department,
            ),
            _MetaChip(
              color: PortalColors.orange,
              label: 'ID: ${employee.employeeId}',
            ),
            _MetaChip(color: PortalColors.green, label: employee.salaryLabel),
          ],
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: portalText(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: PortalColors.muted,
              height: 13 / 10.5,
            ),
          ),
        ),
      ],
    );
  }
}
