import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/core/theme/portal_system_ui.dart';
import 'package:timelay_health/core/widgets/portal_safe_area.dart';
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

  late List<EmployeePayrollItem> _records;

  DateTime? _selectedDate;
  String _monthFilter = 'Nov 2026';
  String _deptFilter = 'All Depts';
  String _desigFilter = 'All Designations';
  String _statusFilter = 'ALL'; // ALL, ACTIVE, INACTIVE

  static const departments = <String>[
    'All Depts',
    'Consultant',
    'Nursing',
    'Laboratory Medicine',
    'Developer',
    'Digital Marketing',
    'Medical',
    'Management',
    'Sales',
  ];

  static const designations = <String>[
    'All Designations',
    'Phlebotomist',
    'Web Developer',
    'Graphic Designer',
    'MERN Stack Developer',
    'Pharmacist',
    'HR Intern',
    'Clinical Dietician',
    'Manager',
    'Staff Nurse',
    'Doctor',
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
    _records = EmployeePayrollItem.sampleList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<EmployeePayrollItem> get _filteredRecords {
    final query = _searchCtrl.text.trim().toLowerCase();

    return _records.where((item) {
      if (_statusFilter == 'ACTIVE' && !item.isActive) return false;
      if (_statusFilter == 'INACTIVE' && item.isActive) return false;

      if (_deptFilter != 'All Depts' &&
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
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: PortalColors.brand,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: PortalColors.heading,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
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
                            Icon(Icons.search_rounded, size: 18, color: accent),
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

    final dateChipLabel = _selectedDate != null
        ? '${_selectedDate!.day}/${_selectedDate!.month}'
        : 'Date';

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
              // --- 1. Top Navbar (Identical to Payroll Dashboard, No Live Badge) ---
              _TopBar(
                onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
              ),

              // --- 2. Scrollable Body Content ---
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
                  children: [
                    // Search Bar
                    _SearchInput(
                      controller: _searchCtrl,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 10),

                    // Filter Chips Row (Single Line, No Scroll)
                    _FilterRow(
                      dateLabel: dateChipLabel,
                      monthLabel: _monthFilter,
                      deptLabel: _deptFilter != 'All Depts' ? _deptFilter : 'Dept',
                      desigLabel: _desigFilter != 'All Designations'
                          ? _desigFilter
                          : 'Desig',
                      dateActive: _selectedDate != null,
                      monthActive: true,
                      deptActive: _deptFilter != 'All Depts',
                      desigActive: _desigFilter != 'All Designations',
                      onDateTap: _pickDate,
                      onMonthTap: () => _pickFromSheet(
                        title: 'Select Month',
                        subtitle: 'Payroll cycle period',
                        icon: Icons.event_note_rounded,
                        accent: const Color(0xFF2563EB),
                        accentTint: const Color(0xFFEFF6FF),
                        items: months,
                        selected: _monthFilter,
                        onPick: (val) => setState(() => _monthFilter = val),
                      ),
                      onDeptTap: () => _pickFromSheet(
                        title: 'Select Department',
                        subtitle: 'Filter by department',
                        icon: Icons.apartment_rounded,
                        accent: const Color(0xFF7C3AED),
                        accentTint: const Color(0xFFF5F3FF),
                        items: departments,
                        selected: _deptFilter,
                        onPick: (val) => setState(() => _deptFilter = val),
                      ),
                      onDesigTap: () => _pickFromSheet(
                        title: 'Select Designation',
                        subtitle: 'Filter by designation',
                        icon: Icons.badge_outlined,
                        accent: const Color(0xFF059669),
                        accentTint: const Color(0xFFECFDF5),
                        items: designations,
                        selected: _desigFilter,
                        onPick: (val) => setState(() => _desigFilter = val),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 3 Stat Cards Row
                    _StatCardsRow(
                      activeFilter: _statusFilter,
                      onSelect: (filter) =>
                          setState(() => _statusFilter = filter),
                    ),
                    const SizedBox(height: 16),

                    // Employee Records Header
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

                    // Employee Payroll Cards List
                    for (final item in list) ...[
                      _EmployeePayrollCard(
                        item: item,
                        onViewDetails: () => _showEmployeeDetails(item),
                        onHoldTap: () => _onHoldTap(item),
                      ),
                      const SizedBox(height: 12),
                    ],

                    const SizedBox(height: 8),

                    // Footer Sync Info
                    Center(
                      child: Text(
                        'Showing ${list.length} of 65 employee records • Payroll cycle: $_monthFilter',
                        style: portalText(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
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
// 1. Top Navbar (Identical to Payroll Dashboard)
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

// ---------------------------------------------------------------------------
// 2. Search Input
// ---------------------------------------------------------------------------
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

// ---------------------------------------------------------------------------
// 3. Filter Row (4 Chips)
// ---------------------------------------------------------------------------
class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.dateLabel,
    required this.monthLabel,
    required this.deptLabel,
    required this.desigLabel,
    required this.dateActive,
    required this.monthActive,
    required this.deptActive,
    required this.desigActive,
    required this.onDateTap,
    required this.onMonthTap,
    required this.onDeptTap,
    required this.onDesigTap,
  });

  final String dateLabel;
  final String monthLabel;
  final String deptLabel;
  final String desigLabel;
  final bool dateActive;
  final bool monthActive;
  final bool deptActive;
  final bool desigActive;
  final VoidCallback onDateTap;
  final VoidCallback onMonthTap;
  final VoidCallback onDeptTap;
  final VoidCallback onDesigTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _FilterChip(
            icon: Icons.calendar_today_outlined,
            label: dateLabel,
            active: dateActive,
            onTap: onDateTap,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _FilterChip(
            icon: Icons.event_note_rounded,
            label: monthLabel,
            active: monthActive,
            onTap: onMonthTap,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _FilterChip(
            icon: Icons.apartment_rounded,
            label: deptLabel,
            active: deptActive,
            onTap: onDeptTap,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _FilterChip(
            icon: Icons.badge_outlined,
            label: desigLabel,
            active: desigActive,
            onTap: onDesigTap,
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
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
          padding: const EdgeInsets.symmetric(horizontal: 5),
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
                size: 11.5,
                color: active ? PortalColors.brand : PortalColors.muted,
              ),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: active ? PortalColors.brand : PortalColors.heading,
                  ),
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.arrow_drop_down_rounded,
                size: 14,
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
// 4. 5 Stat Cards Row (3 visible in view, 4 & 5 on scroll)
// ---------------------------------------------------------------------------
class _StatCardsRow extends StatelessWidget {
  const _StatCardsRow({
    required this.activeFilter,
    required this.onSelect,
  });

  final String activeFilter;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Exactly 3 cards fit within available width, cards 4 and 5 on scroll
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
                value: '65',
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
                value: '25',
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
                value: '40',
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
                value: '₹634,000',
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
                value: '₹199,316',
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

// ---------------------------------------------------------------------------
// 5. Employee Payroll Card
// ---------------------------------------------------------------------------
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
                // Row 1: Initials, Name, Code, Designation, Status Pill, Eye Icon
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

                // Row 2: Attendance Metrics & Weekoff Dates
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

                // Row 3: ACT SAL | CALC | HOLD | NET PAY
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
