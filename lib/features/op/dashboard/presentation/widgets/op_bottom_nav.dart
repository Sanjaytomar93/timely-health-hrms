import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/nav_icons.dart';

class OpBottomNav extends StatelessWidget {
  const OpBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _labels = ['Dashboard', 'Walk-in', 'Doctors', 'Service'];
  static const _icons = [
    Icons.home_rounded,
    Icons.directions_walk_rounded,
    Icons.medical_services_rounded,
    Icons.miscellaneous_services_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: PortalColors.surface,
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
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
          child: Row(
            children: [
              for (var i = 0; i < _labels.length; i++)
                Expanded(
                  child: _OpNavItem(
                    icon: _icons[i],
                    label: _labels[i],
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

class _OpNavItem extends StatelessWidget {
  const _OpNavItem({
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
    const boxSize = 46.0;
    const iconSize = 26.0;

    final Color? bg = selected ? NavIcons.activeBg : null;
    final labelColor = selected ? NavIcons.active : NavIcons.inactive;

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
              color: bg ?? Colors.transparent,
              borderRadius: BorderRadius.circular(28),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: iconSize,
              color: selected ? NavIcons.active : NavIcons.inactive,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: portalText(
              fontSize: 10.5,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: labelColor,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
