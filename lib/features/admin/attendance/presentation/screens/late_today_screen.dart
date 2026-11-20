import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_system_ui.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/core/widgets/portal_safe_area.dart';
import 'package:timelay_health/features/admin/attendance/presentation/bloc/late_today_cubit.dart';
import 'package:timelay_health/features/admin/attendance/presentation/bloc/late_today_state.dart';
import 'package:timelay_health/features/admin/attendance/presentation/models/late_today_ui.dart';
import 'package:timelay_health/features/admin/shared/widgets/portal_filter_pickers.dart';
import 'package:timelay_health/features/dashboard/presentation/screens/employee_home_shell.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/employee_bottom_nav.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/home_side_drawer.dart';
import 'package:timelay_health/features/notifications/presentation/widgets/top_notification_button.dart';

class LateTodayScreen extends StatefulWidget {
  const LateTodayScreen({super.key});

  @override
  State<LateTodayScreen> createState() => _LateTodayScreenState();
}

class _LateTodayScreenState extends State<LateTodayScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchCtrl = TextEditingController();
  late final LateTodayCubit _cubit;

  String _dateLabel = 'Date';
  String _monthOnly = 'Nov';
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  String _dept = 'All Departments';
  String _designation = 'All Designations';

  static const List<String> allMonths = [
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

  static const List<String> departments = [
    'All Departments',
    'Consultant',
    'Developer',
    'Digital Marketing',
    'Laboratory Medicine',
    'Management',
    'Marketing',
    'Medical',
    'Nursing',
    'Operations',
  ];

  static const List<String> designations = [
    'All Designations',
    'AI Intern',
    'Clinical Dietician Trainee',
    'Consultant',
    'Doctor',
    'Flutter Developer',
    'General Manager',
    'Graphic Designer',
    'HR Intern',
    'MERN Stack Developer',
    'Manager',
    'Pharmacist',
    'Phlebotomist',
    'Physiotherapist',
    'Staff Nurse',
    'Web Developer',
    'Staff',
  ];

  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = now.year;
    final m = now.month;
    _monthOnly = PortalFilterPickers.monthAbbr(m);
    final monthParam = '$_selectedYear-${m.toString().padLeft(2, '0')}';
    _cubit = LateTodayCubit()..load(month: monthParam);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _cubit.close();
    super.dispose();
  }

  bool get _dateActive => _dateLabel != 'Date' || _rangeStart != null;
  bool get _monthActive => _monthOnly != 'All';
  bool get _deptActive => _dept != 'All Departments';
  bool get _designActive => _designation != 'All Designations';

  void _clearDate() {
    setState(() {
      _dateLabel = 'Date';
      _rangeStart = null;
      _rangeEnd = null;
    });
    _cubit.load(date: null, clearDate: true, isRefresh: true);
  }

  void _clearMonth() {
    setState(() {
      _monthOnly = 'All';
      _dateLabel = 'Date';
      _rangeStart = null;
      _rangeEnd = null;
    });
    _cubit.load(date: null, month: '', clearDate: true, isRefresh: true);
  }

  void _clearDept() {
    setState(() => _dept = 'All Departments');
  }

  void _clearDesignation() {
    setState(() => _designation = 'All Designations');
  }

  List<LateEmployeeItem> _filterRecords(List<LateEmployeeItem> records) {
    final query = _searchCtrl.text.trim().toLowerCase();
    return records.where((item) {
      final matchesQuery = query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          item.employeeId.toLowerCase().contains(query) ||
          item.department.toLowerCase().contains(query) ||
          item.designation.toLowerCase().contains(query) ||
          item.officeName.toLowerCase().contains(query);

      final matchesDept =
          _dept == 'All Departments' || item.department.toLowerCase() == _dept.toLowerCase();
      final matchesDesignation = _designation == 'All Designations' ||
          item.designation.toLowerCase() == _designation.toLowerCase();

      return matchesQuery && matchesDept && matchesDesignation;
    }).toList();
  }

  Future<void> _pickDate() async {
    final picked = await PortalFilterPickers.showDateRange(
      context: context,
      initialStart: _rangeStart,
      initialEnd: _rangeEnd,
    );
    if (picked == null || !mounted) return;
    setState(() {
      _rangeStart = picked.start;
      _rangeEnd = picked.end;
      _dateLabel =
          '${PortalFilterPickers.chipDate(picked.start)}-${PortalFilterPickers.chipDate(picked.end)}';
      _monthOnly = PortalFilterPickers.monthAbbr(picked.start.month);
      _selectedYear = picked.start.year;
    });

    final formattedStart =
        '${picked.start.year}-${picked.start.month.toString().padLeft(2, '0')}-${picked.start.day.toString().padLeft(2, '0')}';
    final monthParam =
        '${picked.start.year}-${picked.start.month.toString().padLeft(2, '0')}';
    _cubit.load(date: formattedStart, month: monthParam, isRefresh: true);
  }

  Future<void> _pickMonthOnly() async {
    final selected = allMonths.firstWhere(
      (m) => m.toLowerCase().startsWith(_monthOnly.toLowerCase()),
      orElse: () => allMonths[(DateTime.now().month - 1).clamp(0, 11)],
    );
    final picked = await PortalFilterPickers.showGrid(
      context: context,
      title: 'Select Month',
      subtitle: 'Choose a month to filter late arrivals',
      icon: Icons.calendar_month_rounded,
      allLabel: 'All Months',
      items: allMonths,
      selected: selected,
      highlightItem: allMonths[(DateTime.now().month - 1).clamp(0, 11)],
    );
    if (picked == null || !mounted) return;
    if (picked == 'All Months') {
      setState(() {
        _monthOnly = 'All';
        _dateLabel = 'Date';
        _rangeStart = null;
        _rangeEnd = null;
      });
      _cubit.load(date: null, month: '', clearDate: true, isRefresh: true);
      return;
    }
    final idx = allMonths.indexOf(picked) + 1;
    final mStr = idx.toString().padLeft(2, '0');
    final monthParam = '$_selectedYear-$mStr';

    setState(() {
      _monthOnly = PortalFilterPickers.monthAbbr(idx);
      _dateLabel = 'Date';
      _rangeStart = null;
      _rangeEnd = null;
    });

    _cubit.load(month: monthParam, clearDate: true, isRefresh: true);
  }

  Future<void> _pickDept(List<String> items) async {
    final gridItems = items.where((e) => e != 'All Departments').toList();
    final picked = await PortalFilterPickers.showGrid(
      context: context,
      title: 'Select Department',
      subtitle: 'Choose a department to filter late arrivals',
      icon: Icons.apartment_rounded,
      allLabel: 'All Departments',
      items: gridItems,
      selected: _dept,
    );
    if (picked == null || !mounted) return;
    setState(() => _dept = picked);
  }

  Future<void> _pickDesignation(List<String> items) async {
    final gridItems = items.where((e) => e != 'All Designations').toList();
    final picked = await PortalFilterPickers.showGrid(
      context: context,
      title: 'Select Designation',
      subtitle: 'Choose a designation to filter late arrivals',
      icon: Icons.badge_outlined,
      allLabel: 'All Designations',
      items: gridItems,
      selected: _designation,
    );
    if (picked == null || !mounted) return;
    setState(() => _designation = picked);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: PortalSystemUi.lightStatusBar,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: const HomeSideDrawer(),
        drawerScrimColor: PortalColors.brand.withValues(alpha: 0.28),
        backgroundColor: const Color(0xFFF8FAFC),
        body: PortalSafeArea(
          bottom: false,
          statusBarColor: PortalColors.surface,
          child: Column(
            children: [
              // White Navbar
              _WhiteTopBar(
                onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
              ),

              // Main Body Content
              Expanded(
                child: BlocBuilder<LateTodayCubit, LateTodayState>(
                  bloc: _cubit,
                  builder: (context, state) {
                    final ui = state.ui;
                    final records = _filterRecords(ui.records);
                    final isLoading = state is LateTodayLoading && ui.records.isEmpty;
                    final isFailure = state is LateTodayFailureState && ui.records.isEmpty;

                    final currentDepts = <String>{
                      ...departments,
                      ...ui.departments,
                    }.toList();

                    final currentDesigs = <String>{
                      ...designations,
                      ...ui.designations,
                    }.toList();

                    if (isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: PortalColors.brand,
                        ),
                      );
                    }

                    if (isFailure) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEE2E2),
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                child: const Icon(
                                  Icons.wifi_off_rounded,
                                  size: 28,
                                  color: Color(0xFFDC2626),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Failed to Load Late Records',
                                style: portalText(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: PortalColors.heading,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                (state as LateTodayFailureState).message,
                                textAlign: TextAlign.center,
                                style: portalText(
                                  fontSize: 12.5,
                                  color: PortalColors.muted,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: PortalColors.brand,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () => _cubit.load(),
                                child: Text(
                                  'Retry',
                                  style: portalText(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      color: PortalColors.brand,
                      onRefresh: () => _cubit.load(isRefresh: true),
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
                        children: [
                          // Search bar
                          _SearchInput(
                            controller: _searchCtrl,
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 10),

                          // Filter chips row
                          _FilterChipsRow(
                            dateLabel: _dateLabel,
                            monthLabel: _monthOnly,
                            deptLabel: _deptActive ? _dept : 'Dept',
                            designLabel: _designActive ? _designation : 'Design',
                            dateActive: _dateActive,
                            monthActive: _monthActive,
                            deptActive: _deptActive,
                            designActive: _designActive,
                            onDateTap: _pickDate,
                            onMonthTap: _pickMonthOnly,
                            onDeptTap: () => _pickDept(currentDepts),
                            onDesignTap: () => _pickDesignation(currentDesigs),
                            onDateClear: _clearDate,
                            onMonthClear: _clearMonth,
                            onDeptClear: _clearDept,
                            onDesignClear: _clearDesignation,
                          ),
                          const SizedBox(height: 14),

                          // SNAPSHOT SUMMARY Section
                          _SnapshotSummarySection(
                            ui: ui,
                            filteredCount: records.length,
                          ),
                          const SizedBox(height: 18),

                          // Late Employees Section Header
                          Row(
                            children: [
                              const SizedBox(width: 4),
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFE11D48),
                                      Color(0xFFF43F5E),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(9),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFE11D48)
                                          .withValues(alpha: 0.32),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.access_time_filled_rounded,
                                  color: Colors.white,
                                  size: 15,
                                ),
                              ),
                              const SizedBox(width: 9),
                              Text(
                                'Late Employees',
                                style: portalText(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0F172A),
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // List of Late Employee Cards
                          if (records.isEmpty)
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 40),
                              alignment: Alignment.center,
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.check_circle_outline_rounded,
                                    size: 40,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'No late records found',
                                    style: portalText(
                                      fontSize: 13,
                                      color: const Color(0xFF64748B),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _searchCtrl.clear();
                                        _dept = 'All Departments';
                                        _designation = 'All Designations';
                                        _dateLabel = 'Date';
                                        _rangeStart = null;
                                        _rangeEnd = null;
                                        final now = DateTime.now();
                                        _selectedYear = now.year;
                                        _monthOnly =
                                            PortalFilterPickers.monthAbbr(
                                                now.month);
                                      });
                                      final monthParam =
                                          '$_selectedYear-${DateTime.now().month.toString().padLeft(2, '0')}';
                                      _cubit.load(
                                        month: monthParam,
                                        clearDate: true,
                                        isRefresh: true,
                                      );
                                    },
                                    child: Text(
                                      'Reset Filters',
                                      style: portalText(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: PortalColors.brand,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            ...records.map(
                              (item) => _LateEmployeeCard(item: item),
                            ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: EmployeeBottomNav(
          currentIndex: 1,
          onTap: (i) => EmployeeHomeShell.goToTab(context, i),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// White Navbar with Menu, Title and Notifications
// ---------------------------------------------------------------------------
class _WhiteTopBar extends StatelessWidget {
  const _WhiteTopBar({required this.onMenuTap});

  final VoidCallback onMenuTap;

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
          GestureDetector(
            onTap: onMenuTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
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
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Late Today',
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
                  'Late Arrival Monitoring',
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
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Search Input Field
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
          const Icon(
            Icons.search_rounded,
            size: 18,
            color: PortalColors.muted,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: portalText(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: PortalColors.heading,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: 'Search by employee, id, dept...',
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
              child: const Icon(
                Icons.cancel,
                size: 15,
                color: Color(0xFF94A3B8),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter Chips Row
// ---------------------------------------------------------------------------
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
        // 1. Date filter
        Expanded(
          child: _FilterItemButton(
            icon: Icons.calendar_today_outlined,
            label: dateLabel,
            hasDropdown: true,
            active: dateActive,
            onTap: onDateTap,
            onClear: onDateClear,
          ),
        ),
        const SizedBox(width: 6),

        // 2. Month filter
        Expanded(
          child: _FilterItemButton(
            icon: Icons.calendar_month_rounded,
            label: monthLabel,
            hasDropdown: true,
            active: monthActive,
            onTap: onMonthTap,
            onClear: onMonthClear,
          ),
        ),
        const SizedBox(width: 6),

        // 3. Dept filter
        Expanded(
          child: _FilterItemButton(
            icon: Icons.apartment_rounded,
            label: deptLabel,
            hasDropdown: true,
            active: deptActive,
            onTap: onDeptTap,
            onClear: onDeptClear,
          ),
        ),
        const SizedBox(width: 6),

        // 4. Design filter
        Expanded(
          child: _FilterItemButton(
            icon: Icons.badge_outlined,
            label: designLabel,
            hasDropdown: true,
            active: designActive,
            onTap: onDesignTap,
            onClear: onDesignClear,
          ),
        ),
      ],
    );
  }
}

class _FilterItemButton extends StatelessWidget {
  const _FilterItemButton({
    required this.icon,
    required this.label,
    required this.hasDropdown,
    required this.active,
    required this.onTap,
    this.onClear,
    this.activeBg,
    this.activeColor,
    this.activeBorder,
  });

  final IconData icon;
  final String label;
  final bool hasDropdown;
  final bool active;
  final VoidCallback onTap;
  final VoidCallback? onClear;
  final Color? activeBg;
  final Color? activeColor;
  final Color? activeBorder;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = active
        ? (activeColor ?? const Color(0xFF2563EB))
        : const Color(0xFF475569);
    final effectiveBg = active
        ? (activeBg ?? const Color(0xFFEFF6FF))
        : Colors.white;
    final effectiveBorder = active
        ? (activeBorder ?? const Color(0xFFBFDBFE))
        : const Color(0xFFE2E8F0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          height: 33,
          padding: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: effectiveBg,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: effectiveBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 11.5, color: effectiveColor),
              const SizedBox(width: 3.5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 10.5,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: effectiveColor,
                  ),
                ),
              ),
              if (active && onClear != null) ...[
                const SizedBox(width: 2),
                GestureDetector(
                  onTap: onClear,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.all(1.5),
                    decoration: BoxDecoration(
                      color: effectiveColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 11,
                      color: effectiveColor,
                    ),
                  ),
                ),
              ] else if (hasDropdown) ...[
                const SizedBox(width: 1),
                Icon(
                  Icons.arrow_drop_down,
                  size: 13,
                  color: effectiveColor,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Snapshot Summary Section
// ---------------------------------------------------------------------------
class _SnapshotSummarySection extends StatelessWidget {
  const _SnapshotSummarySection({
    required this.ui,
    required this.filteredCount,
  });

  final LateTodayUi ui;
  final int filteredCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'SNAPSHOT SUMMARY',
              style: portalText(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF64748B),
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = ((constraints.maxWidth - 16) / 3).floorToDouble();

            return SizedBox(
              height: 82,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: [
                  // 1. TOTAL LATE
                  _MetricSnapshotCard(
                    width: cardWidth,
                    title: 'TOTAL LATE',
                    value: ui.totalLate.toString(),
                    subtitle: 'today late count',
                    icon: Icons.timer_outlined,
                    accentColor: const Color(0xFFF59E0B),
                    accentBg: const Color(0xFFFEF3C7),
                  ),
                  const SizedBox(width: 8),

                  // 2. FILTERED LATE
                  _MetricSnapshotCard(
                    width: cardWidth,
                    title: 'FILTERED LATE',
                    value: filteredCount.toString(),
                    subtitle: 'matching filters',
                    icon: Icons.filter_alt_rounded,
                    accentColor: const Color(0xFFF59E0B),
                    accentBg: const Color(0xFFFEF3C7),
                  ),
                  const SizedBox(width: 8),

                  // 3. AVG LATE
                  _MetricSnapshotCard(
                    width: cardWidth,
                    title: 'AVG DELAY',
                    value: '${ui.avgLateMinutes}m',
                    subtitle: 'average late',
                    icon: Icons.access_time_filled_rounded,
                    accentColor: const Color(0xFF10B981),
                    accentBg: const Color(0xFFE8FDF2),
                  ),
                  const SizedBox(width: 8),

                  // 4. TOTAL DELAY
                  _MetricSnapshotCard(
                    width: cardWidth,
                    title: 'TOTAL DELAY',
                    value: '${ui.totalLateMinutes}m',
                    subtitle: 'cumulative delay',
                    icon: Icons.hourglass_bottom_rounded,
                    accentColor: const Color(0xFF3B82F6),
                    accentBg: const Color(0xFFEFF6FF),
                  ),
                  if (ui.mostLateName.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    // 5. MOST LATE
                    _MetricSnapshotCard(
                      width: cardWidth * 1.3,
                      title: 'MOST LATE',
                      value: '${ui.mostLateMinutes}m',
                      subtitle: ui.mostLateName,
                      icon: Icons.warning_amber_rounded,
                      accentColor: const Color(0xFFEF4444),
                      accentBg: const Color(0xFFFEE2E2),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _MetricSnapshotCard extends StatelessWidget {
  const _MetricSnapshotCard({
    required this.width,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.accentBg,
  });

  final double width;
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Color accentBg;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 4,
            offset: Offset(0, 1.5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF64748B),
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: accentBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 11, color: accentColor),
              ),
            ],
          ),
          Text(
            value,
            style: portalText(
              fontSize: 16.5,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
              height: 1.1,
            ),
          ),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 8.5,
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
// Late Employee Card (Impressive Shift Timeline Design)
// ---------------------------------------------------------------------------
class _LateEmployeeCard extends StatelessWidget {
  const _LateEmployeeCard({required this.item});

  final LateEmployeeItem item;

  static String? _resolveImageUrl(String? raw) {
    if (raw == null) return null;
    final str = raw.trim();
    if (str.isEmpty || str == 'null') return null;
    if (str.startsWith('http://') || str.startsWith('https://')) {
      return str;
    }
    const baseUrl = 'https://api.timelyhealth.in';
    if (str.startsWith('/')) {
      return '$baseUrl$str';
    }
    return '$baseUrl/$str';
  }

  Color get _severityBg {
    switch (item.severity) {
      case DelaySeverity.minimal:
        return const Color(0xFFE0F2FE);
      case DelaySeverity.minor:
        return const Color(0xFFD1FAE5);
      case DelaySeverity.moderate:
        return const Color(0xFFFEF3C7);
      case DelaySeverity.significant:
        return const Color(0xFFFFEDD5);
      case DelaySeverity.high:
      case DelaySeverity.critical:
        return const Color(0xFFFEE2E2);
    }
  }

  Color get _severityText {
    switch (item.severity) {
      case DelaySeverity.minimal:
        return const Color(0xFF0284C7);
      case DelaySeverity.minor:
        return const Color(0xFF059669);
      case DelaySeverity.moderate:
        return const Color(0xFFD97706);
      case DelaySeverity.significant:
        return const Color(0xFFEA580C);
      case DelaySeverity.high:
      case DelaySeverity.critical:
        return const Color(0xFFDC2626);
    }
  }

  @override
  Widget build(BuildContext context) {
    final photoUrl = _resolveImageUrl(item.checkInImage);
    final isCritical =
        item.severity == DelaySeverity.critical || item.severity == DelaySeverity.high;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCritical
              ? const Color(0xFFFECACA)
              : const Color(0xFFF1F5F9),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isCritical
                ? const Color(0xFFDC2626).withValues(alpha: 0.05)
                : const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Bar: Profile & Delay Capsule
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Modern Squircle Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF26204A), Color(0xFF3F3572)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF26204A).withValues(alpha: 0.18),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  alignment: Alignment.center,
                  child: photoUrl != null
                      ? Image.network(
                          photoUrl,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Text(
                            item.avatarLetter,
                            style: portalText(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          item.avatarLetter,
                          style: portalText(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                ),
                const SizedBox(width: 12),

                // Name, EmpId, and Dept/Role
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: portalText(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                                letterSpacing: 0.1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.employeeId,
                              style: portalText(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF475569),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${item.department} • ${item.designation}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: portalText(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Glowing Delay Pill Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: _severityBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _severityText.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.alarm_rounded,
                        size: 13,
                        color: _severityText,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+${item.lateByMinutes}m',
                        style: portalText(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: _severityText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. Center: Visual Shift Timeline Bridge
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                // Left: Expected time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            size: 12,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'EXPECTED',
                            style: portalText(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF64748B),
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.expectedTime,
                        style: portalText(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        item.shiftType.isNotEmpty
                            ? 'Shift ${item.shiftType}'
                            : 'Standard Shift',
                        style: portalText(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),

                // Center: Visual Arrow / Gap indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x06000000),
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: _severityText,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 12,
                        color: _severityText,
                      ),
                    ],
                  ),
                ),

                // Right: Actual Check-In time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            Icons.login_rounded,
                            size: 12,
                            color: _severityText,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'ACTUAL IN',
                            style: portalText(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: _severityText,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.actualTime,
                        style: portalText(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: _severityText,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '${item.lateByMinutes} min delay',
                        style: portalText(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _severityText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 3. Bottom Strip: Date & Location Tags
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: Row(
              children: [
                // Date Chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 11,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 4.5),
                      Text(
                        item.dateLabel,
                        style: portalText(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 6),

                // Location / Office Chip
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: item.onsite
                          ? const Color(0xFFF0FDF4)
                          : const Color(0xFFFAF5FF),
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                        color: item.onsite
                            ? const Color(0xFFBBF7D0)
                            : const Color(0xFFE9D5FF),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.onsite
                              ? Icons.apartment_rounded
                              : Icons.home_work_outlined,
                          size: 11,
                          color: item.onsite
                              ? const Color(0xFF16A34A)
                              : const Color(0xFF9333EA),
                        ),
                        const SizedBox(width: 4.5),
                        Flexible(
                          child: Text(
                            item.onsite
                                ? (item.officeName.isNotEmpty
                                    ? item.officeName
                                    : 'Onsite')
                                : (item.reason.isNotEmpty
                                    ? item.reason
                                    : 'Work From Home'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: portalText(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: item.onsite
                                  ? const Color(0xFF15803D)
                                  : const Color(0xFF7E22CE),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (item.distance > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.near_me_outlined,
                          size: 10.5,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${item.distance}m',
                          style: portalText(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
