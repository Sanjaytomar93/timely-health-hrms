import 'package:flutter/material.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/theme/camp_colors.dart';

class PatientsFilterChips extends StatelessWidget {
  const PatientsFilterChips({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.counts,
  });

  final String selected;
  final ValueChanged<String> onSelected;
  final Map<String, int> counts;

  static const _chips = <({String label, IconData icon})>[
    (label: 'All', icon: Icons.grid_view_rounded),
    (label: 'Female', icon: Icons.female_rounded),
    (label: 'Male', icon: Icons.male_rounded),
    (label: 'Minors', icon: Icons.child_care_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 2, 14, 4),
      child: Row(
        children: [
          for (var i = 0; i < _chips.length; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(
              child: _Chip(
                label: _chips[i].label,
                icon: _chips[i].icon,
                count: counts[_chips[i].label],
                active: _chips[i].label == selected,
                onTap: () => onSelected(_chips[i].label),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
    this.count,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
          decoration: BoxDecoration(
            gradient: active
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [CampColors.primary, CampColors.primaryLight],
                  )
                : null,
            color: active ? null : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: active
                  ? Colors.transparent
                  : CampColors.primary.withValues(alpha: 0.18),
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: CampColors.primary.withValues(alpha: 0.22),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 12,
                color: active ? Colors.white : CampColors.primary,
              ),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  count == null ? label : '$label $count',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active ? Colors.white : CampColors.secondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
