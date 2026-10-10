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
                  return const ShimmerCardList(scrollable: true);
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
                          compOffCount: state.compOffRequests.records.length,
                          historyCount: state.leaves.length,
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
    required this.compOffCount,
    required this.historyCount,
    required this.onChanged,
  });

  final bool showCompOff;
  final int compOffCount;
  final int historyCount;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
      child: Row(
        children: [
          Expanded(
            child: _SectionTab(
              label: 'Comp-Off',
              subtitle:
                  '$compOffCount ${compOffCount == 1 ? 'request' : 'requests'}',
              icon: Icons.swap_horiz_rounded,
              accent: const Color(0xFF0F9D8A),
              selected: showCompOff,
              onTap: () => onChanged(true),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _SectionTab(
              label: 'Leave History',
              subtitle:
                  '$historyCount ${historyCount == 1 ? 'leave' : 'leaves'}',
              icon: Icons.history_rounded,
              accent: const Color(0xFF6A5AC2),
              selected: !showCompOff,
              onTap: () => onChanged(false),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTab extends StatefulWidget {
  const _SectionTab({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_SectionTab> createState() => _SectionTabState();
}

class _SectionTabState extends State<_SectionTab> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    final accent = widget.accent;

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? accent.withValues(alpha: 0.08) : Colors.white,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: selected ? accent : const Color(0xFFE9E6F2),
              width: selected ? 1.6 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: selected
                    ? accent.withValues(alpha: 0.22)
                    : const Color(0x0D1E1640),
                blurRadius: selected ? 10 : 5,
                offset: Offset(0, selected ? 4 : 2),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(9),
                      gradient: selected
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                accent,
                                Color.lerp(accent, Colors.black, 0.25)!,
                              ],
                            )
                          : null,
                      color: selected ? null : accent.withValues(alpha: 0.10),
                    ),
                    child: Icon(
                      widget.icon,
                      size: 16,
                      color: selected ? Colors.white : accent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: portalText(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: selected
                                ? Color.lerp(accent, Colors.black, 0.35)!
                                : const Color(0xFF31275C),
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          widget.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: portalText(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? accent
                                : PortalColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                top: -4,
                right: -4,
                child: AnimatedScale(
                  scale: selected ? 1 : 0,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutBack,
                  child: Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 9,
                      color: Colors.white,
                    ),
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
      decoration: const BoxDecoration(
        color: PortalColors.surface,
        border: Border(bottom: BorderSide(color: PortalColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/icons/top_bar/ic_top_menu.svg',
            width: 26,
            height: 26,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'My Leaves',
                  style: portalText(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.heading,
                    letterSpacing: 0.1,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Manage your leave applications and requests',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 11,
                    color: PortalColors.muted,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const TopNotificationButton(),
          const SizedBox(width: 14),
          const TopCalendarButton(),
        ],
      ),
    );
  }
}
