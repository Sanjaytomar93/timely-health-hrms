import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/routes/app_routes.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/core/theme/portal_system_ui.dart';
import 'package:timelay_health/core/widgets/portal_safe_area.dart';
import 'package:timelay_health/features/admin/payroll/presentation/models/payroll_overview_ui.dart';
import 'package:timelay_health/features/dashboard/presentation/screens/employee_home_shell.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/employee_bottom_nav.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/home_side_drawer.dart';
import 'package:timelay_health/features/notifications/presentation/widgets/top_notification_button.dart';

class PayrollOverviewScreen extends StatefulWidget {
  const PayrollOverviewScreen({super.key});

  @override
  State<PayrollOverviewScreen> createState() => _PayrollOverviewScreenState();
}

class _PayrollOverviewScreenState extends State<PayrollOverviewScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchCtrl = TextEditingController();

  late PayrollOverviewUi _ui;
  late List<EmployeePayrollRecord> _records;

  String _monthFilter = 'Nov 2026';
  String _deptFilter = 'All Depts';
  String _statusFilter = 'ALL'; // ALL, ACTIVE, INACTIVE

  String get _statusFilterLabel {
    switch (_statusFilter) {
      case 'ACTIVE':
        return 'Active (25)';
      case 'INACTIVE':
        return 'Inactive (40)';
      case 'ALL':
      default:
        return 'All (65)';
    }
  }

  static const departments = <String>[
    'All Depts',
    'Consultant',
    'Nursing',
    'Digital Marketing',
    'Medical',
    'Laboratory Medicine',
    'Marketing',
    'Developer',
    'Sales',
  ];

  static const months = <String>[
    'Nov 2026',
    'Oct 2026',
    'Sep 2026',
    'Aug 2026',
    'Jul 2026',
    'Jun 2026',
  ];

  @override
  void initState() {
    super.initState();
    _ui = PayrollOverviewUi.sample();
    _records = List.from(_ui.records);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<EmployeePayrollRecord> get _filteredRecords {
    final query = _searchCtrl.text.trim().toLowerCase();

    return _records.where((item) {
      if (_statusFilter == 'ACTIVE' && item.status == 'NA') return false;
      if (_statusFilter == 'INACTIVE' && item.status != 'NA') return false;

      if (_deptFilter != 'All Depts' &&
          item.department.toLowerCase() != _deptFilter.toLowerCase()) {
        return false;
      }

      if (query.isNotEmpty) {
        final matchName = item.name.toLowerCase().contains(query);
        final matchCode = item.code.toLowerCase().contains(query);
        final matchRole = item.role.toLowerCase().contains(query);
        final matchDept = item.department.toLowerCase().contains(query);
        if (!matchName && !matchCode && !matchRole && !matchDept) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Future<void> _pickFromSheet({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accent,
    required Color accentTint,
    required List<String> items,
    required String selected,
    required ValueChanged<String> onPick,
  }) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        var query = '';
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            final filtered = items
                .where((e) => e.toLowerCase().contains(query.toLowerCase()))
                .toList();
            return SafeArea(
              child: SizedBox(
                height: MediaQuery.sizeOf(ctx).height * 0.62,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: PortalColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: accentTint,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Icon(icon, size: 20, color: accent),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: portalText(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: PortalColors.heading,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  subtitle,
                                  style: portalText(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: PortalColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      child: Container(
                        height: 42,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: PortalColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: PortalColors.border),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search_rounded,
                                size: 18, color: accent),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                onChanged: (v) => setSheet(() => query = v),
                                style: portalText(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: PortalColors.heading,
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  hintText: 'Search $title...',
                                  hintStyle: portalText(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: PortalColors.muted,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final item = filtered[i];
                          final active = item == selected;
                          return Material(
                            color: active ? accentTint : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              onTap: () => Navigator.of(ctx).pop(item),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: active ? accent : PortalColors.border,
                                    width: active ? 1.3 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: active
                                            ? accent
                                            : PortalColors.background,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      alignment: Alignment.center,
                                      child: Icon(
                                        active
                                            ? Icons.check_rounded
                                            : Icons.circle_outlined,
                                        size: active ? 15 : 12,
                                        color: active
                                            ? Colors.white
                                            : PortalColors.muted,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        item,
                                        style: portalText(
                                          fontSize: 13.5,
                                          fontWeight: active
                                              ? FontWeight.w700
                                              : FontWeight.w600,
                                          color: active
                                              ? accent
                                              : PortalColors.heading,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    if (picked != null) onPick(picked);
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredRecords;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: PortalSystemUi.darkStatusBar,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: const HomeSideDrawer(),
        drawerScrimColor: PortalColors.brand.withValues(alpha: 0.28),
        backgroundColor: const Color(0xFFF8FAFC),
        body: PortalSafeArea(
          bottom: false,
          statusBarColor: PortalColors.brand,
          child: Column(
            children: [
              // --- 1. Top Navbar (Dark Purple Brand Style) ---
              _TopBar(
                onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
              ),

              // --- 2. Scrollable Body Content ---
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
                  children: [
                    // Search Field
                    _PayrollSearchField(
                      controller: _searchCtrl,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 10),

                    // Normal Filters Row (Month, Dept, Status Chips)
                    _PayrollFilterRow(
                      monthLabel: _monthFilter,
                      deptLabel: _deptFilter,
                      statusLabel: _statusFilterLabel,
                      deptActive: _deptFilter != 'All Depts',
                      statusActive: _statusFilter != 'ALL',
                      onMonthTap: () => _pickFromSheet(
                        title: 'Select Month',
                        subtitle: 'Payroll tracking period',
                        icon: Icons.calendar_month_rounded,
                        accent: const Color(0xFF2563EB),
                        accentTint: const Color(0xFFEFF6FF),
                        items: months,
                        selected: _monthFilter,
                        onPick: (val) => setState(() => _monthFilter = val),
                      ),
                      onDeptTap: () => _pickFromSheet(
                        title: 'Departments',
                        subtitle: 'Filter employees by dept',
                        icon: Icons.apartment_rounded,
                        accent: const Color(0xFF7C3AED),
                        accentTint: const Color(0xFFF5F3FF),
                        items: departments,
                        selected: _deptFilter,
                        onPick: (val) => setState(() => _deptFilter = val),
                      ),
                      onStatusTap: () => _pickFromSheet(
                        title: 'Filter Status',
                        subtitle: 'Filter by employee status',
                        icon: Icons.tune_rounded,
                        accent: const Color(0xFF4F46E5),
                        accentTint: const Color(0xFFEEF2FF),
                        items: const [
                          'All (65)',
                          'Active (25)',
                          'Inactive (40)',
                        ],
                        selected: _statusFilterLabel,
                        onPick: (val) => setState(() {
                          if (val.startsWith('Active')) {
                            _statusFilter = 'ACTIVE';
                          } else if (val.startsWith('Inactive')) {
                            _statusFilter = 'INACTIVE';
                          } else {
                            _statusFilter = 'ALL';
                          }
                        }),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 4 Stat Cards in 2x2 Grid
                    _PayrollStatsGrid(stats: _ui.stats),
                    const SizedBox(height: 14),

                    // Payroll Trend Card (6 Months Bar Chart)
                    _PayrollTrendCard(bars: _ui.trendBars),
                    const SizedBox(height: 14),

                    // Payment Status Donut Card
                    const _PaymentStatusCard(),
                    const SizedBox(height: 14),

                    // Payroll Processing Progress
                    const _PayrollProgressCard(),
                    const SizedBox(height: 14),

                    // Earnings Summary Card
                    _EarningsSummaryCard(
                      earnings: _ui.earnings,
                      grossTotal: _ui.grossSalaryTotal,
                    ),
                    const SizedBox(height: 14),

                    // Deductions Summary Card
                    _DeductionsSummaryCard(
                      deductions: _ui.deductions,
                      totalDeductions: _ui.totalDeductions,
                    ),
                    const SizedBox(height: 14),

                    // Attendance Impact Card
                    _AttendanceImpactCard(impact: _ui.impact),
                    const SizedBox(height: 18),

                    // Employee Payroll List Section
                    _EmployeePayrollSection(
                      records: list,
                      totalCount: _records.length,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: EmployeeBottomNav(
          currentIndex: 2,
          onTap: (i) => EmployeeHomeShell.goToTab(context, i),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 1. Dark Top Bar (Original Dark Purple Brand Style)
// ---------------------------------------------------------------------------
class _TopBar extends StatelessWidget {
  const _TopBar({required this.onMenuTap});

  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PortalColors.brand,
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: onMenuTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 34,
              height: 34,
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
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'Payroll Overview',
                      style: portalText(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF065F46),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF10B981),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: Color(0xFF34D399),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Live',
                            style: portalText(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFA7F3D0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Monthly Salary & Payout Tracking',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 11.5,
                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const TopNotificationButton(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. Search Field
// ---------------------------------------------------------------------------
class _PayrollSearchField extends StatelessWidget {
  const _PayrollSearchField({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PortalColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 20, color: PortalColors.muted),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textAlign: TextAlign.start,
              style: portalText(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: PortalColors.heading,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: 'Search employee, ID, dept...',
                hintStyle: portalText(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: PortalColors.muted,
                ),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                controller.clear();
                onChanged('');
              },
              behavior: HitTestBehavior.opaque,
              child: const Icon(
                Icons.close_rounded,
                size: 18,
                color: PortalColors.muted,
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. Normal Filter Row (Month, Dept, Status Chips - Attendance Summary Style)
// ---------------------------------------------------------------------------
class _PayrollFilterRow extends StatelessWidget {
  const _PayrollFilterRow({
    required this.monthLabel,
    required this.deptLabel,
    required this.statusLabel,
    required this.deptActive,
    required this.statusActive,
    required this.onMonthTap,
    required this.onDeptTap,
    required this.onStatusTap,
  });

  final String monthLabel;
  final String deptLabel;
  final String statusLabel;
  final bool deptActive;
  final bool statusActive;
  final VoidCallback onMonthTap;
  final VoidCallback onDeptTap;
  final VoidCallback onStatusTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Chip(
            icon: Icons.calendar_today_outlined,
            label: monthLabel,
            active: true,
            onTap: onMonthTap,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _Chip(
            icon: Icons.apartment_rounded,
            label: deptLabel,
            active: deptActive,
            onTap: onDeptTap,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _Chip(
            icon: Icons.tune_rounded,
            label: statusLabel,
            active: statusActive,
            onTap: onStatusTap,
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? PortalColors.brandTint : Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active
                  ? PortalColors.brand.withValues(alpha: 0.28)
                  : PortalColors.border,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 13,
                color: active ? PortalColors.brand : PortalColors.muted,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: active ? PortalColors.brand : PortalColors.heading,
                  ),
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.arrow_drop_down_rounded,
                size: 16,
                color: active ? PortalColors.brand : PortalColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 4. 2x2 Stat Cards Grid
// ---------------------------------------------------------------------------
class _PayrollStatsGrid extends StatelessWidget {
  const _PayrollStatsGrid({required this.stats});

  final PayrollStatCardData stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'TOTAL PAYROLL',
                value: stats.totalPayroll,
                subtitle: stats.totalPayrollSubtitle,
                icon: Icons.trending_up_rounded,
                iconColor: const Color(0xFF2563EB),
                iconBg: const Color(0xFFEFF6FF),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                title: 'PAID AMOUNT',
                value: stats.paidAmount,
                subtitle: stats.paidSubtitle,
                icon: Icons.check_circle_outline_rounded,
                iconColor: const Color(0xFF059669),
                iconBg: const Color(0xFFECFDF5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'PENDING AMOUNT',
                value: stats.pendingAmount,
                subtitle: stats.pendingSubtitle,
                icon: Icons.access_time_rounded,
                iconColor: const Color(0xFFD97706),
                iconBg: const Color(0xFFFEF3C7),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                title: 'TOTAL EMPLOYEES',
                value: '${stats.totalEmployees}',
                subtitle: stats.employeesSubtitle,
                icon: Icons.people_outline_rounded,
                iconColor: const Color(0xFF7C3AED),
                iconBg: const Color(0xFFF5F3FF),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PortalColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1.5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF64748B),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 14, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: portalText(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: PortalColors.heading,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 5. Payroll Trend Card (Bar Chart)
// ---------------------------------------------------------------------------
class _PayrollTrendCard extends StatelessWidget {
  const _PayrollTrendCard({required this.bars});

  final List<PayrollTrendBar> bars;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payroll Trend',
                      style: portalText(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: PortalColors.heading,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Last 6 Months',
                      style: portalText(
                        fontSize: 11,
                        color: PortalColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: PortalColors.border),
                ),
                child: Text(
                  '6 Months ▾',
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: PortalColors.secondaryText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Custom Rendered Bar Chart
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Y-axis labels
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final lbl in ['20M', '15M', '10M', '5M', '0'])
                      Text(
                        lbl,
                        style: portalText(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (final b in bars)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              width: 22,
                              height: (b.grossMillion / 20.0) * 95,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: b.isHighlighted
                                    ? const Color(0xFF1E1B4B)
                                    : const Color(0xFF6366F1),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              b.month,
                              style: portalText(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: PortalColors.border),
          const SizedBox(height: 10),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                'Gross Payroll',
                style: portalText(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                'Net Payout',
                style: portalText(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 6. Payment Status Donut Card
// ---------------------------------------------------------------------------
class _PaymentStatusCard extends StatelessWidget {
  const _PaymentStatusCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment Status',
                style: portalText(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: PortalColors.heading,
                ),
              ),
              Text(
                'Current month',
                style: portalText(
                  fontSize: 11,
                  color: PortalColors.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              // Circular Donut
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 74,
                      height: 74,
                      child: CircularProgressIndicator(
                        value: 0.0,
                        strokeWidth: 9,
                        backgroundColor: const Color(0xFFF59E0B),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF10B981),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '0%',
                          style: portalText(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: PortalColors.heading,
                          ),
                        ),
                        Text(
                          'PAID',
                          style: portalText(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),

              // Legend and values
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          'Paid: 0 (0%)',
                          style: portalText(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: PortalColors.heading,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Text(
                        '₹0 Disbursed',
                        style: portalText(
                          fontSize: 11,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF59E0B),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          'Pending: 65 (100%)',
                          style: portalText(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: PortalColors.heading,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Text(
                        '₹2,18,068 Net Due',
                        style: portalText(
                          fontSize: 11,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 7. Payroll Processing Progress Card
// ---------------------------------------------------------------------------
class _PayrollProgressCard extends StatelessWidget {
  const _PayrollProgressCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.change_history_rounded,
                  size: 16, color: Color(0xFFF59E0B)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Payroll Processing Progress',
                  style: portalText(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: PortalColors.heading,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Step 2 of 4',
                  style: portalText(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFB45309),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Central Progress Ring
          Center(
            child: SizedBox(
              width: 70,
              height: 70,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const SizedBox(
                    width: 66,
                    height: 66,
                    child: CircularProgressIndicator(
                      value: 0.0,
                      strokeWidth: 6,
                      backgroundColor: Color(0xFFF1F5F9),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFFF59E0B),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '0%',
                        style: portalText(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: PortalColors.heading,
                        ),
                      ),
                      Text(
                        'COMPLETED',
                        style: portalText(
                          fontSize: 7.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 4-step row
          Row(
            children: [
              Expanded(
                child: _StepItem(
                  title: 'Attendance',
                  isDone: true,
                ),
              ),
              Expanded(
                child: _StepItem(
                  title: 'Calculations',
                  isDone: true,
                ),
              ),
              Expanded(
                child: _StepItem(
                  title: 'Deductions',
                  isDone: true,
                ),
              ),
              Expanded(
                child: _StepItem(
                  title: 'Approval',
                  isDone: false,
                  stepNumber: 4,
                  isActive: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  const _StepItem({
    required this.title,
    this.isDone = false,
    this.isActive = false,
    this.stepNumber,
  });

  final String title;
  final bool isDone;
  final bool isActive;
  final int? stepNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFFFEF3C7).withValues(alpha: 0.4)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isActive ? const Color(0xFFF59E0B) : const Color(0xFFE2E8F0),
          width: isActive ? 1.2 : 0.8,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: isDone
                  ? const Color(0xFF10B981)
                  : (isActive ? const Color(0xFFF59E0B) : Colors.grey),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: isDone
                ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
                : Text(
                    '${stepNumber ?? 1}',
                    style: portalText(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
              color: isActive ? const Color(0xFFB45309) : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 8. Earnings Summary Card
// ---------------------------------------------------------------------------
class _EarningsSummaryCard extends StatelessWidget {
  const _EarningsSummaryCard({
    required this.earnings,
    required this.grossTotal,
  });

  final List<PayrollLineItem> earnings;
  final String grossTotal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💰', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                'EARNINGS SUMMARY',
                style: portalText(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: PortalColors.heading,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final item in earnings) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.title,
                    style: portalText(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  Text(
                    item.amount,
                    style: portalText(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: item.isHighlight
                          ? const Color(0xFF059669)
                          : PortalColors.heading,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
          ],
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Gross Salary',
                  style: portalText(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E3A8A),
                  ),
                ),
                Text(
                  grossTotal,
                  style: portalText(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 9. Deductions Summary Card
// ---------------------------------------------------------------------------
class _DeductionsSummaryCard extends StatelessWidget {
  const _DeductionsSummaryCard({
    required this.deductions,
    required this.totalDeductions,
  });

  final List<PayrollLineItem> deductions;
  final String totalDeductions;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'DEDUCTIONS SUMMARY',
                style: portalText(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: PortalColors.heading,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final item in deductions) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.title,
                    style: portalText(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  Text(
                    item.amount,
                    style: portalText(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: item.isDeduction
                          ? const Color(0xFFDC2626)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
          ],
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Deductions',
                  style: portalText(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF991B1B),
                  ),
                ),
                Text(
                  totalDeductions,
                  style: portalText(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFDC2626),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 10. Attendance Impact Card
// ---------------------------------------------------------------------------
class _AttendanceImpactCard extends StatelessWidget {
  const _AttendanceImpactCard({required this.impact});

  final AttendanceImpactSummary impact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.wifi_tethering_rounded,
                  size: 16, color: Color(0xFFEF4444)),
              const SizedBox(width: 8),
              Text(
                'ATTENDANCE IMPACT',
                style: portalText(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: PortalColors.heading,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ImpactCell(
                  label: 'Present Days',
                  value: impact.presentDays,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ImpactCell(
                  label: 'Half Days',
                  value: impact.halfDays,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _ImpactCell(
                  label: 'Weekoffs',
                  value: impact.weekoffs,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ImpactCell(
                  label: 'Comp-offs',
                  value: impact.compOffs,
                  valueColor: const Color(0xFF059669),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _ImpactCell(
                  label: 'Overtime Hours',
                  value: impact.overtimeHours,
                  valueColor: const Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ImpactCell(
                  label: 'Active Processed',
                  value: impact.activeStaff,
                  valueColor: const Color(0xFF7C3AED),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImpactCell extends StatelessWidget {
  const _ImpactCell({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: portalText(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: portalText(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: valueColor ?? PortalColors.heading,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 11. Employee Payroll List Section
// ---------------------------------------------------------------------------
class _EmployeePayrollSection extends StatelessWidget {
  const _EmployeePayrollSection({
    required this.records,
    required this.totalCount,
  });

  final List<EmployeePayrollRecord> records;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'EMPLOYEE PAYROLL LIST',
              style: portalText(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF475569),
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$totalCount Records',
                style: portalText(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF475569),
                ),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => AppRoutes.push(context, AppRoutes.employeePayroll),
              behavior: HitTestBehavior.opaque,
              child: Text(
                'Full Records',
                style: portalText(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2563EB),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (final item in records) ...[
          _EmployeePayrollCard(item: item),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _EmployeePayrollCard extends StatelessWidget {
  const _EmployeePayrollCard({required this.item});

  final EmployeePayrollRecord item;

  @override
  Widget build(BuildContext context) {
    final isPending = item.status == 'PENDING';
    final isNA = item.status == 'NA';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPending
              ? const Color(0xFFFDE68A)
              : const Color(0xFFE2E8F0),
          width: isPending ? 1.0 : 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1.5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Row 1: Avatar, Name, Code, Role, Status Pill
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Color(0xFF1E1B4B),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  item.initials,
                  style: portalText(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: portalText(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: PortalColors.heading,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.code,
                            style: portalText(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.role,
                      style: portalText(
                        fontSize: 11,
                        color: PortalColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isPending
                      ? const Color(0xFFFEF3C7)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.status,
                  style: portalText(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isPending
                        ? const Color(0xFFB45309)
                        : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Row 2: Attendance metrics (Present, Half, OT)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Present: ',
                      style: portalText(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      item.presentDays,
                      style: portalText(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
                Container(width: 1, height: 12, color: const Color(0xFFE2E8F0)),
                Row(
                  children: [
                    Text(
                      'Half: ',
                      style: portalText(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      item.halfDays,
                      style: portalText(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: PortalColors.heading,
                      ),
                    ),
                  ],
                ),
                Container(width: 1, height: 12, color: const Color(0xFFE2E8F0)),
                Row(
                  children: [
                    Text(
                      'OT: ',
                      style: portalText(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      item.otHours,
                      style: portalText(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Row 3: Basic / LOP Ded & NET SALARY
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Basic / LOP Ded',
                    style: portalText(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 1),
                  RichText(
                    text: TextSpan(
                      text: '${item.basicText} | ',
                      style: portalText(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: PortalColors.heading,
                      ),
                      children: [
                        TextSpan(
                          text: '(${item.lopDedText})',
                          style: portalText(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFDC2626),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'NET SALARY',
                    style: portalText(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF94A3B8),
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    item.netSalary,
                    style: portalText(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: isNA ? const Color(0xFF94A3B8) : PortalColors.heading,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
