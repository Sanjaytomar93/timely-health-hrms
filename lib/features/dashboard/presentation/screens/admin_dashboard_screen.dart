import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/widgets/month_picker.dart';
import 'package:timelay_health/features/auth/data/auth_session.dart';
import 'package:timelay_health/features/dashboard/presentation/models/admin_dashboard_ui.dart';
import 'package:timelay_health/features/dashboard/presentation/models/dashboard_home_ui.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/admin_dashboard_sections.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/dashboard_app_bar.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/greeting_header.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/weekly_bar_chart_card.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late DateTime _month;
  late AdminDashboardUi _ui;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
    _ui = AdminDashboardUi.sample(_month);
  }

  Future<void> _pickMonth() async {
    final picked = await showMonthPicker(context, initial: _month);
    if (picked == null || !mounted) return;
    setState(() {
      _month = DateTime(picked.year, picked.month);
      _ui = AdminDashboardUi.sample(_month);
    });
  }

  Future<void> _refresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 280));
    if (!mounted) return;
    setState(() => _ui = AdminDashboardUi.sample(_month));
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
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
    final label = monthYearLabel(_month);
    final rate = _ui.totalStaff == 0
        ? '0%'
        : '${((_ui.presentNow / _ui.totalStaff) * 100).toStringAsFixed(1)}%';

    return ColoredBox(
      color: PortalColors.background,
      child: Column(
        children: [
          const DashboardAppBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Same order / chrome as employee DashboardScreen
                  SliverToBoxAdapter(
                    child: GreetingHeader(
                      data: DashboardGreetingUi(
                        greeting: greet,
                        firstName: firstName,
                        dateLabel: 'Attendance Dashboard · ${monthYearLabel(DateTime.now())}',
                      ),
                    ),
                  ),
                  SoftSliver(
                    child: AdminLiveBanner(
                      present: _ui.presentNow,
                      absent: _ui.absentNow,
                      lateCount: _ui.lateNow,
                      total: _ui.totalStaff,
                      rateLabel: rate,
                    ),
                  ),
                  SoftSliver(
                    child: AdminMetricsGrid(metrics: _ui.metrics),
                  ),
                  const SoftSliver(child: AdminQuickActions()),
                  SoftSliver(
                    child: AdminTodayAttendanceCard(slices: _ui.todaySlices),
                  ),
                  SoftSliver(
                    child: AdminHeatmapCard(
                      values: _ui.heatmap,
                      month: _month,
                      monthLabel: label,
                      onMonthTap: _pickMonth,
                    ),
                  ),
                  SoftSliver(
                    child: AdminLiveWorkforceCard(
                      totalStaff: _ui.totalStaff,
                      presentNow: _ui.presentNow,
                      lateNow: _ui.lateNow,
                      onLeaveNow: _ui.onLeaveNow,
                      absentNow: _ui.absentNow,
                    ),
                  ),
                  SoftSliver(
                    child: AdminExceptionsCard(items: _ui.exceptions),
                  ),
                  SoftSliver(
                    child: AdminTopPerformersCard(items: _ui.topPerformers),
                  ),
                  SoftSliver(child: AdminStreaksCard(items: _ui.streaks)),
                  SoftSliver(
                    child: AdminDeptPerformanceCard(items: _ui.departments),
                  ),
                  SoftSliver(
                    child: AdminHolidaysCard(
                      month: _month,
                      monthLabel: label,
                    ),
                  ),
                  SoftSliver(child: AdminTrendCard(points: _ui.trend)),
                  SoftSliver(
                    child: AdminPendingLeavesCard(
                      items: _ui.pendingLeaves,
                      onApprove: (i) => _toast('Approved ${i.name}'),
                      onReject: (i) => _toast('Rejected ${i.name}'),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
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
