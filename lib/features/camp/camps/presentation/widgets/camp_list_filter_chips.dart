import 'package:flutter/material.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/theme/camp_colors.dart';

class CampListFilterChips extends StatelessWidget {
  const CampListFilterChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final String selected;
  final ValueChanged<String> onSelected;

  static const _chips = <String>[
    'All camps',
    'Today',
    'Live',
    'Upcoming',
    'Completed',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 4),
      child: Row(
        children: [
          for (var i = 0; i < _chips.length; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(
              child: _Chip(
                label: _chips[i],
                active: _chips[i] == selected,
                onTap: () => onSelected(_chips[i]),
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
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
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
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: active ? FontWeight.w700 : FontWeight.w600,
              color: active ? Colors.white : CampColors.secondary,
            ),
          ),
        ),
      ),
    );
  }
}
