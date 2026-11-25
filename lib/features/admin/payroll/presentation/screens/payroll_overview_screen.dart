import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/core/theme/portal_system_ui.dart';
import 'package:timelay_health/core/widgets/portal_safe_area.dart';
import 'package:timelay_health/core/widgets/shimmer.dart';
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
  bool _ready = false;

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
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() => _ready = true);
    });
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

  Future<void> _pickMonthSheet() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Month',
                          style: portalText(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Payroll tracking period',
                          style: portalText(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.6,
                  ),
                  itemCount: months.length,
                  itemBuilder: (ctx, i) {
                    final month = months[i];
                    final isSelected = month == _monthFilter;
                    return InkWell(
                      onTap: () => Navigator.pop(ctx, month),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? PortalColors.brandTint
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? PortalColors.brand
                                : const Color(0xFFE2E8F0),
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 15,
                              color: isSelected
                                  ? PortalColors.brand
                                  : const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                month,
                                style: portalText(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  color: isSelected
                                      ? PortalColors.brand
                                      : const Color(0xFF1E293B),
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle_rounded,
                                size: 16,
                                color: PortalColors.brand,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
    if (picked != null) {
      setState(() => _monthFilter = picked);
    }
  }

  Future<void> _pickDepartmentSheet() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        var query = '';
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            final filtered = departments
                .where((e) => e.toLowerCase().contains(query.toLowerCase()))
                .toList();

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(ctx).height * 0.72,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select Department',
                              style: portalText(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Filter employees by unit',
                              style: portalText(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search_rounded,
                            size: 18,
                            color: Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              onChanged: (v) => setSheet(() => query = v),
                              style: portalText(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF0F172A),
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search department...',
                                hintStyle: portalText(
                                  fontSize: 13,
                                  color: const Color(0xFF94A3B8),
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (ctx, i) {
                          final dept = filtered[i];
                          final isSelected = dept == _deptFilter;
                          final isAll = dept == 'All Depts';

                          return InkWell(
                            onTap: () => Navigator.pop(ctx, dept),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 11,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? PortalColors.brandTint
                                    : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? PortalColors.brand
                                      : const Color(0xFFE2E8F0),
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? PortalColors.brand
                                          : const Color(0xFFE2E8F0),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      isAll
                                          ? Icons.apps_rounded
                                          : Icons.apartment_rounded,
                                      size: 16,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      dept,
                                      style: portalText(
                                        fontSize: 13.5,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w600,
                                        color: isSelected
                                            ? PortalColors.brand
                                            : const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      size: 18,
                                      color: PortalColors.brand,
                                    )
                                else
                                  const Icon(
                                    Icons.radio_button_unchecked_rounded,
                                    size: 18,
                                    color: Color(0xFFCBD5E1),
                                  ),
                              ],
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
  if (picked != null) {
    setState(() => _deptFilter = picked);
  }
}

  Future<void> _pickStatusSheet() async {
    final options = [
      {
        'id': 'ALL',
        'label': 'All Employees',
        'count': '65 Staff Records',
        'icon': Icons.group_outlined,
        'color': const Color(0xFF6366F1),
        'tint': const Color(0xFFEEF2FF),
      },
      {
        'id': 'ACTIVE',
        'label': 'Active Employees',
        'count': '25 Active Staff',
        'icon': Icons.check_circle_outline_rounded,
        'color': const Color(0xFF10B981),
        'tint': const Color(0xFFECFDF5),
      },
      {
        'id': 'INACTIVE',
        'label': 'Inactive / On-Hold',
        'count': '40 Clearance Req.',
        'icon': Icons.pause_circle_outline_rounded,
        'color': const Color(0xFFEF4444),
        'tint': const Color(0xFFFEF2F2),
      },
    ];

    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Filter Status',
                          style: portalText(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Select status category to view',
                          style: portalText(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                for (final opt in options) ...[
                  Builder(
                    builder: (_) {
                      final id = opt['id'] as String;
                      final isSelected = _statusFilter == id;
                      final color = opt['color'] as Color;
                      final tint = opt['tint'] as Color;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          onTap: () => Navigator.pop(ctx, id),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? tint.withValues(alpha: 0.6)
                                  : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? color
                                    : const Color(0xFFE2E8F0),
                                width: isSelected ? 1.5 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: tint,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    opt['icon'] as IconData,
                                    size: 18,
                                    color: color,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        opt['label'] as String,
                                        style: portalText(
                                          fontSize: 13.5,
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w600,
                                          color: const Color(0xFF0F172A),
                                        ),
                                      ),
                                      const SizedBox(height: 1),
                                      Text(
                                        opt['count'] as String,
                                        style: portalText(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle_rounded,
                                    size: 20,
                                    color: color,
                                  )
                                else
                                  const Icon(
                                    Icons.radio_button_unchecked_rounded,
                                    size: 20,
                                    color: Color(0xFFCBD5E1),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
    if (picked != null) {
      setState(() => _statusFilter = picked);
    }
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
              _TopBar(
                onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
              ),

              Expanded(
                child: !_ready
                    ? const AdminListShimmer(statCount: 4, cardCount: 5)
                    : ListView(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
                  children: [
                    _PayrollSearchField(
                      controller: _searchCtrl,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 10),

                    _PayrollFilterRow(
                      monthLabel: _monthFilter,
                      deptLabel: _deptFilter,
                      statusLabel: _statusFilterLabel,
                      deptActive: _deptFilter != 'All Depts',
                      statusActive: _statusFilter != 'ALL',
                      onMonthTap: _pickMonthSheet,
                      onDeptTap: _pickDepartmentSheet,
                      onStatusTap: _pickStatusSheet,
                      onClearDept: () => setState(() => _deptFilter = 'All Depts'),
                      onClearStatus: () => setState(() => _statusFilter = 'ALL'),
                      onClearAll: () => setState(() {
                        _deptFilter = 'All Depts';
                        _statusFilter = 'ALL';
                      }),
                    ),
                    const SizedBox(height: 12),

                    const _PayrollStatsGrid(),
                    const SizedBox(height: 14),

                    _PayrollAnalyticsCard(
                      selectedMonth: _monthFilter,
                      onMonthTap: _pickMonthSheet,
                    ),
                    const SizedBox(height: 18),

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
          currentIndex: 3,
          onTap: (i) => EmployeeHomeShell.goToTab(context, i),
        ),
      ),
    );
  }
}

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
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF34D399),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x6634D399),
                            blurRadius: 4,
                            spreadRadius: 1,
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
    this.onClearDept,
    this.onClearStatus,
    this.onClearAll,
  });

  final String monthLabel;
  final String deptLabel;
  final String statusLabel;
  final bool deptActive;
  final bool statusActive;
  final VoidCallback onMonthTap;
  final VoidCallback onDeptTap;
  final VoidCallback onStatusTap;
  final VoidCallback? onClearDept;
  final VoidCallback? onClearStatus;
  final VoidCallback? onClearAll;

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
            onClear: deptActive ? onClearDept : null,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _Chip(
            icon: Icons.tune_rounded,
            label: statusLabel,
            active: statusActive,
            onTap: onStatusTap,
            onClear: statusActive ? onClearStatus : null,
          ),
        ),
        if (deptActive || statusActive) ...[
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onClearAll,
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: Color(0xFFDC2626),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    'Clear',
                    style: portalText(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFDC2626),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
    this.onClear,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final VoidCallback? onClear;

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
              if (onClear != null)
                GestureDetector(
                  onTap: onClear,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    child: Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: active ? PortalColors.brand : PortalColors.muted,
                    ),
                  ),
                )
              else
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

class _PayrollStatsGrid extends StatelessWidget {
  const _PayrollStatsGrid();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: const [
            Expanded(
              child: _StatCard(
                title: 'TOTAL EMPLOYEES',
                value: '26',
                badgeText: 'Active',
                badgeBg: Color(0xFFDCFCE7),
                badgeColor: Color(0xFF15803D),
                subtitle: 'All 65 • Active 26',
                icon: Icons.group_outlined,
                iconColor: Color(0xFF7C3AED),
                iconBg: Color(0xFFF5F3FF),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _StatCard(
                title: 'SALARY PAID',
                value: '0',
                badgeText: '0.0%',
                badgeBg: Color(0xFFDCFCE7),
                badgeColor: Color(0xFF16A34A),
                subtitle: '0 records cleared',
                icon: Icons.check_rounded,
                iconColor: Color(0xFF16A34A),
                iconBg: Color(0xFFDCFCE7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        Row(
          children: const [
            Expanded(
              child: _StatCard(
                title: 'SALARY PENDING',
                value: '0',
                badgeText: '0.0%',
                badgeBg: Color(0xFFFEF3C7),
                badgeColor: Color(0xFFD97706),
                subtitle: 'Awaiting release batch',
                icon: Icons.access_time_rounded,
                iconColor: Color(0xFFD97706),
                iconBg: Color(0xFFFEF3C7),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _StatCard(
                title: 'ON HOLD / INACTIVE',
                value: '6',
                badgeText: '23.1%',
                badgeBg: Color(0xFFDBEAFE),
                badgeColor: Color(0xFF2563EB),
                subtitle: 'Clearance verification req.',
                icon: Icons.pause_circle_outline_rounded,
                iconColor: Color(0xFF2563EB),
                iconBg: Color(0xFFDBEAFE),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        Row(
          children: const [
            Expanded(
              child: _StatCard(
                title: 'WITH DEDUCTIONS',
                value: '20',
                badgeText: '76.9%',
                badgeBg: Color(0xFFFEE2E2),
                badgeColor: Color(0xFFDC2626),
                subtitle: 'LOP & deductions',
                icon: Icons.warning_amber_rounded,
                iconColor: Color(0xFFDC2626),
                iconBg: Color(0xFFFEE2E2),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _StatCard(
                title: 'GROSS PAYROLL',
                value: '₹2,12,208',
                subtitle: '6 Active Depts',
                icon: Icons.payments_outlined,
                iconColor: Color(0xFF059669),
                iconBg: Color(0xFFECFDF5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        Row(
          children: const [
            Expanded(
              child: _StatCard(
                title: 'NET DISBURSED',
                value: '₹0',
                subtitle: 'Pending release',
                icon: Icons.credit_card_rounded,
                iconColor: Color(0xFF6366F1),
                iconBg: Color(0xFFEEF2FF),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _StatCard(
                title: 'DISBURSEMENT %',
                value: '0.0%',
                hasValueDot: true,
                valueDotColor: Color(0xFF10B981),
                subtitle: 'Clearance: 0.0%',
                icon: Icons.percent_rounded,
                iconColor: Color(0xFF64748B),
                iconBg: Color(0xFFF1F5F9),
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
    this.badgeText,
    this.badgeBg,
    this.badgeColor,
    this.hasValueDot = false,
    this.valueDotColor,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String? badgeText;
  final Color? badgeBg;
  final Color? badgeColor;
  final bool hasValueDot;
  final Color? valueDotColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: PortalColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 3,
            offset: const Offset(0, 1),
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
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF64748B),
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              Container(
                width: 23,
                height: 23,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 12.5, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 4),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (hasValueDot) ...[
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: valueDotColor ?? const Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
              ],
              Text(
                value,
                style: portalText(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  color: PortalColors.heading,
                  letterSpacing: -0.2,
                ),
              ),
              if (badgeText != null) ...[
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1.5,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBg ?? const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    badgeText!,
                    style: portalText(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      color: badgeColor ?? const Color(0xFF15803D),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),

          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}

class _PayrollAnalyticsCard extends StatelessWidget {
  const _PayrollAnalyticsCard({
    required this.selectedMonth,
    required this.onMonthTap,
  });

  final String selectedMonth;
  final VoidCallback onMonthTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PortalColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPayrollStatusSection(),

          const SizedBox(height: 20),
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFF1F5F9),
          ),
          const SizedBox(height: 18),

          _buildGrossVsNetSection(),

          const SizedBox(height: 20),
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFF1F5F9),
          ),
          const SizedBox(height: 18),

          _buildDepartmentDisbursementSection(),
        ],
      ),
    );
  }

  Widget _buildPayrollStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PAYROLL STATUS',
                  style: portalText(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 3),
                RichText(
                  text: TextSpan(
                    style: portalText(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                    children: [
                      const TextSpan(text: 'Disbursed Clearance: '),
                      TextSpan(
                        text: '0.0%',
                        style: portalText(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: onMonthTap,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  selectedMonth,
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF475569),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Divider(
          height: 1,
          thickness: 1,
          color: Color(0xFFF1F5F9),
        ),
        const SizedBox(height: 14),

        Row(
          children: [
            SizedBox(
              width: 104,
              height: 104,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(104, 104),
                    painter: const _DonutChartPainter(
                      sections: [
                        _ChartSection(
                          percentage: 76.9,
                          color: Color(0xFFEF4444), // With Deductions
                        ),
                        _ChartSection(
                          percentage: 23.1,
                          color: Color(0xFF3B82F6), // On Hold / Inactive
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '0.0%',
                        style: portalText(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        'DISBURSED',
                        style: portalText(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF64748B),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                children: const [
                  _LegendRow(
                    dotColor: Color(0xFF10B981),
                    title: 'Salary Paid',
                    valueText: '0 (0.0%)',
                  ),
                  SizedBox(height: 7),
                  _LegendRow(
                    dotColor: Color(0xFFF59E0B),
                    title: 'Salary Pending',
                    valueText: '0 (0.0%)',
                  ),
                  SizedBox(height: 7),
                  _LegendRow(
                    dotColor: Color(0xFFEF4444),
                    title: 'With Deductions',
                    valueText: '20 (76.9%)',
                  ),
                  SizedBox(height: 7),
                  _LegendRow(
                    dotColor: Color(0xFF3B82F6),
                    title: 'On Hold / Inactive',
                    valueText: '6 (23.1%)',
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGrossVsNetSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GROSS VS NET PAYROLL',
                  style: portalText(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Active Departments (6 Units)',
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'Gross',
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF059669),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFF3B82F6),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'Net (₹0)',
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),

        const _DepartmentPayrollBar(
          deptName: 'Developer',
          grossText: '₹62k',
          netText: 'Net 0',
          progress: 1.0,
        ),
        const SizedBox(height: 12),
        const _DepartmentPayrollBar(
          deptName: 'Consultant',
          grossText: '₹45k',
          netText: 'Net 0',
          progress: 45 / 62,
        ),
        const SizedBox(height: 12),
        const _DepartmentPayrollBar(
          deptName: 'Medical',
          grossText: '₹38k',
          netText: 'Net 0',
          progress: 38 / 62,
        ),
        const SizedBox(height: 12),
        const _DepartmentPayrollBar(
          deptName: 'Laboratory Medicine',
          grossText: '₹32k',
          netText: 'Net 0',
          progress: 32 / 62,
        ),
        const SizedBox(height: 12),
        const _DepartmentPayrollBar(
          deptName: 'Marketing',
          grossText: '₹19k',
          netText: 'Net 0',
          progress: 19 / 62,
        ),
        const SizedBox(height: 12),
        const _DepartmentPayrollBar(
          deptName: 'Digital Marketing',
          grossText: '₹16k',
          netText: 'Net 0',
          progress: 16 / 62,
        ),
      ],
    );
  }

  Widget _buildDepartmentDisbursementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'DEPARTMENT DISBURSEMENT (%)',
              style: portalText(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
                letterSpacing: 0.3,
              ),
            ),
            Text(
              'All 0%',
              style: portalText(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Row(
          children: const [
            Expanded(child: _DeptPercentTile(name: 'Developer', percent: '0%')),
            SizedBox(width: 8),
            Expanded(child: _DeptPercentTile(name: 'Consultant', percent: '0%')),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: const [
            Expanded(child: _DeptPercentTile(name: 'Medical', percent: '0%')),
            SizedBox(width: 8),
            Expanded(child: _DeptPercentTile(name: 'Lab Medicine', percent: '0%')),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: const [
            Expanded(child: _DeptPercentTile(name: 'Marketing', percent: '0%')),
            SizedBox(width: 8),
            Expanded(child: _DeptPercentTile(name: 'Digital Marketing', percent: '0%')),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: const [
            Expanded(child: _DeptPercentTile(name: 'Nursing', percent: '0%')),
            SizedBox(width: 8),
            Expanded(child: _DeptPercentTile(name: 'Management', percent: '0%')),
          ],
        ),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.dotColor,
    required this.title,
    required this.valueText,
  });

  final Color dotColor;
  final String title;
  final String valueText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 7.5,
          height: 7.5,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF334155),
            ),
          ),
        ),
        Text(
          valueText,
          style: portalText(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}

class _DepartmentPayrollBar extends StatelessWidget {
  const _DepartmentPayrollBar({
    required this.deptName,
    required this.grossText,
    required this.netText,
    required this.progress,
  });

  final String deptName;
  final String grossText;
  final String netText;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              deptName,
              style: portalText(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF334155),
              ),
            ),
            RichText(
              text: TextSpan(
                style: portalText(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
                children: [
                  TextSpan(text: grossText),
                  TextSpan(
                    text: ' / $netText',
                    style: portalText(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LayoutBuilder(
          builder: (context, constraints) {
            final barWidth = constraints.maxWidth * progress.clamp(0.0, 1.0);
            return Stack(
              children: [
                Container(
                  height: 6.5,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(3.5),
                  ),
                ),
                Container(
                  height: 6.5,
                  width: barWidth,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(3.5),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _DeptPercentTile extends StatelessWidget {
  const _DeptPercentTile({
    required this.name,
    required this.percent,
  });

  final String name;
  final String percent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFE2E8F0).withValues(alpha: 0.7),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: portalText(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF475569),
              ),
            ),
          ),
          Text(
            percent,
            style: portalText(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  const _DonutChartPainter({
    required this.sections,
  });

  final List<_ChartSection> sections;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 14) / 2;
    const strokeWidth = 12.0;

    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = const Color(0xFFF1F5F9);

    canvas.drawCircle(center, radius, bgPaint);

    final rect = Rect.fromCircle(center: center, radius: radius);
    var startAngle = -math.pi / 2; // Start from top (12 o'clock)

    for (final section in sections) {
      if (section.percentage <= 0) continue;
      final sweepAngle = (section.percentage / 100) * 2 * math.pi;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = section.color;

      const gap = 0.05;
      if (sweepAngle > gap) {
        canvas.drawArc(
          rect,
          startAngle + gap / 2,
          sweepAngle - gap,
          false,
          paint,
        );
      }
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) => true;
}

class _ChartSection {
  const _ChartSection({
    required this.percentage,
    required this.color,
  });

  final double percentage;
  final Color color;
}

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
            const Icon(
              Icons.receipt_long_rounded,
              size: 16,
              color: Color(0xFF475569),
            ),
            const SizedBox(width: 6),
            Text(
              'Employee Payroll List',
              style: portalText(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF334155),
                letterSpacing: 0.2,
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
