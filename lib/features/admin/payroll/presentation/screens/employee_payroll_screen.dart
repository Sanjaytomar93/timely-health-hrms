import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/core/theme/portal_system_ui.dart';
import 'package:timelay_health/core/widgets/portal_safe_area.dart';
import 'package:timelay_health/core/widgets/shimmer.dart';
import 'package:timelay_health/features/admin/payroll/data/datasources/bulk_payroll_remote_datasource.dart';
import 'package:timelay_health/features/admin/payroll/domain/failures/bulk_payroll_failure.dart';
import 'package:timelay_health/features/admin/payroll/presentation/models/employee_payroll_model.dart';
import 'package:timelay_health/features/dashboard/presentation/screens/employee_home_shell.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/employee_bottom_nav.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/home_side_drawer.dart';
import 'package:timelay_health/features/notifications/presentation/widgets/top_notification_button.dart';

class EmployeePayrollScreen extends StatefulWidget {
  const EmployeePayrollScreen({super.key});

  @override
  State<EmployeePayrollScreen> createState() => _EmployeePayrollScreenState();
}

class _EmployeePayrollScreenState extends State<EmployeePayrollScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchCtrl = TextEditingController();
  final BulkPayrollRemoteDataSource _remote = BulkPayrollRemoteDataSource();

  static const _monthShort = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static const _monthFull = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  EmployeePayrollUi _ui = EmployeePayrollUi.empty;
  bool _ready = false;
  String? _error;

  DateTime? _startDate;
  DateTime? _endDate;
  late String _monthKey;
  late String _monthFilter;
  String _deptFilter = 'All Departments';
  String _desigFilter = 'All Designations';
  String _statusFilter = 'ALL';

  late final List<String> _months;

  static String _labelFor(DateTime d) =>
      '${_monthShort[d.month - 1]} ${d.year}';

  static String _keyFor(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}';

  static DateTime? _parseLabel(String label) {
    final parts = label.trim().split(RegExp(r'\s+'));
    if (parts.length != 2) return null;
    final mi = _monthShort.indexWhere((m) => m == parts[0]);
    final year = int.tryParse(parts[1]);
    if (mi < 0 || year == null) return null;
    return DateTime(year, mi + 1, 1);
  }

  String _fmtChipDate(DateTime d) => '${d.day}/${d.month}';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _monthKey = _keyFor(now);
    _monthFilter = _labelFor(now);
    _months = List.generate(12, (i) {
      final d = DateTime(now.year, now.month - i, 1);
      return _labelFor(d);
    });
    _loadPayroll();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPayroll() async {
    setState(() {
      _ready = false;
      _error = null;
    });
    try {
      final json = await _remote.getBulkPayroll(month: _monthKey);
      if (!mounted) return;
      setState(() {
        _ui = EmployeePayrollUi.fromBulkPayrollJson(json);
        _ready = true;
        if (!_ui.departments.contains(_deptFilter)) {
          _deptFilter = 'All Departments';
        }
        if (!_ui.designations.contains(_desigFilter)) {
          _desigFilter = 'All Designations';
        }
      });
    } on BulkPayrollFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _ready = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load payroll data. Please try again.';
        _ready = true;
      });
    }
  }

  void _onMonthPicked(String label) {
    final parsed = _parseLabel(label);
    if (parsed == null) return;
    setState(() {
      _monthFilter = label;
      _monthKey = _keyFor(parsed);
    });
    _loadPayroll();
  }

  List<EmployeePayrollItem> get _filteredRecords {
    final query = _searchCtrl.text.trim().toLowerCase();

    return _ui.records.where((item) {
      if (_statusFilter == 'ACTIVE' && !item.isActive) return false;
      if (_statusFilter == 'INACTIVE' && item.isActive) return false;

      if (_deptFilter != 'All Departments' &&
          item.department.toLowerCase() != _deptFilter.toLowerCase()) {
        return false;
      }

      if (_desigFilter != 'All Designations' &&
          item.designation.toLowerCase() != _desigFilter.toLowerCase()) {
        return false;
      }

      if (query.isNotEmpty) {
        final matchName = item.name.toLowerCase().contains(query);
        final matchCode = item.code.toLowerCase().contains(query);
        final matchDept = item.department.toLowerCase().contains(query);
        final matchDesig = item.designation.toLowerCase().contains(query);
        if (!matchName && !matchCode && !matchDept && !matchDesig) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Future<void> _pickDate() async {
    final picked = await showModalBottomSheet<DateTimeRange>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => _DateRangePickerSheet(
        initialStart: _startDate,
        initialEnd: _endDate,
      ),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _startDate = picked.start;
      _endDate = picked.end;
    });
  }

  Future<void> _pickMonth() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => _FilterGridPickerSheet(
        title: 'Select Month',
        subtitle: 'Choose a payroll cycle period',
        icon: Icons.calendar_month_rounded,
        items: _months,
        selected: _monthFilter,
        highlightItem: _months.isNotEmpty ? _months.first : null,
      ),
    );
    if (picked == null || !mounted) return;
    _onMonthPicked(picked);
  }

  Future<void> _pickDept() async {
    final items = _ui.departments
        .where((e) => e != 'All Departments')
        .toList();
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => _FilterGridPickerSheet(
        title: 'Select Department',
        subtitle: 'Choose a department to filter payroll',
        icon: Icons.apartment_rounded,
        allLabel: 'All Departments',
        items: items,
        selected: _deptFilter,
      ),
    );
    if (picked == null || !mounted) return;
    setState(() => _deptFilter = picked);
  }

  Future<void> _pickDesignation() async {
    final items = _ui.designations
        .where((e) => e != 'All Designations')
        .toList();
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => _FilterGridPickerSheet(
        title: 'Select Designation',
        subtitle: 'Choose a designation to filter payroll',
        icon: Icons.badge_outlined,
        allLabel: 'All Designations',
        items: items,
        selected: _desigFilter,
      ),
    );
    if (picked == null || !mounted) return;
    setState(() => _desigFilter = picked);
  }

  void _showEmployeeDetails(EmployeePayrollItem item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: PortalColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E1B4B),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        item.initials,
                        style: portalText(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: portalText(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: PortalColors.heading,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${item.code} • ${item.designation} (${item.department})',
                            style: portalText(
                              fontSize: 12,
                              color: PortalColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                const SizedBox(height: 14),
                _detailRow('Attendance Present', '${item.presentDays} Days'),
                _detailRow('Half Days', '${item.halfDays} Days'),
                _detailRow('Overtime', item.otHours),
                _detailRow('Paid Days', '${item.paidDays} Days'),
                if (item.compOffs.isNotEmpty)
                  _detailRow('Comp-off Days', '${item.compOffs} Days'),
                _detailRow('Week-Off Dates', item.woDates),
                const Divider(height: 20, color: Color(0xFFE2E8F0)),
                _detailRow('Actual Salary', item.actSal),
                _detailRow('Calculated Salary', item.calcSal),
                _detailRow('Hold Amount', item.holdText),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'NET PAYOUT',
                        style: portalText(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF065F46),
                        ),
                      ),
                      Text(
                        item.netPay,
                        style: portalText(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF059669),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: portalText(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
          Text(
            value,
            style: portalText(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: PortalColors.heading,
            ),
          ),
        ],
      ),
    );
  }

  void _onHoldTap(EmployeePayrollItem item) {
    final ctrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Hold Salary - ${item.name}',
          style: portalText(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: PortalColors.heading,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter hold amount for ${item.name} (${item.code}):',
              style: portalText(fontSize: 12, color: PortalColors.muted),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'e.g. 2000',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: PortalColors.border),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: portalText(color: PortalColors.muted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: PortalColors.brand,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Hold amount updated for ${item.name}'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: const Color(0xFF059669),
                ),
              );
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredRecords;
    final dateActive = _startDate != null && _endDate != null;
    final deptActive = _deptFilter != 'All Departments';
    final desigActive = _desigFilter != 'All Designations';

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
                    : _error != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _error!,
                                    textAlign: TextAlign.center,
                                    style: portalText(
                                      fontSize: 13,
                                      color: PortalColors.muted,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextButton(
                                    onPressed: _loadPayroll,
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
                  children: [
                    _SearchInput(
                      controller: _searchCtrl,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 10),
                    _FilterChipsRow(
                      dateLabel: dateActive
                          ? '${_fmtChipDate(_startDate!)}-${_fmtChipDate(_endDate!)}'
                          : 'Date',
                      monthLabel: _monthFilter,
                      deptLabel: deptActive ? _deptFilter : 'Department',
                      designLabel:
                          desigActive ? _desigFilter : 'Designation',
                      dateActive: dateActive,
                      monthActive: true,
                      deptActive: deptActive,
                      designActive: desigActive,
                      onDateTap: _pickDate,
                      onMonthTap: _pickMonth,
                      onDeptTap: _pickDept,
                      onDesignTap: _pickDesignation,
                      onDateClear: () => setState(() {
                        _startDate = null;
                        _endDate = null;
                      }),
                      onMonthClear: () {
                        final now = DateTime.now();
                        _onMonthPicked(_labelFor(now));
                      },
                      onDeptClear: () =>
                          setState(() => _deptFilter = 'All Departments'),
                      onDesignClear: () =>
                          setState(() => _desigFilter = 'All Designations'),
                    ),
                    const SizedBox(height: 14),
                    _StatCardsRow(
                      stats: _ui.stats,
                      activeFilter: _statusFilter,
                      onSelect: (filter) =>
                          setState(() => _statusFilter = filter),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(
                          Icons.assignment_ind_outlined,
                          size: 17,
                          color: Color(0xFF475569),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Employee Records',
                          style: portalText(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF334155),
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (list.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text(
                            'No payroll records for $_monthFilter',
                            style: portalText(
                              fontSize: 13,
                              color: PortalColors.muted,
                            ),
                          ),
                        ),
                      )
                    else
                      for (final item in list) ...[
                        _EmployeePayrollCard(
                          item: item,
                          onViewDetails: () => _showEmployeeDetails(item),
                          onHoldTap: () => _onHoldTap(item),
                        ),
                        const SizedBox(height: 12),
                      ],
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
                Text(
                  'Employee Payroll',
                  style: portalText(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Monthly Salary & Payout Details',
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

class _SearchInput extends StatelessWidget {
  const _SearchInput({
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
                hintText: 'Search employee by ID, name...',
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

class _FilterChipsRow extends StatelessWidget {
  const _FilterChipsRow({
    required this.dateLabel,
    required this.monthLabel,
    required this.deptLabel,
    required this.designLabel,
    required this.dateActive,
    required this.monthActive,
    required this.deptActive,
    required this.designActive,
    required this.onDateTap,
    required this.onMonthTap,
    required this.onDeptTap,
    required this.onDesignTap,
    this.onDateClear,
    this.onMonthClear,
    this.onDeptClear,
    this.onDesignClear,
  });

  final String dateLabel;
  final String monthLabel;
  final String deptLabel;
  final String designLabel;
  final bool dateActive;
  final bool monthActive;
  final bool deptActive;
  final bool designActive;
  final VoidCallback onDateTap;
  final VoidCallback onMonthTap;
  final VoidCallback onDeptTap;
  final VoidCallback onDesignTap;
  final VoidCallback? onDateClear;
  final VoidCallback? onMonthClear;
  final VoidCallback? onDeptClear;
  final VoidCallback? onDesignClear;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Chip(
            icon: Icons.calendar_today_outlined,
            label: dateLabel,
            active: dateActive,
            onTap: onDateTap,
            onClear: onDateClear,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _Chip(
            icon: Icons.event_note_rounded,
            label: monthLabel,
            active: monthActive,
            onTap: onMonthTap,
            onClear: onMonthClear,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _Chip(
            icon: Icons.apartment_rounded,
            label: deptLabel,
            active: deptActive,
            onTap: onDeptTap,
            onClear: onDeptClear,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _Chip(
            icon: Icons.badge_outlined,
            label: designLabel,
            active: designActive,
            onTap: onDesignTap,
            onClear: onDesignClear,
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
    this.onClear,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final color = active ? PortalColors.brand : PortalColors.muted;
    return Material(
      color: active ? PortalColors.brandTint : Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 6),
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
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
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
              if (active && onClear != null)
                GestureDetector(
                  onTap: onClear,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.all(1.5),
                    decoration: BoxDecoration(
                      color: PortalColors.brand.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 11,
                      color: PortalColors.brand,
                    ),
                  ),
                )
              else
                Icon(Icons.arrow_drop_down, size: 14, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCardsRow extends StatelessWidget {
  const _StatCardsRow({
    required this.stats,
    required this.activeFilter,
    required this.onSelect,
  });

  final EmployeePayrollStats stats;
  final String activeFilter;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 8.0;
        final cardWidth = (constraints.maxWidth - (spacing * 2)) / 3;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _StatCard(
                width: cardWidth,
                title: 'ALL EMPLOYEES',
                value: '${stats.totalEmployees}',
                subtitle: 'total in payroll',
                icon: Icons.group_outlined,
                iconColor: const Color(0xFF2563EB),
                iconBg: const Color(0xFFEFF6FF),
                titleColor: const Color(0xFF64748B),
                isSelected: activeFilter == 'ALL',
                onTap: () => onSelect('ALL'),
              ),
              const SizedBox(width: spacing),
              _StatCard(
                width: cardWidth,
                title: 'ACTIVE EMPLOYEES',
                value: '${stats.activeEmployees}',
                subtitle: 'active in payroll',
                icon: Icons.person_outline_rounded,
                iconColor: const Color(0xFF059669),
                iconBg: const Color(0xFFECFDF5),
                titleColor: const Color(0xFF059669),
                isSelected: activeFilter == 'ACTIVE',
                onTap: () => onSelect('ACTIVE'),
              ),
              const SizedBox(width: spacing),
              _StatCard(
                width: cardWidth,
                title: 'INACTIVE EMPLOYEES',
                value: '${stats.inactiveEmployees}',
                subtitle: 'hidden from reports',
                icon: Icons.person_off_outlined,
                iconColor: const Color(0xFFDC2626),
                iconBg: const Color(0xFFFEF2F2),
                titleColor: const Color(0xFFDC2626),
                isSelected: activeFilter == 'INACTIVE',
                onTap: () => onSelect('INACTIVE'),
              ),
              const SizedBox(width: spacing),
              _StatCard(
                width: cardWidth,
                title: 'TOTAL ASSIGNED SALARY',
                value: stats.totalAssignedSalary,
                subtitle: 'total assigned per month',
                icon: Icons.trending_up_rounded,
                iconColor: const Color(0xFF4F46E5),
                iconBg: const Color(0xFFEEF2FF),
                titleColor: const Color(0xFF64748B),
                isSelected: activeFilter == 'SALARY',
                onTap: () => onSelect('SALARY'),
              ),
              const SizedBox(width: spacing),
              _StatCard(
                width: cardWidth,
                title: 'TOTAL NET PAY',
                value: stats.totalNetPay,
                subtitle: 'total net pay this month',
                icon: Icons.trending_up_rounded,
                iconColor: const Color(0xFF0284C7),
                iconBg: const Color(0xFFF0F9FF),
                titleColor: const Color(0xFF64748B),
                isSelected: activeFilter == 'NET_PAY',
                onTap: () => onSelect('NET_PAY'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.width,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.titleColor,
    required this.isSelected,
    required this.onTap,
  });

  final double width;
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Color titleColor;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: width,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? const Color(0xFF4F46E5) : PortalColors.border,
              width: isSelected ? 1.5 : 1,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: portalText(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        color: titleColor,
                        letterSpacing: 0.1,
                        height: 1.15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon, size: 12, color: iconColor),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: portalText(
                    fontSize: value.startsWith('₹') ? 14 : 18,
                    fontWeight: FontWeight.w800,
                    color: PortalColors.heading,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: portalText(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w500,
                  color: PortalColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmployeePayrollCard extends StatelessWidget {
  const _EmployeePayrollCard({
    required this.item,
    required this.onViewDetails,
    required this.onHoldTap,
  });

  final EmployeePayrollItem item;
  final VoidCallback onViewDetails;
  final VoidCallback onHoldTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.hasAmberAccent
              ? const Color(0xFFF59E0B)
              : const Color(0xFFE2E8F0),
          width: item.hasAmberAccent ? 1.2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (item.hasAmberAccent)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 3.5,
              child: Container(color: const Color(0xFFF59E0B)),
            ),
          Padding(
            padding: const EdgeInsets.all(14),
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
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
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
                            '${item.designation} - ${item.department}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: portalText(
                              fontSize: 11,
                              color: PortalColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2.5,
                      ),
                      decoration: BoxDecoration(
                        color: item.isActive
                            ? const Color(0xFFECFDF5)
                            : const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: item.isActive
                              ? const Color(0xFFA7F3D0)
                              : const Color(0xFFFECACA),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        item.status,
                        style: portalText(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: item.isActive
                              ? const Color(0xFF059669)
                              : const Color(0xFFDC2626),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: onViewDetails,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.remove_red_eye_outlined,
                          size: 16,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _metricCol('PRES', '${item.presentDays}', const Color(0xFF059669)),
                          _divider(),
                          _metricCol(
                            'HALF',
                            item.halfDays == 0 ? '0' : '${item.halfDays}',
                            item.halfDays > 0 ? const Color(0xFFD97706) : PortalColors.heading,
                          ),
                          _divider(),
                          _metricCol(
                            'OT',
                            item.otHours,
                            item.otHours.startsWith('+') ? const Color(0xFF2563EB) : PortalColors.muted,
                          ),
                          _divider(),
                          _metricCol('PAID', '${item.paidDays}', const Color(0xFF059669)),
                          if (item.compOffs.isNotEmpty) ...[
                            _divider(),
                            _metricCol('COMP', item.compOffs, const Color(0xFF059669)),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Divider(height: 1, color: Color(0xFFE2E8F0)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            'WO DATES:',
                            style: portalText(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF94A3B8),
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.woDates,
                              style: portalText(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF475569),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _finCol('ACT SAL', item.actSal),
                    _finCol('CALC', item.calcSal),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'HOLD',
                          style: portalText(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 2),
                        if (item.holdText == '+Add')
                          GestureDetector(
                            onTap: onHoldTap,
                            behavior: HitTestBehavior.opaque,
                            child: Text(
                              '+Add',
                              style: portalText(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2563EB),
                              ),
                            ),
                          )
                        else
                          Text(
                            item.holdText,
                            style: portalText(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: PortalColors.muted,
                            ),
                          ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'NET PAY',
                          style: portalText(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF059669),
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          item.netPay,
                          style: portalText(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF059669),
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 16, color: const Color(0xFFE2E8F0));
  }

  Widget _metricCol(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: portalText(
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: portalText(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _finCol(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: portalText(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: portalText(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: PortalColors.heading,
          ),
        ),
      ],
    );
  }
}

class _DateRangePickerSheet extends StatefulWidget {
  const _DateRangePickerSheet({
    this.initialStart,
    this.initialEnd,
  });

  final DateTime? initialStart;
  final DateTime? initialEnd;

  @override
  State<_DateRangePickerSheet> createState() => _DateRangePickerSheetState();
}

class _DateRangePickerSheetState extends State<_DateRangePickerSheet> {
  late DateTime _viewMonth;
  DateTime? _start;
  DateTime? _end;
  bool _pickingEnd = false;

  static const _weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  static const _monthNames = _EmployeePayrollScreenState._monthFull;

  @override
  void initState() {
    super.initState();
    _start = widget.initialStart;
    _end = widget.initialEnd;
    _viewMonth = DateTime(
      (_start ?? DateTime.now()).year,
      (_start ?? DateTime.now()).month,
    );
    _pickingEnd = _start != null && _end == null;
  }

  DateTime _only(DateTime d) => DateTime(d.year, d.month, d.day);

  String _label(DateTime? d) {
    if (d == null) return 'Select date';
    return '${d.day.toString().padLeft(2, '0')} ${_monthNames[d.month - 1].substring(0, 3)} ${d.year}';
  }

  void _onDayTap(DateTime day) {
    final d = _only(day);
    setState(() {
      if (!_pickingEnd || _start == null) {
        _start = d;
        _end = null;
        _pickingEnd = true;
      } else {
        if (d.isBefore(_start!)) {
          _end = _start;
          _start = d;
        } else {
          _end = d;
        }
        _pickingEnd = false;
      }
    });
  }

  bool _inRange(DateTime day) {
    if (_start == null || _end == null) return false;
    final d = _only(day);
    return !d.isBefore(_start!) && !d.isAfter(_end!);
  }

  bool _isStart(DateTime day) =>
      _start != null && _only(day) == _only(_start!);

  bool _isEnd(DateTime day) => _end != null && _only(day) == _only(_end!);

  @override
  Widget build(BuildContext context) {
    final daysInMonth =
        DateTime(_viewMonth.year, _viewMonth.month + 1, 0).day;
    final firstWeekday =
        DateTime(_viewMonth.year, _viewMonth.month, 1).weekday % 7;
    final cells = <DateTime?>[
      ...List<DateTime?>.filled(firstWeekday, null),
      ...List.generate(
        daysInMonth,
        (i) => DateTime(_viewMonth.year, _viewMonth.month, i + 1),
      ),
    ];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    final canApply = _start != null && _end != null;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: PortalColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: PortalColors.brandTint,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.date_range_rounded,
                    size: 19,
                    color: PortalColors.brand,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Date Range',
                        style: portalText(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: PortalColors.heading,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'Pick start and end date',
                        style: portalText(
                          fontSize: 11.5,
                          color: PortalColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, size: 20),
                  color: PortalColors.muted,
                  splashRadius: 18,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _DateFieldCard(
                    label: 'Start Date',
                    value: _label(_start),
                    active: !_pickingEnd,
                    filled: _start != null,
                    onTap: () => setState(() => _pickingEnd = false),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: PortalColors.brand.withValues(alpha: 0.45),
                  ),
                ),
                Expanded(
                  child: _DateFieldCard(
                    label: 'End Date',
                    value: _label(_end),
                    active: _pickingEnd,
                    filled: _end != null,
                    onTap: () {
                      if (_start != null) {
                        setState(() => _pickingEnd = true);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: PortalColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => setState(() {
                          _viewMonth = DateTime(
                            _viewMonth.year,
                            _viewMonth.month - 1,
                          );
                        }),
                        icon: const Icon(Icons.chevron_left_rounded),
                        color: PortalColors.heading,
                        splashRadius: 18,
                      ),
                      Expanded(
                        child: Text(
                          '${_monthNames[_viewMonth.month - 1]} ${_viewMonth.year}',
                          textAlign: TextAlign.center,
                          style: portalText(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: PortalColors.heading,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() {
                          _viewMonth = DateTime(
                            _viewMonth.year,
                            _viewMonth.month + 1,
                          );
                        }),
                        icon: const Icon(Icons.chevron_right_rounded),
                        color: PortalColors.heading,
                        splashRadius: 18,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      for (final d in _weekDays)
                        Expanded(
                          child: Center(
                            child: Text(
                              d,
                              style: portalText(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: PortalColors.muted,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cells.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 2,
                    ),
                    itemBuilder: (_, i) {
                      final day = cells[i];
                      if (day == null) return const SizedBox.shrink();

                      final isStart = _isStart(day);
                      final isEnd = _isEnd(day);
                      final inRange = _inRange(day);
                      final isEdge = isStart || isEnd;
                      final isToday = _only(day) == _only(DateTime.now());

                      return GestureDetector(
                        onTap: () => _onDayTap(day),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isEdge
                                ? PortalColors.brand
                                : (inRange
                                    ? PortalColors.brandTint
                                    : Colors.transparent),
                            shape:
                                isEdge ? BoxShape.circle : BoxShape.rectangle,
                            borderRadius: isEdge
                                ? null
                                : (inRange ? BorderRadius.circular(8) : null),
                            border: isToday && !isEdge && !inRange
                                ? Border.all(
                                    color: PortalColors.brand
                                        .withValues(alpha: 0.35),
                                  )
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${day.day}',
                            style: portalText(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: isEdge
                                  ? Colors.white
                                  : (inRange
                                      ? PortalColors.brand
                                      : PortalColors.heading),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _start = null;
                        _end = null;
                        _pickingEnd = false;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: PortalColors.muted,
                      side: const BorderSide(color: PortalColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Clear',
                      style: portalText(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: PortalColors.muted,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: canApply
                        ? () => Navigator.of(context).pop(
                              DateTimeRange(start: _start!, end: _end!),
                            )
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PortalColors.brand,
                      disabledBackgroundColor:
                          PortalColors.brand.withValues(alpha: 0.35),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Apply Range',
                      style: portalText(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DateFieldCard extends StatelessWidget {
  const _DateFieldCard({
    required this.label,
    required this.value,
    required this.active,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool active;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? PortalColors.brandTint : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active ? PortalColors.brand : PortalColors.border,
              width: active ? 1.4 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: portalText(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: active ? PortalColors.brand : PortalColors.muted,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: portalText(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: filled ? PortalColors.heading : PortalColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterGridPickerSheet extends StatelessWidget {
  const _FilterGridPickerSheet({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.items,
    required this.selected,
    this.allLabel,
    this.highlightItem,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String? allLabel;
  final List<String> items;
  final String selected;
  final String? highlightItem;

  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.sizeOf(context).height * 0.72;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxH),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: PortalColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: PortalColors.brandTint,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon, size: 19, color: PortalColors.brand),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: portalText(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: PortalColors.heading,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          subtitle,
                          style: portalText(
                            fontSize: 11.5,
                            color: PortalColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: PortalColors.muted,
                    splashRadius: 18,
                  ),
                ],
              ),
              if (allLabel != null) ...[
                const SizedBox(height: 12),
                Material(
                  color: selected == allLabel
                      ? PortalColors.brandTint
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(allLabel),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected == allLabel
                              ? PortalColors.brand
                              : PortalColors.border,
                          width: selected == allLabel ? 1.4 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            selected == allLabel
                                ? Icons.check_circle_rounded
                                : Icons.all_inclusive_rounded,
                            size: 18,
                            color: selected == allLabel
                                ? PortalColors.brand
                                : PortalColors.muted,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            allLabel!,
                            style: portalText(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: selected == allLabel
                                  ? PortalColors.brand
                                  : PortalColors.heading,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2.2,
                  ),
                  itemBuilder: (ctx, index) {
                    final name = items[index];
                    final isSelected = selected == name;
                    final isHighlight = highlightItem == name;
                    return Material(
                      color: isSelected
                          ? PortalColors.brand
                          : (isHighlight
                              ? PortalColors.brandTint
                              : Colors.white),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(name),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? PortalColors.brand
                                  : (isHighlight
                                      ? PortalColors.brand
                                          .withValues(alpha: 0.45)
                                      : PortalColors.border),
                              width: isSelected || isHighlight ? 1.3 : 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            name,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: portalText(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : (isHighlight
                                      ? PortalColors.brand
                                      : PortalColors.heading),
                            ),
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
      ),
    );
  }
}
