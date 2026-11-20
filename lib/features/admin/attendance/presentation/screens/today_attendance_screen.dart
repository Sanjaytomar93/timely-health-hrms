import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/core/widgets/portal_safe_area.dart';
import 'package:timelay_health/features/admin/attendance/presentation/bloc/today_attendance_cubit.dart';
import 'package:timelay_health/features/admin/attendance/presentation/bloc/today_attendance_state.dart';
import 'package:timelay_health/features/admin/attendance/presentation/models/today_attendance_ui.dart';
import 'package:timelay_health/features/admin/shared/widgets/portal_filter_pickers.dart';
import 'package:timelay_health/features/dashboard/presentation/screens/employee_home_shell.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/employee_bottom_nav.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/home_side_drawer.dart';
import 'package:timelay_health/features/notifications/presentation/widgets/top_notification_button.dart';

class TodayAttendanceScreen extends StatefulWidget {
  const TodayAttendanceScreen({super.key});

  @override
  State<TodayAttendanceScreen> createState() => _TodayAttendanceScreenState();
}

class _TodayAttendanceScreenState extends State<TodayAttendanceScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final TodayAttendanceCubit _cubit;

  int _selectedYear = DateTime.now().year;
  int _selectedMonthIndex = DateTime.now().month;
  String _dateLabel = 'Date';
  String _monthOnly = 'Nov';
  String _defaultMonthAbbr = 'Nov';
  String? _selectedDateString;
  String? _selectedDateEndString;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  String _dept = 'All Departments';
  String _designation = 'All Designations';
  String? _snapshotFilter;

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
    _cubit = TodayAttendanceCubit()..load();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= 300) {
      _cubit.loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchCtrl.dispose();
    _cubit.close();
    super.dispose();
  }

  bool get _dateActive => _selectedDateString != null;
  bool get _monthActive => _monthOnly != _defaultMonthAbbr;
  bool get _deptActive => _dept != 'All Departments';
  bool get _designActive => _designation != 'All Designations';

  List<TodayCheckInItem> _filterRecords(List<TodayCheckInItem> records) {
    final query = _searchCtrl.text.trim().toLowerCase();
    return records.where((item) {
      final matchesQuery = query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          item.employeeId.toLowerCase().contains(query) ||
          item.department.toLowerCase().contains(query) ||
          item.designation.toLowerCase().contains(query);

      final matchesDept = _dept == 'All Departments' ||
          item.department.toLowerCase() == _dept.toLowerCase();
      final matchesDesignation = _designation == 'All Designations' ||
          item.designation.toLowerCase() == _designation.toLowerCase();

      final matchesDate = () {
        if (_selectedDateString == null || _selectedDateString!.isEmpty) {
          return true;
        }
        final d = item.dateString;
        if (d.isEmpty) return false;
        final end = _selectedDateEndString ?? _selectedDateString!;
        return d.compareTo(_selectedDateString!) >= 0 && d.compareTo(end) <= 0;
      }();

      final matchesSnapshot = switch (_snapshotFilter) {
        'active' => item.isActive,
        'onsite' => item.isOnsite,
        'remote' => !item.isOnsite,
        _ => true,
      };

      return matchesQuery &&
          matchesDept &&
          matchesDesignation &&
          matchesDate &&
          matchesSnapshot;
    }).toList();
  }

  Future<void> _reloadWithFilters({bool isRefresh = false}) async {
    if (_selectedDateString != null) {
      final monthStr =
          '$_selectedYear-${_selectedMonthIndex.toString().padLeft(2, '0')}';
      await _cubit.load(
        month: monthStr,
        date: _selectedDateString,
        isRefresh: isRefresh,
      );
    } else if (_monthActive) {
      final monthStr =
          '$_selectedYear-${_selectedMonthIndex.toString().padLeft(2, '0')}';
      await _cubit.load(month: monthStr, date: '', isRefresh: isRefresh);
    } else {
      await _cubit.load(month: '', date: '', isRefresh: isRefresh);
    }
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
    final monthStr =
        '${start.year}-${start.month.toString().padLeft(2, '0')}';

    setState(() {
      _rangeStart = start;
      _rangeEnd = end;
      _selectedYear = start.year;
      _selectedMonthIndex = start.month;
      _selectedDateString = from;
      _selectedDateEndString = to;
      _dateLabel =
          '${PortalFilterPickers.chipDate(start)}-${PortalFilterPickers.chipDate(end)}';
      _monthOnly = PortalFilterPickers.monthAbbr(start.month);
    });
    _cubit.load(month: monthStr, date: from);
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
      subtitle: 'Choose a month to filter check-ins',
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
        _selectedDateEndString = null;
        _rangeStart = null;
        _rangeEnd = null;
      });
      _cubit.load(month: '', date: '');
      return;
    }

    final idx = allMonths.indexOf(picked) + 1;
    setState(() {
      _selectedMonthIndex = idx;
      _monthOnly = PortalFilterPickers.monthAbbr(idx);
      _dateLabel = 'Date';
      _selectedDateString = null;
      _selectedDateEndString = null;
      _rangeStart = null;
      _rangeEnd = null;
    });
    final monthStr = '$_selectedYear-${idx.toString().padLeft(2, '0')}';
    _cubit.load(month: monthStr, date: '');
  }

  Future<void> _pickDept(List<String> items) async {
    final gridItems = items.where((e) => e != 'All Departments').toList();
    final picked = await PortalFilterPickers.showGrid(
      context: context,
      title: 'Select Department',
      subtitle: 'Choose a department to filter check-ins',
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
      subtitle: 'Choose a designation to filter check-ins',
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
      child: BlocBuilder<TodayAttendanceCubit, TodayAttendanceState>(
        builder: (context, state) {
          final ui = state.ui;
          final records = _filterRecords(ui.records);
          final isLoading =
              state is TodayAttendanceLoading && ui.records.isEmpty;
          final isFailure =
              state is TodayAttendanceFailureState && ui.records.isEmpty;

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
            value: SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
            ),
            child: Scaffold(
              key: _scaffoldKey,
              backgroundColor: const Color(0xFFF6F8FB),
              drawer: const HomeSideDrawer(),
              drawerScrimColor: PortalColors.brand.withValues(alpha: 0.28),
              body: PortalSafeArea(
                bottom: false,
                statusBarColor: Colors.white,
                child: Column(
                  children: [
                    _WhiteTopBar(
                      onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        color: const Color(0xFF4F46E5),
                        onRefresh: () => _reloadWithFilters(isRefresh: true),
                        child: ListView(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            _SearchInput(
                              controller: _searchCtrl,
                              onChanged: (v) {
                                setState(() {});
                                _cubit.updateSearch(v);
                              },
                            ),
                            const SizedBox(height: 10),

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
                              onDateClear: () {
                                setState(() {
                                  _dateLabel = 'Date';
                                  _selectedDateString = null;
                                  _selectedDateEndString = null;
                                  _rangeStart = null;
                                  _rangeEnd = null;
                                });
                                _reloadWithFilters();
                              },
                              onMonthClear: () {
                                final now = DateTime.now();
                                setState(() {
                                  _selectedYear = now.year;
                                  _selectedMonthIndex = now.month;
                                  _monthOnly = _defaultMonthAbbr;
                                  _dateLabel = 'Date';
                                  _selectedDateString = null;
                                  _selectedDateEndString = null;
                                  _rangeStart = null;
                                  _rangeEnd = null;
                                });
                                _cubit.load(month: '', date: '');
                              },
                              onDeptClear: () => setState(() {
                                _dept = 'All Departments';
                              }),
                              onDesignClear: () => setState(() {
                                _designation = 'All Designations';
                              }),
                            ),
                            const SizedBox(height: 14),
                            _LiveSnapshotSection(
                              ui: ui,
                              selectedFilter: _snapshotFilter,
                              onFilterTap: (filter) {
                                setState(() {
                                  _snapshotFilter =
                                      _snapshotFilter == filter ? null : filter;
                                });
                              },
                            ),
                            const SizedBox(height: 18),

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
                                    Icons.fingerprint_rounded,
                                    color: PortalColors.brand,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Employee Check-ins',
                                  style: portalText(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEF2FF),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${records.length} of ${ui.totalCheckIn} Records',
                                    style: portalText(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF4F46E5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            if (isLoading)
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 48),
                                alignment: Alignment.center,
                                child: const CircularProgressIndicator(
                                  color: Color(0xFF4F46E5),
                                  strokeWidth: 2.5,
                                ),
                              )
                            else if (isFailure)
                              Container(
                                padding: const EdgeInsets.all(28),
                                margin:
                                    const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: const Color(0xFFFEE2E2)),
                                ),
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.error_outline_rounded,
                                      size: 36,
                                      color: Color(0xFFEF4444),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      (state as TodayAttendanceFailureState)
                                          .message,
                                      textAlign: TextAlign.center,
                                      style: portalText(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    ElevatedButton.icon(
                                      onPressed: () => _cubit.load(),
                                      icon: const Icon(Icons.refresh_rounded,
                                          size: 16),
                                      label: const Text('Try Again'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF4F46E5),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else if (records.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(32),
                                alignment: Alignment.center,
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.search_off_rounded,
                                      size: 48,
                                      color: PortalColors.muted
                                          .withValues(alpha: 0.5),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'No check-in records found',
                                      style: portalText(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: PortalColors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              ...records.map(
                                (record) => _TodayCheckInCard(record: record),
                              ),

                            if (state.isFetchingMore) ...[
                              const SizedBox(height: 12),
                              const Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: Color(0xFF4F46E5),
                                  ),
                                ),
                              ),
                            ],

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
                      TextSpan(text: "Today's "),
                      TextSpan(
                        text: 'Attendance',
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
                  'Monitoring & Activity Tracker',
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 5,
            offset: const Offset(0, 1.5),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
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
              controller: controller,
              onChanged: onChanged,
              style: portalText(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: PortalColors.heading,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: 'Search employee or ID...',
                hintStyle: portalText(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF94A3B8),
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
                Icons.cancel_rounded,
                size: 16,
                color: Color(0xFF94A3B8),
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
          child: _FilterItemButton(
            icon: Icons.calendar_today_rounded,
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

        Expanded(
          child: _FilterItemButton(
            icon: Icons.calendar_month_outlined,
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

        Expanded(
          child: _FilterItemButton(
            icon: Icons.person_outline_rounded,
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
                  onTap: () {
                    onClear?.call();
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Container(
                      width: 16,
                      height: 16,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: effectiveColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 12,
                        color: effectiveColor,
                      ),
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

class _LiveSnapshotSection extends StatelessWidget {
  const _LiveSnapshotSection({
    required this.ui,
    required this.selectedFilter,
    required this.onFilterTap,
  });

  final TodayAttendanceUi ui;
  final String? selectedFilter;
  final ValueChanged<String?> onFilterTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LIVE SNAPSHOT',
          style: portalText(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF64748B),
            letterSpacing: 0.6,
          ),
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
                  _MetricCard(
                    width: cardWidth,
                    title: 'TOTAL CHECK-IN',
                    value: '${ui.totalCheckIn}',
                    subtitle: 'Checked in today',
                    icon: Icons.how_to_reg_rounded,
                    accentColor: PortalColors.brand,
                    accentBg: PortalColors.brandTint,
                    selected: selectedFilter == null,
                    onTap: () => onFilterTap(null),
                  ),
                  const SizedBox(width: 8),
                  _MetricCard(
                    width: cardWidth,
                    title: 'ACTIVE WORKING',
                    value: '${ui.activeWorking}',
                    subtitle: 'Currently working',
                    icon: Icons.person_rounded,
                    accentColor: const Color(0xFF10B981),
                    accentBg: const Color(0xFFECFDF5),
                    selected: selectedFilter == 'active',
                    onTap: () => onFilterTap('active'),
                  ),
                  const SizedBox(width: 8),
                  _MetricCard(
                    width: cardWidth,
                    title: 'ONSITE (WFO)',
                    value: '${ui.onsiteCount}',
                    subtitle: 'Working at office',
                    icon: Icons.apartment_rounded,
                    accentColor: const Color(0xFF6366F1),
                    accentBg: const Color(0xFFEEF2FF),
                    selected: selectedFilter == 'onsite',
                    onTap: () => onFilterTap('onsite'),
                  ),
                  const SizedBox(width: 8),
                  _MetricCard(
                    width: cardWidth,
                    title: 'REMOTE (WFH)',
                    value: '${ui.remoteCount}',
                    subtitle: 'Work from home',
                    icon: Icons.home_work_rounded,
                    accentColor: const Color(0xFF8B5CF6),
                    accentBg: const Color(0xFFF5F3FF),
                    selected: selectedFilter == 'remote',
                    onTap: () => onFilterTap('remote'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.width,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.accentBg,
    this.selected = false,
    this.onTap,
  });

  final double width;
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Color accentBg;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: width,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? accentBg : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? accentColor.withValues(alpha: 0.55) : const Color(0xFFE2E8F0),
              width: selected ? 1.4 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 5,
                offset: const Offset(0, 1.5),
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
                        color: selected ? accentColor : const Color(0xFF64748B),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: selected ? Colors.white : accentBg,
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
        ),
      ),
    );
  }
}

class _TodayCheckInCard extends StatelessWidget {
  const _TodayCheckInCard({required this.record});

  final TodayCheckInItem record;

  @override
  Widget build(BuildContext context) {
    final isActive = record.isActive;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showPhotoDialog(context, record),
        borderRadius: BorderRadius.circular(18),
        child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEFF0F6), width: 1.1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: record.isAvatarRed
                      ? const Color(0xFF991B1B)
                      : const Color(0xFF221F4B),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: (record.photoUrl != null && record.photoUrl!.isNotEmpty)
                    ? Image.network(
                        record.photoUrl!,
                        width: 38,
                        height: 38,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Text(
                          record.avatarLetter,
                          style: portalText(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        record.avatarLetter,
                        style: portalText(
                          fontSize: 15,
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
                            record.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: portalText(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF111827),
                              letterSpacing: 0.1,
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
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            record.employeeId,
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
                      '${record.department} • ${record.designation}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: portalText(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFFE8FDF2)
                      : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isActive
                        ? const Color(0xFFB9F5D8)
                        : const Color(0xFFFECACA),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF10B981)
                            : const Color(0xFFDC2626),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isActive ? 'Active' : 'Logged Out',
                      style: portalText(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: isActive
                            ? const Color(0xFF10B981)
                            : const Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Check In',
                        style: portalText(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            record.checkInTime,
                            style: portalText(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Check Out / Total',
                        style: portalText(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 3),
                      if (isActive)
                        Row(
                          children: [
                            Text(
                              '—',
                              style: portalText(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              record.totalHours,
                              style: portalText(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFE11D48),
                              ),
                            ),
                          ],
                        )
                      else
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: const Color(0xFFDBEAFE),
                                ),
                              ),
                              child: Text(
                                record.checkOutTime ?? '',
                                style: portalText(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF2563EB),
                                ),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                record.totalHours,
                                style: portalText(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFD97706),
                                ),
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
          const SizedBox(height: 10),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 2.5,
                ),
                decoration: BoxDecoration(
                  color: record.isOnsite
                      ? const Color(0xFFE8FDF2)
                      : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: record.isOnsite
                        ? const Color(0xFFA7F3D0)
                        : const Color(0xFFBFDBFE),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      record.isOnsite
                          ? Icons.location_on_outlined
                          : Icons.home_outlined,
                      size: 11,
                      color: record.isOnsite
                          ? const Color(0xFF10B981)
                          : const Color(0xFF2563EB),
                    ),
                    const SizedBox(width: 3.5),
                    Text(
                      record.locationMode,
                      style: portalText(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: record.isOnsite
                            ? const Color(0xFF10B981)
                            : const Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
              ),

              if (record.photoVerified || (record.photoUrl != null && record.photoUrl!.isNotEmpty)) ...[
                const SizedBox(width: 6),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showPhotoDialog(context, record),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      width: 26,
                      height: 22,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFFA7F3D0),
                          width: 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image_outlined,
                        size: 13,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ),
                ),
              ],

              const Spacer(),

              Text(
                record.dateLabel,
                style: portalText(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ],
      ),
        ),
      ),
    );
  }
}

Widget _buildTodayPlaceholderPhoto({String label = 'No photo'}) {
  return Container(
    color: const Color(0xFF1E293B),
    alignment: Alignment.center,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.face_retouching_natural_rounded,
          size: 36,
          color: Color(0xFF94A3B8),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: portalText(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF94A3B8),
          ),
        ),
      ],
    ),
  );
}

Widget _buildLabeledPhoto({
  required String title,
  required String? imageUrl,
  required String emptyLabel,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: portalText(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF0F172A),
        ),
      ),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 160,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: imageUrl != null && imageUrl.isNotEmpty
              ? InteractiveViewer(
                  clipBehavior: Clip.none,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 160,
                    loadingBuilder: (ctx, child, progress) {
                      if (progress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: progress.expectedTotalBytes != null
                              ? progress.cumulativeBytesLoaded /
                                  (progress.expectedTotalBytes ?? 1)
                              : null,
                          color: const Color(0xFF4F46E5),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) =>
                        _buildTodayPlaceholderPhoto(label: emptyLabel),
                  ),
                )
              : _buildTodayPlaceholderPhoto(label: emptyLabel),
        ),
      ),
    ],
  );
}

void _showPhotoDialog(BuildContext context, TodayCheckInItem record) {
  final checkInUrl = record.checkInImage ?? record.photoUrl;
  final checkOutUrl = record.checkOutImage;

  showDialog(
    context: context,
    builder: (dialogCtx) => Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(dialogCtx).height * 0.85,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: record.isAvatarRed
                          ? const Color(0xFF991B1B)
                          : const Color(0xFF221F4B),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      record.avatarLetter,
                      style: portalText(
                        fontSize: 15,
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
                                record.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: portalText(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0F172A),
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
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                record.employeeId,
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
                          '${record.department} • ${record.designation}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: portalText(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Material(
                    color: const Color(0xFFF1F5F9),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.pop(dialogCtx),
                      child: const SizedBox(
                        width: 30,
                        height: 30,
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildLabeledPhoto(
                title: 'Check-in Image',
                imageUrl: checkInUrl,
                emptyLabel: 'No check-in image',
              ),
              const SizedBox(height: 12),
              _buildLabeledPhoto(
                title: 'Checkout Image',
                imageUrl: checkOutUrl,
                emptyLabel: 'No checkout image',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 7,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PUNCH STATUS',
                            style: portalText(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            record.isActive ? 'Active Working' : 'Logged Out',
                            style: portalText(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: record.isActive
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFDC2626),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 7,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOTAL LOGGED',
                            style: portalText(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            record.totalHours,
                            style: portalText(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF2563EB),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogCtx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E1B4B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Close',
                  style: portalText(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
