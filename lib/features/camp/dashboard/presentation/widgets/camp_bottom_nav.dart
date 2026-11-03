import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/theme/camp_colors.dart';

class CampBottomNav extends StatelessWidget {
  const CampBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = <({IconData icon, IconData activeIcon, String label})>[
    (
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    (
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month_rounded,
      label: 'Camps',
    ),
    (
      icon: Icons.people_outline_rounded,
      activeIcon: Icons.people_rounded,
      label: 'Patients',
    ),
    (
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: CampColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 48,
            offset: Offset(-1, -15),
            spreadRadius: -17,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        minimum: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: _CampNavItem(
                    icon: currentIndex == i
                        ? _items[i].activeIcon
                        : _items[i].icon,
                    label: _items[i].label,
                    selected: currentIndex == i,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CampNavItem extends StatelessWidget {
  const _CampNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const boxSize = 42.0;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            width: boxSize,
            height: boxSize,
            decoration: BoxDecoration(
              color: selected
                  ? CampColors.primary.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(24),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 26,
              color: selected ? CampColors.primary : const Color(0xFF888888),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: portalText(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? CampColors.primary : const Color(0xFF888888),
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
