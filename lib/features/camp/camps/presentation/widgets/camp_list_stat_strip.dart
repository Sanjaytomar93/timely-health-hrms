import 'package:flutter/material.dart';
import 'package:timelay_health/features/camp/camps/presentation/models/camp_list_ui.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/theme/camp_colors.dart';

class CampListStatStrip extends StatelessWidget {
  const CampListStatStrip({super.key, required this.stats});

  final List<CampListStatUi> stats;

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
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(_pad, 6, _pad, 6),
            itemCount: stats.length,
            separatorBuilder: (_, _) => const SizedBox(width: _gap),
            itemBuilder: (context, i) => SizedBox(
              width: cardW,
              child: _StripStatCard(stat: stats[i]),
            ),
          ),
        );
      },
    );
  }
}

class _StripStatCard extends StatelessWidget {
  const _StripStatCard({required this.stat});

  final CampListStatUi stat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CampColors.border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.04),
            blurRadius: 10,
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
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                    height: 1,
                    color: CampColors.muted,
                  ),
                ),
              ),
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: stat.iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(stat.icon, size: 12, color: stat.iconColor),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            stat.value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: CampColors.heading,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            stat.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 9,
              height: 1.1,
              color: CampColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}
