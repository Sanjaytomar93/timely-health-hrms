import 'package:flutter/material.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/models/camp_dashboard_ui.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/widgets/camp_hero_banner.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/widgets/camp_date_and_stats_card.dart';

class CampHeroWithStats extends StatelessWidget {
  const CampHeroWithStats({super.key, required this.data});

  final CampDashboardUi data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CampHeroBanner(),
        CampDateAndStatsCard(data: data),
      ],
    );
  }
}

// ── Date Range Filter Card ──────────────────────────────────────────────────
