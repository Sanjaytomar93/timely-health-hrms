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
import 'package:timelay_health/features/dashboard/presentation/widgets/dashboard_card.dart';

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
        if (loading && state.allRecords.isEmpty) {
          return const AttendanceShimmer();
        }

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
              SliverToBoxAdapter(child: AttendanceStatsRow(stats: stats)),
              const SliverToBoxAdapter(child: OtInfoBox()),
              const SliverToBoxAdapter(child: FiltersActionsCard()),
              const SliverToBoxAdapter(child: OtAvailableBanner()),
              if (error != null && state.allRecords.isEmpty)
                SliverToBoxAdapter(
                  child: DashboardCard(
                    topSpacing: 22,
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                    child: Column(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: const BoxDecoration(
                            color: PortalColors.redTint,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.cloud_off_rounded,
                            size: 26,
                            color: PortalColors.red,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          error,
                          textAlign: TextAlign.center,
                          style: portalText(
                            fontSize: 12,
                            color: PortalColors.muted,
                            height: 16 / 12,
                          ),
                        ),
                        const SizedBox(height: 14),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: PortalColors.brand,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () =>
                              context.read<AttendanceCubit>().load(),
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                AttendanceRecordsSection(
                  records: records,
                  selectedOtIds: state.selectedOtIds,
                  onToggleOt: stats.hasOt
                      ? context.read<AttendanceCubit>().toggleOtSelection
                      : null,
                ),
            ],
          ),
        );
      },
    );
  }
}
