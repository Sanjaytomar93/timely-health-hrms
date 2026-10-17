import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';

class ProfileExperienceStats extends StatelessWidget {
  const ProfileExperienceStats({super.key});

  static const _items = [
    _Stat(
      value: '0',
      label: 'Total Roles',
      subtitle: 'experience records',
      icon: 'assets/icons/profile/ic_stat_roles.svg',
      tint: PortalColors.purpleTint,
      accent: PortalColors.brand,
    ),
    _Stat(
      value: '0',
      label: 'Current Roles',
      subtitle: 'active positions',
      icon: 'assets/icons/profile/ic_stat_current.svg',
      tint: PortalColors.greenTint,
      accent: PortalColors.green,
    ),
    _Stat(
      value: '0',
      label: 'Companies',
      subtitle: 'unique employers',
      icon: 'assets/icons/profile/ic_stat_building.svg',
      tint: Color(0xFFEAF0FD),
      accent: Color(0xFF3B6FE0),
    ),
    _Stat(
      value: 'New',
      label: 'Profile',
      subtitle: 'Experience status',
      icon: 'assets/icons/profile/ic_stat_building.svg',
      tint: PortalColors.orangeTint,
      accent: PortalColors.orange,
      valueWeight: FontWeight.w600,
      valueSize: 15,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Experience snapshot',
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
              Expanded(child: _StatCard(item: _items[0])),
              const SizedBox(width: 10),
              Expanded(child: _StatCard(item: _items[1])),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _StatCard(item: _items[2])),
              const SizedBox(width: 10),
              Expanded(child: _StatCard(item: _items[3])),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat {
  const _Stat({
    required this.value,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.tint,
    required this.accent,
    this.valueWeight = FontWeight.w700,
    this.valueSize = 20,
  });

  final String value;
  final String label;
  final String subtitle;
  final String icon;
  final Color tint;
  final Color accent;
  final FontWeight valueWeight;
  final double valueSize;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.item});

  final _Stat item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
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
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: item.tint,
              borderRadius: BorderRadius.circular(11),
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(item.icon, width: 14, height: 14),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.value,
                  style: portalText(
                    fontSize: item.valueSize,
                    fontWeight: item.valueWeight,
                    color: item.accent,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.heading,
                    height: 1.2,
                  ),
                ),
                Text(
                  item.subtitle,
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
          ),
        ],
      ),
    );
  }
}
