import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';

class AttendanceTabs extends StatelessWidget {
  const AttendanceTabs({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;

  static const _tabs = ['📋 Records', '🕒 Shift', '📍 Location'];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PortalColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 11),
      child: Row(
        children: [
          for (var i = 0; i < _tabs.length; i++) ...[
            if (i > 0) const SizedBox(width: 9),
            Expanded(
              child: _TabChip(
                label: _tabs[i],
                selected: currentIndex == i,
                onTap: () => onChanged(i),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? PortalColors.purple : PortalColors.background,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          height: 40,
          child: Center(
            child: Text(
              label,
              style: portalText(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : PortalColors.muted,
                height: 14 / 11.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
