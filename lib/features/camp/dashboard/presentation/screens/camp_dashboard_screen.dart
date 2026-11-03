import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/theme/camp_colors.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/widgets/camp_bmi_card.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/widgets/camp_bp_analysis_card.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/widgets/camp_date_filter_card.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/widgets/camp_distribution_card.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/widgets/camp_hero_with_stats.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/widgets/camp_participation_card.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/widgets/camp_top_bar.dart';
import 'package:timelay_health/features/camp/shared/camp_shimmer.dart';

class CampDashboardScreen extends StatelessWidget {
  const CampDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DashboardCubit()..load(),
      child: const _CampDashboardView(),
    );
  }
}

class _CampDashboardView extends StatefulWidget {
  const _CampDashboardView();

  @override
  State<_CampDashboardView> createState() => _CampDashboardViewState();
}

class _CampDashboardViewState extends State<_CampDashboardView> {
  DateTime? _from;
  DateTime? _to;
  bool _showSugar = false;

  Future<void> _pickDate({required bool isFrom}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: (isFrom ? _from : _to) ?? now,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 1),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isFrom) {
        _from = picked;
      } else {
        _to = picked;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: CampColors.background,
      child: Column(
        children: [
          const CampTopBar(),
          Expanded(
            child: BlocBuilder<DashboardCubit, DashboardState>(
              builder: (context, state) {
                final loading =
                    state is DashboardLoading && state.data.stats.isEmpty;

                if (loading) {
                  return const CampDashboardShimmer();
                }

                final data = state.data;

                return RefreshIndicator(
                  onRefresh: () =>
                      context.read<DashboardCubit>().load(keepExisting: true),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      CampHeroWithStats(data: data),
                      if (state is DashboardFailureState &&
                          data.stats.isEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
                          child: Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              color: CampColors.muted,
                            ),
                          ),
                        ),
                      CampDateFilterCard(
                        from: _from,
                        to: _to,
                        onPickFrom: () => _pickDate(isFrom: true),
                        onPickTo: () => _pickDate(isFrom: false),
                        onReset: () => setState(() {
                          _from = null;
                          _to = null;
                        }),
                      ),
                      if (data.distribution.isNotEmpty)
                        CampDistributionCard(data: data),
                      if (data.participation.isNotEmpty)
                        CampParticipationCard(items: data.participation),
                      if (data.bmi.isNotEmpty) CampBmiCard(items: data.bmi),
                      if (data.bpSlices.isNotEmpty ||
                          data.sugarSlices.isNotEmpty)
                        CampBpAnalysisCard(
                          data: data,
                          showSugar: _showSugar,
                          onToggle: (v) => setState(() => _showSugar = v),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
