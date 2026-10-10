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
    ),
    _Stat(
      value: '0',
      label: 'Current Roles',
      subtitle: 'active positions',
      icon: 'assets/icons/profile/ic_stat_current.svg',
    ),
    _Stat(
      value: '0',
      label: 'Companies',
      subtitle: 'unique employers',
      icon: 'assets/icons/profile/ic_stat_building.svg',
    ),
    _Stat(
      value: 'New',
      label: 'Profile',
      subtitle: 'Experience status',
      icon: 'assets/icons/profile/ic_stat_building.svg',
      valueWeight: FontWeight.w500,
      valueSize: 15,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < _items.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(child: _StatCard(item: _items[i])),
            ],
          ],
        ),
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
    this.valueWeight = FontWeight.w700,
    this.valueSize = 17,
  });

  final String value;
  final String label;
  final String subtitle;
  final String icon;
  final FontWeight valueWeight;
  final double valueSize;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.item});

  final _Stat item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 11, 8, 10),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: PortalColors.purpleTint,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(item.icon, width: 12, height: 12),
          ),
          const SizedBox(height: 6),
          Text(
            item.value,
            textAlign: TextAlign.center,
            style: portalText(
              fontSize: item.valueSize,
              fontWeight: item.valueWeight,
              color: PortalColors.green,
              height: 21 / 17,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            item.label.toUpperCase(),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: PortalColors.muted,
              letterSpacing: 0.3,
              height: 10 / 8,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.subtitle,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 8.5,
              color: PortalColors.muted,
              height: 10 / 8.5,
            ),
          ),
        ],
      ),
    );
  }
}
