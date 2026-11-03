import 'package:flutter/material.dart';
import 'package:timelay_health/features/camp/camps/presentation/models/camp_list_ui.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/theme/camp_colors.dart';

class CampListStatStrip extends StatelessWidget {
  const CampListStatStrip({
    super.key,
    required this.stats,
    this.selectedFilter,
    this.onStatTap,
  });

  final List<CampListStatUi> stats;
  final String? selectedFilter;
  final ValueChanged<CampListStatUi>? onStatTap;

  static const _pad = 16.0;
  static const _gap = 8.0;
  static const _visible = 3;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final usable =
            constraints.maxWidth - (_pad * 2) - (_gap * (_visible - 1));
        final cardW = usable / _visible;

        return SizedBox(
          height: 104,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(_pad, 6, _pad, 6),
            itemCount: stats.length,
            separatorBuilder: (_, _) => const SizedBox(width: _gap),
            itemBuilder: (context, i) {
              final stat = stats[i];
              final isSelected = switch (stat.title) {
                'TOTAL CAMPS' => selectedFilter == 'All camps',
                'ACTIVE CAMPS' => selectedFilter == 'Today',
                'UPCOMING' => selectedFilter == 'Upcoming',
                'COMPLETED' => selectedFilter == 'Completed',
                _ => false,
              };
              return SizedBox(
                width: cardW,
                child: _StripStatCard(
                  stat: stat,
                  selected: isSelected,
                  onTap: onStatTap == null ? null : () => onStatTap!(stat),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _StripStatCard extends StatelessWidget {
  const _StripStatCard({
    required this.stat,
    required this.selected,
    this.onTap,
  });

  final CampListStatUi stat;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? CampColors.primary.withValues(alpha: 0.45)
                  : CampColors.border,
              width: selected ? 1.4 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: selected
                    ? CampColors.primary.withValues(alpha: 0.12)
                    : const Color(0xFF1A1A2E).withValues(alpha: 0.04),
                blurRadius: selected ? 12 : 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      stat.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                        height: 1.1,
                        color: selected ? CampColors.primary : CampColors.muted,
                      ),
                    ),
                  ),
                  Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? CampColors.primaryTint : stat.iconBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      stat.icon,
                      size: 13,
                      color: selected ? CampColors.primary : stat.iconColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                stat.value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: selected ? CampColors.primary : CampColors.heading,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                stat.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  height: 1.1,
                  fontWeight: FontWeight.w500,
                  color: CampColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
