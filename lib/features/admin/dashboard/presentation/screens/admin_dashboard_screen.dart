import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelay_health/core/routes/app_routes.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/core/widgets/month_picker.dart';
import 'package:timelay_health/core/widgets/shimmer.dart';
import 'package:timelay_health/features/auth/data/auth_session.dart';
import 'package:timelay_health/features/admin/dashboard/presentation/bloc/admin_dashboard_cubit.dart';
import 'package:timelay_health/features/admin/dashboard/presentation/bloc/admin_dashboard_state.dart';
import 'package:timelay_health/features/admin/dashboard/presentation/models/admin_dashboard_ui.dart';
import 'package:timelay_health/features/admin/dashboard/presentation/widgets/admin_dashboard_sections.dart';
import 'package:timelay_health/features/admin/leaves/domain/failures/admin_leave_failure.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/dashboard_app_bar.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/weekly_bar_chart_card.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminDashboardCubit()..load(),
      child: const _AdminDashboardView(),
    );
  }
}

class _AdminDashboardView extends StatelessWidget {
  const _AdminDashboardView();

  Future<void> _pickMonth(BuildContext context) async {
    final cubit = context.read<AdminDashboardCubit>();
    final picked = await showMonthPicker(context, initial: cubit.month);
    if (picked == null || !context.mounted) return;
    await cubit.setMonth(picked);
  }

  void _toast(BuildContext context, String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? const Color(0xFFDC2626) : null,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _go(BuildContext context, String route) {
    Navigator.of(context).pushNamed(route);
  }

  Future<void> _updateLeave(
    BuildContext context,
    AdminLeaveRequestItem item, {
    required String status,
  }) async {
    final cubit = context.read<AdminDashboardCubit>();
    try {
      await cubit.updateLeaveStatus(id: item.id, status: status);
      if (!context.mounted) return;
      final label = status == 'approved' ? 'Approved' : 'Rejected';
      _toast(context, '$label ${item.name}');
    } on AdminLeaveFailure catch (e) {
      if (!context.mounted) return;
      _toast(context, e.message, isError: true);
    } catch (_) {
      if (!context.mounted) return;
      _toast(context, 'Failed to update leave. Please try again.', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final emp = AuthSession.currentEmployee;
    final firstName = (emp?.firstName?.trim().isNotEmpty ?? false)
        ? emp!.firstName!.trim()
        : (emp?.displayName.split(RegExp(r'\s+')).first ?? 'Admin');
    final hour = DateTime.now().hour;
    final greet = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';
    final now = DateTime.now();
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final weekday = days[(now.weekday - 1) % 7];
    final monthName = months[(now.month - 1) % 12];
    final dateFormatted = '$weekday, $monthName ${now.day}, ${now.year}';

    return ColoredBox(
      color: PortalColors.background,
      child: Column(
        children: [
          const DashboardAppBar(),
          Expanded(
            child: BlocConsumer<AdminDashboardCubit, AdminDashboardState>(
              listener: (context, state) {
                if (state is AdminDashboardFailureState &&
                    state.ui == AdminDashboardUi.empty) {
                  _toast(context, state.message);
                }
              },
              builder: (context, state) {
                final ui = state.ui;
                final month = state.month;
                final label = monthYearLabel(month);
                final loading = state is AdminDashboardLoading &&
                    ui == AdminDashboardUi.empty;

                return RefreshIndicator(
                  onRefresh: () => context.read<AdminDashboardCubit>().load(
                        keepExisting: true,
                      ),
                  child: loading
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [AdminDashboardShimmer()],
                        )
                      : CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            SoftSliver(
                              child: _AdminGreetingHeader(
                                greeting: greet,
                                firstName: firstName,
                                dateLabel: dateFormatted,
                              ),
                            ),
                            SoftSliver(
                              child: _FilterRow(
                                monthLabel: label,
                                onPickMonth: () => _pickMonth(context),
                                onPickLocation: () => _go(
                                  context,
                                  AppRoutes.locationManagement,
                                ),
                              ),
                            ),
                            SoftSliver(
                              child: AdminTotalStaffCard(
                                totalStaff: ui.totalStaff,
                                onTap: () =>
                                    _go(context, AppRoutes.employeeList),
                              ),
                            ),
                            SoftSliver(
                              child: AdminStatCardsGrid(
                                metrics: ui.metrics,
                                onPresentTap: () =>
                                    _go(context, AppRoutes.todayAttendance),
                                onAbsentTap: () =>
                                    _go(context, AppRoutes.absentToday),
                                onLateTap: () =>
                                    _go(context, AppRoutes.lateToday),
                                onRateTap: () =>
                                    _go(context, AppRoutes.attendanceSummary),
                              ),
                            ),
                            SoftSliver(
                              child: AdminTodayAttendanceCard(
                                slices: ui.todaySlices,
                                overallRate: ui.attendanceRate,
                                onMenuTap: () =>
                                    _go(context, AppRoutes.attendanceSummary),
                              ),
                            ),
                            SoftSliver(
                              child: AdminHeatmapCard(
                                values: ui.heatmap,
                                month: month,
                                monthLabel: label,
                                onMonthTap: () => _pickMonth(context),
                                onMenuTap: () =>
                                    _go(context, AppRoutes.attendanceSummary),
                              ),
                            ),
                            SoftSliver(
                              child: AdminLiveWorkforceCard(
                                totalStaff: ui.totalStaff,
                                presentNow: ui.presentNow,
                                lateNow: ui.lateNow,
                                onLeaveNow: ui.onLeaveNow,
                                absentNow: ui.absentNow,
                                onViewAll: () =>
                                    _go(context, AppRoutes.todayAttendance),
                              ),
                            ),
                            SoftSliver(
                              child: AdminExceptionsCard(
                                items: ui.exceptions,
                                onViewAll: () =>
                                    _go(context, AppRoutes.attendanceSummary),
                              ),
                            ),
                            SoftSliver(
                              child: AdminPerformersAndStreaksCard(
                                topPerformers: ui.topPerformers,
                                streaks: ui.streaks,
                              ),
                            ),
                            SoftSliver(
                              child: AdminDeptPerformanceCard(
                                items: ui.departments,
                                onViewAll: () =>
                                    _go(context, AppRoutes.employeeList),
                              ),
                            ),
                            SoftSliver(
                              child: AdminTrendCard(
                                points: ui.trend,
                                year: month.year,
                              ),
                            ),
                            SoftSliver(
                              child: AdminHolidaysCard(
                                month: month,
                                monthLabel: label,
                                holidayDots: ui.holidayDots,
                                onViewCalendar: () =>
                                    _go(context, AppRoutes.holidayCalendar),
                              ),
                            ),
                            SoftSliver(
                              child: AdminPendingLeavesCard(
                                items: ui.pendingLeaves,
                                onApprove: (i) => _updateLeave(
                                  context,
                                  i,
                                  status: 'approved',
                                ),
                                onReject: (i) => _updateLeave(
                                  context,
                                  i,
                                  status: 'rejected',
                                ),
                                onViewAll: () =>
                                    _go(context, AppRoutes.leaveList),
                              ),
                            ),
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 24),
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

class _AdminGreetingHeader extends StatelessWidget {
  const _AdminGreetingHeader({
    required this.greeting,
    required this.firstName,
    required this.dateLabel,
  });

  final String greeting;
  final String firstName;
  final String dateLabel;

  static const double _leadingWidth = 22.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(
                width: _leadingWidth,
                child: Center(
                  child: Text('👋', style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: portalText(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: PortalColors.heading,
                    ),
                    children: [
                      TextSpan(text: '$greeting, '),
                      TextSpan(
                        text: firstName,
                        style: const TextStyle(color: Color(0xFF059669)),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const SizedBox(
                width: _leadingWidth,
                child: Center(
                  child: Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: PortalColors.muted,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                dateLabel,
                style: portalText(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: PortalColors.muted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.monthLabel,
    required this.onPickMonth,
    required this.onPickLocation,
  });

  final String monthLabel;
  final VoidCallback onPickMonth;
  final VoidCallback onPickLocation;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onPickMonth,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: PortalColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: Color(0xFF2563EB),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        monthLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: portalText(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: PortalColors.heading,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: PortalColors.muted,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: InkWell(
              onTap: onPickLocation,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: PortalColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 15,
                      color: Color(0xFF059669),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Locations',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: portalText(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: PortalColors.heading,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: PortalColors.muted,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SoftSliver extends StatelessWidget {
  const SoftSliver({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(child: RepaintBoundary(child: child));
  }
}
