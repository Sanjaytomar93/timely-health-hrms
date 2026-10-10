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
      ),
      _Tile(
        label: 'Department',
        value: employee.department.isEmpty ? '—' : employee.department,
        footer: 'current team',
        icon: 'assets/icons/profile/ic_department.svg',
      ),
      _Tile(
        label: 'Role',
        value: employee.role.isEmpty ? '—' : employee.role,
        footer: 'active designation',
        icon: 'assets/icons/profile/ic_role.svg',
      ),
      _Tile(
        label: 'Joined On',
        value: employee.joinDateShort,
        footer: employee.email,
        icon: 'assets/icons/profile/ic_joined.svg',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _InfoTile(tile: tiles[0])),
              const SizedBox(width: 10),
              Expanded(child: _InfoTile(tile: tiles[1])),
            ],
          ),
          const SizedBox(height: 9),
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
  });

  final String label;
  final String value;
  final String footer;
  final String icon;
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.tile});

  final _Tile tile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: PortalColors.purpleTint,
                  borderRadius: BorderRadius.circular(7),
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset(tile.icon, width: 11, height: 11),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  tile.label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.muted,
                    letterSpacing: 0.3,
                    height: 11 / 9,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            tile.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: PortalColors.heading,
              height: 16 / 13.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tile.footer,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 9.5,
              color: PortalColors.muted,
              height: 11 / 9.5,
            ),
          ),
        ],
      ),
    );
  }
}
