import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/core/widgets/shimmer.dart';
import 'package:timelay_health/features/leaves/presentation/bloc/leaves_cubit.dart';
import 'package:timelay_health/features/leaves/presentation/bloc/leaves_state.dart';
import 'package:timelay_health/features/leaves/presentation/widgets/apply_leave_sheet.dart';
import 'package:timelay_health/features/leaves/presentation/widgets/leave_balance_grid.dart';
import 'package:timelay_health/features/leaves/presentation/widgets/leave_extra_days_card.dart';
import 'package:timelay_health/features/leaves/presentation/widgets/leave_filters_card.dart';
import 'package:timelay_health/features/leaves/presentation/widgets/leave_history_list.dart';
import 'package:timelay_health/features/leaves/presentation/widgets/comp_off_requests_table.dart';
import 'package:timelay_health/features/leaves/presentation/widgets/leave_stats_row.dart';
import 'package:timelay_health/features/holidays/presentation/widgets/top_calendar_button.dart';
import 'package:timelay_health/features/notifications/presentation/widgets/top_notification_button.dart';
import 'package:timelay_health/features/permissions/presentation/widgets/request_permission_dialog.dart';

class LeavesScreen extends StatelessWidget {
  const LeavesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LeavesCubit()..load(),
      child: const _LeavesView(),
    );
  }
}

class _LeavesView extends StatefulWidget {
  const _LeavesView();

  @override
  State<_LeavesView> createState() => _LeavesViewState();
}

class _LeavesViewState extends State<_LeavesView> {
  final _search = TextEditingController();
  bool _showCompOff = true;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: PortalColors.background,
      child: Column(
        children: [
          const _LeavesAppBar(),
          Expanded(
            child: BlocBuilder<LeavesCubit, LeavesState>(
              builder: (context, state) {
                final loading = state is LeavesLoading && state.leaves.isEmpty;

                if (loading) {
                  return const LeavesShimmer();
                }

                return RefreshIndicator(
                  onRefresh: () =>
                      context.read<LeavesCubit>().load(keepExisting: true),
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      if (state is LeavesFailureState && state.leaves.isEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
                            child: Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: portalText(
                                fontSize: 12,
                                color: PortalColors.muted,
                              ),
                            ),
                          ),
                        ),
                      SliverToBoxAdapter(
                        child: LeaveStatsRow(
                          stats: state.stats,
                          compOffCount: state.compOffRequests.records.length,
                        ),
                      ),
                      const SliverToBoxAdapter(child: _LeaveActions()),
                      SliverToBoxAdapter(
                        child: LeaveBalanceGrid(stats: state.stats),
                      ),
                      SliverToBoxAdapter(
                        child: LeaveExtraDaysCard(
                          stats: state.stats,
                          month: state.selectedMonth,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: LeaveFiltersCard(
                          searchController: _search,
                          onSearchChanged: (v) =>
                              context.read<LeavesCubit>().setSearch(v),
                          selectedDate: state.selectedDate,
                          selectedMonth: state.selectedMonth,
                          onDateChanged: context
                              .read<LeavesCubit>()
                              .setSelectedDate,
                          onMonthChanged: context
                              .read<LeavesCubit>()
                              .setSelectedMonth,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: _LeaveSectionSwitcher(
                          showCompOff: _showCompOff,
                          onChanged: (value) {
                            setState(() => _showCompOff = value);
                          },
                        ),
                      ),
                      if (_showCompOff)
                        SliverToBoxAdapter(
                          child: CompOffRequestsTable(
                            requests: state.compOffRequests,
                          ),
                        )
                      else
                        SliverToBoxAdapter(
                          child: LeaveHistoryList(items: state.leaves),
                        ),
                      const SliverToBoxAdapter(child: SizedBox(height: 28)),
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

class _LeaveSectionSwitcher extends StatelessWidget {
  const _LeaveSectionSwitcher({
    required this.showCompOff,
    required this.onChanged,
  });

  final bool showCompOff;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
      child: Container(
        height: 48,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: PortalColors.border),
          boxShadow: [
            BoxShadow(
              color: PortalColors.brand.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _SegmentChip(
                label: 'Comp Off',
                selected: showCompOff,
                onTap: () => onChanged(true),
                colors: const [Color(0xFF0F9D8A), Color(0xFF18AC96)],
              ),
            ),
            Expanded(
              child: _SegmentChip(
                label: 'Leave History',
                selected: !showCompOff,
                onTap: () => onChanged(false),
                colors: PortalColors.brandGradient,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentChip extends StatelessWidget {
  const _SegmentChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.colors,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    final accent = colors.first;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: selected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: colors,
                )
              : null,
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.28),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: portalText(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            color: selected ? Colors.white : PortalColors.heading,
          ),
        ),
      ),
    );
  }
}

class _LeaveActions extends StatelessWidget {
  const _LeaveActions();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 36,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(11),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF26204A), Color(0xFF4B4285)],
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => showApplyLeaveSheet(context),
                    borderRadius: BorderRadius.circular(11),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add, size: 14, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          'Apply Leave',
                          style: portalText(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 36,
              child: OutlinedButton.icon(
                onPressed: () => showRequestPermissionDialog(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: PortalColors.green,
                  backgroundColor: PortalColors.greenTint,
                  side: const BorderSide(color: Color(0xFFCDEEE0)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                  padding: EdgeInsets.zero,
                ),
                icon: const Icon(Icons.verified_user_outlined, size: 14),
                label: Text(
                  'Permission',
                  style: portalText(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.green,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeavesAppBar extends StatelessWidget {
  const _LeavesAppBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PortalColors.surface,
        border: const Border(bottom: BorderSide(color: PortalColors.border)),
        boxShadow: [
          BoxShadow(
            color: PortalColors.brand.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: PortalColors.brandTint,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              'assets/icons/top_bar/ic_top_menu.svg',
              width: 18,
              height: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'My Leaves',
                  style: portalText(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: PortalColors.heading,
                    letterSpacing: 0.1,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Track balances, requests & history',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 11.5,
                    color: PortalColors.muted,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const TopNotificationButton(),
          const SizedBox(width: 12),
          const TopCalendarButton(),
        ],
      ),
    );
  }
}
