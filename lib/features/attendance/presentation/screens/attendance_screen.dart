import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/core/widgets/shimmer.dart';
import 'package:timelay_health/features/attendance/presentation/bloc/attendance_cubit.dart';
import 'package:timelay_health/features/attendance/presentation/bloc/attendance_state.dart';
import 'package:timelay_health/features/attendance/presentation/mappers/attendance_ui_mapper.dart';
import 'package:timelay_health/features/attendance/presentation/widgets/attendance_app_bar.dart';
import 'package:timelay_health/features/attendance/presentation/widgets/attendance_records_section.dart';
import 'package:timelay_health/features/attendance/presentation/widgets/attendance_stats_row.dart';
import 'package:timelay_health/features/attendance/presentation/widgets/attendance_tabs.dart';
import 'package:timelay_health/features/attendance/presentation/widgets/filters_actions_card.dart';
import 'package:timelay_health/features/attendance/presentation/widgets/my_location_tab.dart';
import 'package:timelay_health/features/attendance/presentation/widgets/my_shift_tab.dart';
import 'package:timelay_health/features/attendance/presentation/widgets/ot_available_banner.dart';
import 'package:timelay_health/features/attendance/presentation/widgets/ot_info_box.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/attendance_banner.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key, this.isActive = true});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AttendanceCubit()..load(),
      child: _AttendanceView(isActive: isActive),
    );
  }
}

class _AttendanceView extends StatefulWidget {
  const _AttendanceView({required this.isActive});

  final bool isActive;

  @override
  State<_AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<_AttendanceView> {
  int _tabIndex = 0;
  final Set<int> _openedTabs = {0};

  @override
  void didUpdateWidget(covariant _AttendanceView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive && _tabIndex != 0) {
      setState(() => _tabIndex = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: PortalColors.background,
      child: Column(
        children: [
          const AttendanceAppBar(),
          AttendanceTabs(
            currentIndex: _tabIndex,
            onChanged: (i) => setState(() {
              _openedTabs.add(i);
              _tabIndex = i;
            }),
          ),
          Expanded(
            child: IndexedStack(
              index: _tabIndex,
              children: [
                const _RecordsTab(),
                _openedTabs.contains(1)
                    ? const MyShiftTab()
                    : const SizedBox.shrink(),
                _openedTabs.contains(2)
                    ? const MyLocationTab()
                    : const SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordsTab extends StatelessWidget {
  const _RecordsTab();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AttendanceCubit, AttendanceState>(
      listenWhen: (previous, current) =>
          current is AttendanceFailureState && current.records.isNotEmpty,
      listener: (context, state) {
        if (state is AttendanceFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final records = state.records;
        final stats = state.stats;
        final loading =
            state is AttendanceLoading || state is AttendanceInitial;
        final error = state is AttendanceFailureState ? state.message : null;
        final banner = AttendanceUiMapper.toBanner(
          records: state.allRecords,
          shiftLabel: state.shiftLabel,
        );
        return RefreshIndicator(
          color: PortalColors.purple,
          onRefresh: () =>
              context.read<AttendanceCubit>().load(keepExisting: true),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: AttendanceBanner(data: banner)),
              const SliverToBoxAdapter(child: OtInfoBox()),
              SliverToBoxAdapter(child: AttendanceStatsRow(stats: stats)),
              const SliverToBoxAdapter(child: FiltersActionsCard()),
              const SliverToBoxAdapter(child: OtAvailableBanner()),
              if (loading && state.allRecords.isEmpty)
                const SliverToBoxAdapter(child: ShimmerCardList(itemCount: 4))
              else if (error != null && state.allRecords.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
                    child: Column(
                      children: [
                        Text(
                          error,
                          textAlign: TextAlign.center,
                          style: portalText(
                            fontSize: 12,
                            color: PortalColors.muted,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () =>
                              context.read<AttendanceCubit>().load(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: AttendanceRecordsSection(
                    records: records,
                    selectedOtIds: state.selectedOtIds,
                    onToggleOt: stats.hasOt
                        ? context.read<AttendanceCubit>().toggleOtSelection
                        : null,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
