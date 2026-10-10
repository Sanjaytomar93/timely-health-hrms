import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/core/widgets/month_picker.dart';
import 'package:timelay_health/core/widgets/shimmer.dart';
import 'package:timelay_health/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:timelay_health/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:timelay_health/features/dashboard/presentation/models/dashboard_home_ui.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/absent_week_wise_card.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/attendance_banner.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/dashboard_app_bar.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/greeting_header.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/profile_card.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/quick_actions_section.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/recent_activity_card.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/stat_cards_row.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/update_detail_dialog.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/updates_celebrations_card.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/weekly_bar_chart_card.dart';
import 'package:timelay_health/core/routes/app_routes.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, this.onOpenAttendance, this.onOpenLeaves});

  final VoidCallback? onOpenAttendance;
  final VoidCallback? onOpenLeaves;

  @override
  Widget build(BuildContext context) {
    return _DashboardView(
      onOpenAttendance: onOpenAttendance,
      onOpenLeaves: onOpenLeaves,
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView({this.onOpenAttendance, this.onOpenLeaves});

  final VoidCallback? onOpenAttendance;
  final VoidCallback? onOpenLeaves;

  Future<void> _pickMonth(BuildContext context) async {
    final cubit = context.read<DashboardCubit>();
    final picked = await showMonthPicker(context, initial: cubit.month);
    if (picked == null) return;
    await cubit.setMonth(picked);
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: PortalColors.background,
      child: Column(
        children: [
          const DashboardAppBar(),
          Expanded(
            child: BlocBuilder<DashboardCubit, DashboardState>(
              builder: (context, state) {
                final cubit = context.read<DashboardCubit>();
                final ui = state.ui ?? DashboardHomeUi.empty;
                final firstLoad =
                    state is DashboardLoading &&
                    state.ui == DashboardHomeUi.empty;

                if (firstLoad) {
                  return const DashboardShimmer();
                }

                return RefreshIndicator(
                  onRefresh: () =>
                      context.read<DashboardCubit>().load(keepExisting: true),
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      if (state is DashboardFailureState)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
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
                        child: GreetingHeader(data: ui.greeting),
                      ),
                      SliverToBoxAdapter(child: ProfileCard(data: ui.profile)),
                      SliverToBoxAdapter(
                        child: AttendanceBanner(data: ui.attendanceBanner),
                      ),
                      SliverToBoxAdapter(
                        child: StatCardsRow(cards: ui.statCards),
                      ),
                      SliverToBoxAdapter(
                        child: QuickActionsSection(
                          onHistory: onOpenAttendance,
                          onLeaves: onOpenLeaves,
                          onPermission: () =>
                              AppRoutes.push(context, AppRoutes.permissions),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: RepaintBoundary(
                          child: WeeklyBarChartCard(
                            title: 'Late Minutes',
                            titleIcon: Icons.access_time,
                            barColor: PortalColors.orange,
                            barColors: const [
                              Color(0xFFF0A72E),
                              Color(0xFFFF7043),
                              Color(0xFFAB47BC),
                              Color(0xFF42A5F5),
                              Color(0xFF26A69A),
                            ],
                            values: ui.lateMinutes,
                            monthLabel: monthYearLabel(cubit.month),
                            onMonthTap: () => _pickMonth(context),
                            topSpacing: 24,
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: RepaintBoundary(
                          child: AbsentWeekWiseCard(
                            data: ui.absentDays,
                            monthLabel: monthYearLabel(cubit.month),
                            onMonthTap: () => _pickMonth(context),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: RecentActivityCard(items: ui.recentActivity),
                      ),
                      SliverToBoxAdapter(
                        child: UpdatesCelebrationsCard(
                          monthLabel: ui.updatesMonthLabel,
                          items: ui.updates,
                          onDetails: (item) =>
                              showUpdateDetailDialog(context, item: item),
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
