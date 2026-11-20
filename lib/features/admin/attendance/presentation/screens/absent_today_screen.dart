import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_system_ui.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/core/widgets/portal_safe_area.dart';
import 'package:timelay_health/features/admin/attendance/presentation/bloc/absent_today_cubit.dart';
import 'package:timelay_health/features/admin/attendance/presentation/bloc/absent_today_state.dart';
import 'package:timelay_health/features/admin/attendance/presentation/models/absent_today_ui.dart';
import 'package:timelay_health/features/admin/shared/widgets/portal_filter_pickers.dart';
import 'package:timelay_health/features/dashboard/presentation/screens/employee_home_shell.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/employee_bottom_nav.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/home_side_drawer.dart';
import 'package:timelay_health/features/notifications/presentation/widgets/top_notification_button.dart';

class AbsentTodayScreen extends StatefulWidget {
  const AbsentTodayScreen({super.key});

  @override
  State<AbsentTodayScreen> createState() => _AbsentTodayScreenState();
}

class _AbsentTodayScreenState extends State<AbsentTodayScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchCtrl = TextEditingController();
  late final AbsentTodayCubit _cubit;

  int _selectedYear = DateTime.now().year;
  int _selectedMonthIndex = DateTime.now().month;
  String _dateLabel = 'Date';
  String _monthOnly = 'Nov';
  String _defaultMonthAbbr = 'Nov';
  String? _selectedDateString;
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
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonthIndex = now.month;
    const months = [
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
    _defaultMonthAbbr = months[now.month - 1];
    _monthOnly = _defaultMonthAbbr;
    _cubit = AbsentTodayCubit()..load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _cubit.close();
    super.dispose();
  }

  bool get _dateActive => _selectedDateString != null;
  bool get _monthActive => _monthOnly != _defaultMonthAbbr;
  bool get _deptActive => _dept != 'All Departments';
  bool get _designActive => _designation != 'All Designations';

  List<AbsentEmployeeItem> _filterRecords(List<AbsentEmployeeItem> records) {
    final query = _searchCtrl.text.trim().toLowerCase();
    return records.where((item) {
      final matchesQuery = query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          item.employeeId.toLowerCase().contains(query) ||
          item.department.toLowerCase().contains(query) ||
          item.designation.toLowerCase().contains(query);

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

    final start = picked.start;
    final end = picked.end;
    final from = PortalFilterPickers.ymd(start);
    final to = PortalFilterPickers.ymd(end);

    setState(() {
      _rangeStart = start;
      _rangeEnd = end;
      _selectedYear = start.year;
      _selectedMonthIndex = start.month;
      _selectedDateString = from;
      _dateLabel =
          '${PortalFilterPickers.chipDate(start)}-${PortalFilterPickers.chipDate(end)}';
      _monthOnly = PortalFilterPickers.monthAbbr(start.month);
    });
    _cubit.load(fromDate: from, toDate: to);
  }

  Future<void> _pickMonthOnly() async {
    final now = DateTime.now();
    final availableMonths = allMonths.sublist(0, now.month);
    final selected = availableMonths.firstWhere(
      (m) => m.toLowerCase().startsWith(_monthOnly.toLowerCase()),
      orElse: () => availableMonths.last,
    );
    final picked = await PortalFilterPickers.showGrid(
      context: context,
      title: 'Select Month',
      subtitle: 'Choose a month to filter absences',
      icon: Icons.calendar_month_rounded,
      allLabel: 'Current Month',
      items: availableMonths,
      selected: selected,
      highlightItem: availableMonths.last,
    );
    if (picked == null || !mounted) return;

    if (picked == 'Current Month') {
      setState(() {
        _selectedYear = now.year;
        _selectedMonthIndex = now.month;
        _monthOnly = _defaultMonthAbbr;
        _dateLabel = 'Date';
        _selectedDateString = null;
        _rangeStart = null;
        _rangeEnd = null;
      });
      _cubit.load();
      return;
    }

    final idx = allMonths.indexOf(picked) + 1;
    final lastDay = DateTime(_selectedYear, idx + 1, 0).day;
    final fromDate = '$_selectedYear-${idx.toString().padLeft(2, '0')}-01';
    final toDate =
        '$_selectedYear-${idx.toString().padLeft(2, '0')}-${lastDay.toString().padLeft(2, '0')}';
    setState(() {
      _selectedMonthIndex = idx;
      _monthOnly = PortalFilterPickers.monthAbbr(idx);
      _dateLabel = 'Date';
      _selectedDateString = null;
      _rangeStart = null;
      _rangeEnd = null;
    });
    _cubit.load(fromDate: fromDate, toDate: toDate);
  }

  Future<void> _pickDept(List<String> items) async {
    final gridItems = items.where((e) => e != 'All Departments').toList();
    final picked = await PortalFilterPickers.showGrid(
      context: context,
      title: 'Select Department',
      subtitle: 'Choose a department to filter absences',
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
      subtitle: 'Choose a designation to filter absences',
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
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<AbsentTodayCubit, AbsentTodayState>(
        builder: (context, state) {
          final ui = state.ui;
          final records = _filterRecords(ui.records);
          final isLoading = state is AbsentTodayLoading && ui.records.isEmpty;
          final isFailure = state is AbsentTodayFailureState && ui.records.isEmpty;

          final effectiveDepts = [
            'All Departments',
            ...ui.departments.isNotEmpty
                ? ui.departments
                : departments.where((d) => d != 'All Departments'),
          ];

          final effectiveDesignations = [
            'All Designations',
            ...ui.designations.isNotEmpty
                ? ui.designations
                : designations.where((d) => d != 'All Designations'),
          ];

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
                    // White Navbar (Leaves Screen Style)
                    _WhiteTopBar(
                      onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
                    ),

                    // Main Body Content
                    Expanded(
                      child: RefreshIndicator(
                        color: const Color(0xFF4F46E5),
                        onRefresh: () => _cubit.load(isRefresh: true),
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            // Search bar
                            _SearchInput(
                              controller: _searchCtrl,
                              onChanged: (v) {
                                setState(() {});
                                _cubit.updateSearch(v);
                              },
                            ),
                            const SizedBox(height: 10),

                            // Filter chips row with cross (clear) icons
                            _FilterChipsRow(
                              dateLabel: _dateLabel,
                              monthLabel: _monthOnly,
                              deptLabel: _deptActive ? _dept : 'Dept',
                              designLabel:
                                  _designActive ? _designation : 'Design',
                              dateActive: _dateActive,
                              monthActive: _monthActive,
                              deptActive: _deptActive,
                              designActive: _designActive,
                              onDateTap: _pickDate,
                              onMonthTap: _pickMonthOnly,
                              onDeptTap: () => _pickDept(effectiveDepts),
                              onDesignTap: () =>
                                  _pickDesignation(effectiveDesignations),
                              onDateClear: () => setState(() {
                                _dateLabel = 'Date';
                                _selectedDateString = null;
                                _rangeStart = null;
                                _rangeEnd = null;
                                _cubit.load();
                              }),
                              onMonthClear: () => setState(() {
                                _monthOnly = _defaultMonthAbbr;
                                _rangeStart = null;
                                _rangeEnd = null;
                                _cubit.load();
                              }),
                              onDeptClear: () => setState(() {
                                _dept = 'All Departments';
                              }),
                              onDesignClear: () => setState(() {
                                _designation = 'All Designations';
                              }),
                            ),
                            const SizedBox(height: 14),

                            // SNAPSHOT SUMMARY Section (3 Cards visible in one line, rest on scroll)
                            _SnapshotSummarySection(
                              ui: ui,
                              filteredCount: records.length,
                            ),
                            const SizedBox(height: 18),

                            // Absent Employees Section Header
                            Row(
                              children: [
                                const SizedBox(width: 4),
                                Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: PortalColors.brandTint,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.person_off_rounded,
                                    color: PortalColors.brand,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Absent Employees',
                                  style: portalText(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Loading state
                            if (isLoading)
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 48),
                                alignment: Alignment.center,
                                child: const CircularProgressIndicator(
                                  color: Color(0xFF4F46E5),
                                  strokeWidth: 2.5,
                                ),
                              )
                            // Failure state
                            else if (isFailure)
                              Container(
                                padding: const EdgeInsets.all(28),
                                margin: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFFEE2E8)),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.cloud_off_rounded,
                                      size: 40,
                                      color: Color(0xFFDC2626),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      (state as AbsentTodayFailureState).message,
                                      textAlign: TextAlign.center,
                                      style: portalText(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    ElevatedButton(
                                      onPressed: () => _cubit.load(isRefresh: true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF4F46E5),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 18,
                                          vertical: 9,
                                        ),
                                      ),
                                      child: Text(
                                        'Retry',
                                        style: portalText(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            // Empty state
                            else if (records.isEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 40),
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
                                      'No absent employees found',
                                      style: portalText(
                                        fontSize: 13,
                                        color: const Color(0xFF64748B),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            // Records List
                            else
                              ...records.map(
                                (item) => _AbsentEmployeeCard(item: item),
                              ),

                            const SizedBox(height: 20),
                          ],
                        ),
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
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// White Navbar like Leaves Screen
// ---------------------------------------------------------------------------
class _WhiteTopBar extends StatelessWidget {
  const _WhiteTopBar({
    required this.onMenuTap,
  });

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
                RichText(
                  text: TextSpan(
                    style: portalText(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: PortalColors.heading,
                      letterSpacing: 0.1,
                      height: 1.2,
                    ),
                    children: const [
                      TextSpan(text: 'Absent '),
                      TextSpan(
                        text: 'Today',
                        style: TextStyle(
                          color: Color(0xFF4F46E5),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Absence & Leave Monitoring',
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
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 6,
            offset: Offset(0, 1.5),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Icon(Icons.search, size: 17, color: Color(0xFF94A3B8)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: portalText(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                hintText: 'Search absent employee, ID...',
                hintStyle: portalText(
                  fontSize: 12,
                  color: const Color(0xFF94A3B8),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
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
// Filter Chips Row (Exact same width as Search Bar, 4 equal columns)
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
            activeBg: const Color(0xFFEFF6FF),
            activeColor: const Color(0xFF2563EB),
            activeBorder: const Color(0xFFBFDBFE),
            onTap: onDateTap,
            onClear: onDateClear,
          ),
        ),
        const SizedBox(width: 6),

        // 2. Month filter (shows only month)
        Expanded(
          child: _FilterItemButton(
            icon: Icons.calendar_month_rounded,
            label: monthLabel,
            hasDropdown: true,
            active: monthActive,
            activeBg: const Color(0xFFEFF6FF),
            activeColor: const Color(0xFF2563EB),
            activeBorder: const Color(0xFFBFDBFE),
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
            activeBg: const Color(0xFFEFF6FF),
            activeColor: const Color(0xFF2563EB),
            activeBorder: const Color(0xFFBFDBFE),
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
            activeBg: const Color(0xFFEFF6FF),
            activeColor: const Color(0xFF2563EB),
            activeBorder: const Color(0xFFBFDBFE),
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
// Snapshot Summary Section (3 cards visible at once in one line, rest on scroll)
// ---------------------------------------------------------------------------
class _SnapshotSummarySection extends StatelessWidget {
  const _SnapshotSummarySection({
    required this.ui,
    required this.filteredCount,
  });

  final AbsentTodayUi ui;
  final int filteredCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        const SizedBox(height: 8),
        // Row 1: 2 cards
        Row(
          children: [
            Expanded(
              child: _MetricSnapshotCard(
                title: 'TOTAL ABSENCES',
                value: ui.totalAbsences.toString(),
                subtitle: 'active in view',
                icon: Icons.person_remove_rounded,
                accentColor: const Color(0xFFEF4444),
                accentBg: const Color(0xFFFEE2E2),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricSnapshotCard(
                title: 'FILTERED ABSENCES',
                value: filteredCount.toString(),
                subtitle: 'matching filters',
                icon: Icons.filter_alt_rounded,
                accentColor: const Color(0xFFF59E0B),
                accentBg: const Color(0xFFFEF3C7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Row 2: 2 cards
        Row(
          children: [
            Expanded(
              child: _MetricSnapshotCard(
                title: 'ACTIVE EMPLOYEES',
                value: ui.activeEmployees.toString(),
                subtitle: 'active employees',
                icon: Icons.people_alt_rounded,
                accentColor: const Color(0xFF10B981),
                accentBg: const Color(0xFFE8FDF2),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricSnapshotCard(
                title: 'AVG ABSENT RATE',
                value: ui.avgAbsentRate,
                subtitle: 'average rate',
                icon: Icons.percent_rounded,
                accentColor: const Color(0xFF2563EB),
                accentBg: const Color(0xFFEFF6FF),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricSnapshotCard extends StatelessWidget {
  const _MetricSnapshotCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.accentBg,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Color accentBg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF64748B),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: accentBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: 15,
                  color: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: portalText(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
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
// Absent Employee Card
// ---------------------------------------------------------------------------
class _AbsentEmployeeCard extends StatelessWidget {
  const _AbsentEmployeeCard({required this.item});

  final AbsentEmployeeItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFF0F6), width: 1.1),
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
          // Top Row: Avatar, Name + ID, ABSENT Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Circle Avatar with brand gradient
              Container(
                width: 40,
                height: 40,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: PortalColors.brandGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: PortalColors.brand.withValues(alpha: 0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 1.5),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: (item.photoUrl != null && item.photoUrl!.isNotEmpty)
                    ? Image.network(
                        item.photoUrl!,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Text(
                          item.avatarLetter,
                          style: portalText(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        item.avatarLetter,
                        style: portalText(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
              ),
              const SizedBox(width: 10),

              // Info Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + Employee ID badge
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: portalText(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                              letterSpacing: 0.1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5.5,
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
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),

                    // Designation
                    Text(
                      item.designation,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: portalText(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: PortalColors.brand,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // ABSENT Badge with red indicator dot
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 2.5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFECACA), width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'ABSENT',
                      style: portalText(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFDC2626),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Bottom Info Row: Department and Date
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                // Department
                const Icon(
                  Icons.apartment_rounded,
                  size: 13,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    item.department,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: portalText(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF475569),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Date & Full Day
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 12,
                  color: Color(0xFF94A3B8),
                ),
                const SizedBox(width: 4),
                Text(
                  '${item.dateLabel} • ${item.leaveType}',
                  style: portalText(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
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
