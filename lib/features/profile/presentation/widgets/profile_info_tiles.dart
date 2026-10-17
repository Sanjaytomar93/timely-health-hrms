import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/auth/domain/entities/employee.dart';

class ProfileInfoTiles extends StatelessWidget {
  const ProfileInfoTiles({super.key, required this.employee});

  final Employee employee;

  @override
  Widget build(BuildContext context) {
    final tiles = [
      _Tile(
        label: 'Employee ID',
        value: employee.employeeId,
        footer: 'registered code',
        icon: 'assets/icons/profile/ic_employee_id.svg',
        accent: PortalColors.purple,
        tint: PortalColors.purpleTint,
      ),
      _Tile(
        label: 'Department',
        value: employee.department.isEmpty ? '—' : employee.department,
        footer: 'current team',
        icon: 'assets/icons/profile/ic_department.svg',
        accent: const Color(0xFF3B6FE0),
        tint: const Color(0xFFEAF0FD),
      ),
      _Tile(
        label: 'Role',
        value: employee.role.isEmpty ? '—' : employee.role,
        footer: 'active designation',
        icon: 'assets/icons/profile/ic_role.svg',
        accent: PortalColors.green,
        tint: PortalColors.greenTint,
      ),
      _Tile(
        label: 'Joined On',
        value: employee.joinDateShort,
        footer: 'start date',
        icon: 'assets/icons/profile/ic_joined.svg',
        accent: PortalColors.orange,
        tint: PortalColors.orangeTint,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick facts',
            style: portalText(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: PortalColors.heading,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _InfoTile(tile: tiles[0])),
              const SizedBox(width: 10),
              Expanded(child: _InfoTile(tile: tiles[1])),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _InfoTile(tile: tiles[2])),
              const SizedBox(width: 10),
              Expanded(child: _InfoTile(tile: tiles[3])),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tile {
  const _Tile({
    required this.label,
    required this.value,
    required this.footer,
    required this.icon,
    required this.accent,
    required this.tint,
  });

  final String label;
  final String value;
  final String footer;
  final String icon;
  final Color accent;
  final Color tint;
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.tile});

  final _Tile tile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 11),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PortalColors.border),
        boxShadow: [
          BoxShadow(
            color: PortalColors.brand.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: tile.tint,
                  borderRadius: BorderRadius.circular(9),
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset(tile.icon, width: 13, height: 13),
              ),
              const Spacer(),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: tile.accent,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            tile.label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: PortalColors.muted,
              letterSpacing: 0.4,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tile.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: PortalColors.heading,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            tile.footer,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 9.5,
              color: PortalColors.muted,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
