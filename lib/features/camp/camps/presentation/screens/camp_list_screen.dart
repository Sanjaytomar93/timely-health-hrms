import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelay_health/features/camp/camps/presentation/bloc/camps_cubit.dart';
import 'package:timelay_health/features/camp/camps/presentation/bloc/camps_state.dart';
import 'package:timelay_health/features/camp/camps/presentation/models/camp_list_ui.dart';
import 'package:timelay_health/features/camp/camps/presentation/widgets/camp_list_card.dart';
import 'package:timelay_health/features/camp/camps/presentation/widgets/camp_list_filter_chips.dart';
import 'package:timelay_health/features/camp/camps/presentation/widgets/camp_list_search_bar.dart';
import 'package:timelay_health/features/camp/camps/presentation/widgets/camp_list_section_header.dart';
import 'package:timelay_health/features/camp/camps/presentation/widgets/camp_list_stat_strip.dart';
import 'package:timelay_health/features/camp/camps/presentation/widgets/camp_list_top_bar.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/theme/camp_colors.dart';
import 'package:timelay_health/features/camp/shared/camp_shimmer.dart';

class CampListScreen extends StatelessWidget {
  const CampListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CampsCubit()..load(),
      child: const _CampListView(),
    );
  }
}

class _CampListView extends StatefulWidget {
  const _CampListView();

  @override
  State<_CampListView> createState() => _CampListViewState();
}

class _CampListViewState extends State<_CampListView> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: CampColors.background,
      child: Column(
        children: [
          const CampListTopBar(),
          Expanded(
            child: BlocBuilder<CampsCubit, CampsState>(
              builder: (context, state) {
                final loading =
                    state is CampsLoading && state.allCamps.isEmpty;

                if (loading) {
                  return const CampListShimmer();
                }

                final camps = state.camps;
                final today = <CampItemUi>[];
                final completed = <CampItemUi>[];
                final other = <CampItemUi>[];
                for (final c in camps) {
                  switch (c.status) {
                    case CampListStatus.today:
                      today.add(c);
                    case CampListStatus.completed:
                      completed.add(c);
                    default:
                      other.add(c);
                  }
                }

                return RefreshIndicator(
                  onRefresh: () =>
                      context.read<CampsCubit>().load(keepExisting: true),
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: CampListSearchBar(
                          controller: _search,
                          onChanged: (v) =>
                              context.read<CampsCubit>().setSearch(v),
                        ),
                      ),
                      if (state.stats.isNotEmpty)
                        SliverToBoxAdapter(
                          child: CampListStatStrip(
                            stats: state.stats,
                            selectedFilter: state.filter,
                            onStatTap: (stat) => context
                                .read<CampsCubit>()
                                .setFilter(stat.filter),
                          ),
                        ),
                      SliverToBoxAdapter(
                        child: CampListFilterChips(
                          selected: state.filter,
                          onSelected: (v) =>
                              context.read<CampsCubit>().setFilter(v),
                        ),
                      ),
                      if (state is CampsFailureState &&
                          state.allCamps.isEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
                            child: Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                color: CampColors.muted,
                              ),
                            ),
                          ),
                        ),
                      if (today.isNotEmpty) ...[
                        SliverToBoxAdapter(
                          child: CampListSectionHeader(
                            title: 'Active today',
                            count: today.length,
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, i) => CampListCard(camp: today[i]),
                            childCount: today.length,
                          ),
                        ),
                      ],
                      if (completed.isNotEmpty) ...[
                        SliverToBoxAdapter(
                          child: CampListSectionHeader(
                            title: 'Completed',
                            count: completed.length,
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, i) => CampListCard(camp: completed[i]),
                            childCount: completed.length,
                          ),
                        ),
                      ],
                      if (other.isNotEmpty) ...[
                        SliverToBoxAdapter(
                          child: CampListSectionHeader(
                            title: 'More camps',
                            count: other.length,
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, i) => CampListCard(camp: other[i]),
                            childCount: other.length,
                          ),
                        ),
                      ],
                      if (camps.isEmpty && state is! CampsFailureState)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: Center(
                              child: Text(
                                'No camps found',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: CampColors.muted,
                                ),
                              ),
                            ),
                          ),
                        ),
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
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
