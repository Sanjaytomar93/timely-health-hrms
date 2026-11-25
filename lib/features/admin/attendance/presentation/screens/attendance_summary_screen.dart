import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_system_ui.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/core/widgets/portal_safe_area.dart';
import 'package:timelay_health/core/widgets/shimmer.dart';
import 'package:timelay_health/features/admin/attendance/presentation/bloc/attendance_summary_cubit.dart';
import 'package:timelay_health/features/admin/attendance/presentation/bloc/attendance_summary_state.dart';
import 'package:timelay_health/features/admin/attendance/presentation/models/attendance_summary_ui.dart';
import 'package:timelay_health/features/dashboard/presentation/screens/employee_home_shell.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/employee_bottom_nav.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/home_side_drawer.dart';
import 'package:timelay_health/features/notifications/presentation/widgets/top_notification_button.dart';

class AttendanceSummaryScreen extends StatefulWidget {
  const AttendanceSummaryScreen({super.key});

  @override
  State<AttendanceSummaryScreen> createState() =>
      _AttendanceSummaryScreenState();
}

class _AttendanceSummaryScreenState extends State<AttendanceSummaryScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final AttendanceSummaryCubit _cubit;

  DateTime _selectedDate = DateTime.now();
  String _monthLabel = '';
  String _dept = 'All Departments';
  String _designation = 'All Designations';

  int _displayedCount = 15;
  bool _isLoadingMore = false;

  static const List<String> _months = [
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

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    final now = DateTime.now();
    _selectedDate = now;
    _monthLabel = '${_months[now.month - 1]} ${now.year}';
    final monthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    _cubit = AttendanceSummaryCubit(initialMonth: monthKey)..load();
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore) {
      final allFiltered = _filterRoster(_cubit.state.ui.roster);
      if (_displayedCount < allFiltered.length) {
        setState(() {
          _isLoadingMore = true;
        });
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() {
              _displayedCount += 15;
              _isLoadingMore = false;
            });
          }
        });
      }
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

  bool get _deptActive => _dept != 'All Departments';
  bool get _designActive => _designation != 'All Designations';

  List<AttendanceRosterItem> _filterRoster(List<AttendanceRosterItem> roster) {
    final q = _searchCtrl.text.trim().toLowerCase();
    return roster.where((e) {
      final matchQ = q.isEmpty ||
          e.name.toLowerCase().contains(q) ||
          e.employeeId.toLowerCase().contains(q);
      final matchDept =
          _dept == 'All Departments' || e.department == _dept;
      final matchDes =
          _designation == 'All Designations' || e.role == _designation;
      return matchQ && matchDept && matchDes;
    }).toList();
  }

  Future<void> _pickMonth() async {
    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => _MonthPickerBottomSheet(
        initialDate: _selectedDate,
      ),
    );
    if (picked == null || !mounted) return;

    _selectedDate = picked;
    final monthKey =
        '${picked.year}-${picked.month.toString().padLeft(2, '0')}';
    setState(() {
      _monthLabel = '${_months[picked.month - 1]} ${picked.year}';
      _displayedCount = 15;
    });
    _cubit.load(month: monthKey);
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
    return BlocProvider.value(
      value: _cubit,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: PortalSystemUi.lightStatusBar,
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: const Color(0xFFF3F2F7),
          drawer: const HomeSideDrawer(),
          drawerScrimColor: PortalColors.brand.withValues(alpha: 0.28),
          body: PortalSafeArea(
            bottom: false,
            statusBarColor: PortalColors.surface,
            child: Column(
              children: [
                _TopBar(
                  onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
                ),
                Expanded(
                  child: BlocBuilder<AttendanceSummaryCubit, AttendanceSummaryState>(
                    builder: (context, state) {
                      if (state is AttendanceSummaryLoading &&
                          state.ui.roster.isEmpty) {
                        return const _LoadingView();
                      }

                      if (state is AttendanceSummaryFailureState &&
                          state.ui.roster.isEmpty) {
                        return _ErrorView(
                          message: state.message,
                          onRetry: () => _cubit.load(),
                        );
                      }

                      final ui = state.ui;

                      final deptsSet = <String>{
                        ...ui.meta.departments,
                        for (final item in ui.roster)
                          if (item.department.isNotEmpty &&
                              item.department != 'General')
                            item.department,
                      };
                      final departments = [
                        'All Departments',
                        ...deptsSet.toList()..sort(),
                      ];
                      if (!departments.contains(_dept)) {
                        _dept = 'All Departments';
                      }

                      final desigSet = <String>{
                        ...ui.meta.designations,
                        for (final item in ui.roster)
                          if (item.role.isNotEmpty && item.role != 'Staff')
                            item.role,
                      };
                      final designations = [
                        'All Designations',
                        ...desigSet.toList()..sort(),
                      ];
                      if (!designations.contains(_designation)) {
                        _designation = 'All Designations';
                      }

                      final list = _filterRoster(ui.roster);
                      final displayedList =
                          list.take(_displayedCount).toList();

                      return RefreshIndicator(
                        color: PortalColors.brand,
                        onRefresh: () => _cubit.load(isRefresh: true),
                        child: ListView(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
                          children: [
                            _SearchField(
                              controller: _searchCtrl,
                              onChanged: (_) =>
                                  setState(() => _displayedCount = 15),
                            ),
                            const SizedBox(height: 10),
                            _FilterChips(
                              monthLabel: _monthLabel,
                              deptLabel:
                                  _deptActive ? _dept : 'Department',
                              designLabel:
                                  _designActive ? _designation : 'Designation',
                              deptActive: _deptActive,
                              designActive: _designActive,
                              onMonthTap: _pickMonth,
                              onDeptTap: () => _pickFromSheet(
                                title: 'Departments',
                                subtitle: 'Filter roster by department',
                                icon: Icons.apartment_rounded,
                                accent: PortalColors.brand,
                                accentTint: PortalColors.brandTint,
                                items: departments,
                                selected: _dept,
                                onPick: (v) => setState(() {
                                  _dept = v;
                                  _displayedCount = 15;
                                }),
                              ),
                              onDesignTap: () => _pickFromSheet(
                                title: 'Designations',
                                subtitle: 'Filter roster by designation',
                                icon: Icons.badge_outlined,
                                accent: PortalColors.brandLight,
                                accentTint: PortalColors.brandTint,
                                items: designations,
                                selected: _designation,
                                onPick: (v) => setState(() {
                                  _designation = v;
                                  _displayedCount = 15;
                                }),
                              ),
                              onClearDept: () => setState(() {
                                _dept = 'All Departments';
                                _displayedCount = 15;
                              }),
                              onClearDesign: () => setState(() {
                                _designation = 'All Designations';
                                _displayedCount = 15;
                              }),
                            ),
                            const SizedBox(height: 12),
                            _StatsRow(stats: ui.stats),
                            const SizedBox(height: 14),
                            if (list.isEmpty)
                              _EmptyView(
                                onReset: () {
                                  setState(() {
                                    _dept = 'All Departments';
                                    _designation = 'All Designations';
                                    _searchCtrl.clear();
                                    _displayedCount = 15;
                                  });
                                },
                              )
                            else ...[
                              for (final item in displayedList) ...[
                                _RosterCard(item: item),
                                const SizedBox(height: 10),
                              ],
                              if (_isLoadingMore)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  child: Center(
                                    child: SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: PortalColors.brand,
                                        strokeWidth: 2.2,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
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
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const AdminListShimmer(statCount: 4, cardCount: 5);
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: PortalColors.redTint,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.error_outline_rounded,
                size: 28,
                color: PortalColors.red,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Failed to load attendance summary',
              style: portalText(
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
                color: PortalColors.heading,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: portalText(
                fontSize: 12.5,
                color: PortalColors.muted,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: PortalColors.brand,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: PortalColors.brandTint,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.people_outline_rounded,
              size: 24,
              color: PortalColors.brand,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No employees found',
            style: portalText(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: PortalColors.heading,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try adjusting your search or filters.',
            style: portalText(
              fontSize: 12,
              color: PortalColors.muted,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onReset,
            child: Text(
              'Reset all filters',
              style: portalText(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: PortalColors.brand,
              ),
            ),
          ),
        ],
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
                  'Attendance Summary',
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
                  'Tracking & Inspection Mode',
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

class _SearchField extends StatelessWidget {
  const _SearchField({
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
              style: portalText(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: PortalColors.heading,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: 'Search by ID, employee name...',
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
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.monthLabel,
    required this.deptLabel,
    required this.designLabel,
    required this.deptActive,
    required this.designActive,
    required this.onMonthTap,
    required this.onDeptTap,
    required this.onDesignTap,
    required this.onClearDept,
    required this.onClearDesign,
  });

  final String monthLabel;
  final String deptLabel;
  final String designLabel;
  final bool deptActive;
  final bool designActive;
  final VoidCallback onMonthTap;
  final VoidCallback onDeptTap;
  final VoidCallback onDesignTap;
  final VoidCallback onClearDept;
  final VoidCallback onClearDesign;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Chip(
            icon: Icons.calendar_month_rounded,
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
            onClear: onClearDept,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _Chip(
            icon: Icons.badge_outlined,
            label: designLabel,
            active: designActive,
            onTap: onDesignTap,
            onClear: onClearDesign,
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
    return Material(
      color: active ? PortalColors.brandTint : Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 35,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active
                  ? PortalColors.brand.withValues(alpha: 0.35)
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
              if (active && onClear != null)
                GestureDetector(
                  onTap: onClear,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 18,
                    height: 18,
                    margin: const EdgeInsets.only(left: 3),
                    decoration: BoxDecoration(
                      color: PortalColors.brand.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.close_rounded,
                      size: 12,
                      color: PortalColors.brand,
                    ),
                  ),
                )
              else
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 15,
                  color: active ? PortalColors.brand : PortalColors.muted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.stats});

  final AttendanceSummaryStats stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'TOTAL EMPLOYEES',
                value: '${stats.totalEmployees}',
                subtitle: 'active in view',
                icon: Icons.groups_rounded,
                iconColor: const Color(0xFF2563EB),
                iconBg: const Color(0xFFEFF6FF),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                title: 'AVG WORK DAYS',
                value: stats.avgWorkDays.toStringAsFixed(1),
                subtitle: 'days per employee',
                icon: Icons.calendar_today_rounded,
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
                title: 'TOTAL ONSITE',
                value: '${stats.totalOnsite}',
                subtitle: 'office check-ins',
                icon: Icons.apartment_rounded,
                iconColor: const Color(0xFF0D9488),
                iconBg: const Color(0xFFCCFBF1),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                title: 'TOTAL LATE DAYS',
                value: '${stats.totalLateDays}',
                subtitle: 'grace exceeded',
                icon: Icons.access_time_rounded,
                iconColor: const Color(0xFFD97706),
                iconBg: const Color(0xFFFEF3C7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _StatCard(
          title: 'TOTAL OVERTIME',
          value: stats.totalOvertime,
          subtitle: 'accumulated overtime',
          icon: Icons.more_time_rounded,
          iconColor: Colors.white,
          iconBg: Colors.white.withValues(alpha: 0.2),
          isAppColor: true,
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
    this.isAppColor = false,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final bool isAppColor;

  @override
  Widget build(BuildContext context) {
    if (isAppColor) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: PortalColors.brandGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.22),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: PortalColors.brand.withValues(alpha: 0.28),
              blurRadius: 12,
              offset: const Offset(0, 3.5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2.5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          title,
                          style: portalText(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Text(
                    value,
                    style: portalText(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.3,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.trending_up_rounded,
                        size: 13,
                        color: Colors.greenAccent.shade200,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        subtitle,
                        style: portalText(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.more_time_rounded,
                size: 24,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

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
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: 15,
                  color: iconColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: portalText(
              fontSize: 18,
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

class _RosterCard extends StatelessWidget {
  const _RosterCard({required this.item});

  final AttendanceRosterItem item;

  (Color, Color) get _badgeColors => switch (item.badge) {
        AttendanceBadge.fullDay => (PortalColors.greenTint, PortalColors.green),
        AttendanceBadge.noAttendance =>
          (PortalColors.redTint, PortalColors.red),
        AttendanceBadge.singlePunch =>
          (const Color(0xFFF3EEFF), const Color(0xFF8B5CF6)),
        AttendanceBadge.earlyLeave =>
          (PortalColors.orangeTint, PortalColors.orange),
      };

  @override
  Widget build(BuildContext context) {
    final badge = _badgeColors;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PortalColors.border),
        boxShadow: [
          BoxShadow(
            color: PortalColors.brand.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: PortalColors.brandGradient,
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: PortalColors.brand.withValues(alpha: 0.22),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  item.initials,
                  style: portalText(
                    fontSize: 12,
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
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: PortalColors.brandTint,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            item.employeeId,
                            style: portalText(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: PortalColors.brand,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.role} - ${item.department}',
                      style: portalText(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: PortalColors.brandLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: badge.$1,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  item.badgeLabel,
                  style: portalText(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: badge.$2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, thickness: 1, color: PortalColors.border),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MetricBox(
                  label: 'PRESENT',
                  value: '${item.present}',
                  valueColor: PortalColors.green,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _MetricBox(
                  label: 'LATE',
                  value: '${item.late}',
                  valueColor: PortalColors.heading,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _MetricBox(
                  label: 'ON-SITE',
                  value: '${item.onSite}',
                  valueColor: const Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _MetricBox(
                  label: 'REMOTE',
                  value: '${item.remote}',
                  valueColor: PortalColors.heading,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: _MetricBox(
                  label: 'HALF DAY',
                  value: '${item.halfDay}',
                  valueColor: PortalColors.heading,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _MetricBox(
                  label: 'FULL DAY',
                  value: '${item.fullDay}',
                  valueColor: PortalColors.heading,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _MetricBox(
                  label: 'OT',
                  value: item.otHours.toStringAsFixed(1),
                  valueColor: const Color(0xFF8B5CF6),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _MetricBox(
                  label: 'WORK DAYS',
                  value: item.workDays.toStringAsFixed(1),
                  valueColor: PortalColors.heading,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricBox extends StatelessWidget {
  const _MetricBox({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 3),
      decoration: BoxDecoration(
        color: PortalColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: portalText(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: PortalColors.muted,
              letterSpacing: 0.15,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: portalText(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthPickerBottomSheet extends StatefulWidget {
  const _MonthPickerBottomSheet({required this.initialDate});

  final DateTime initialDate;

  @override
  State<_MonthPickerBottomSheet> createState() =>
      _MonthPickerBottomSheetState();
}

class _MonthPickerBottomSheetState extends State<_MonthPickerBottomSheet> {
  late int _year;

  static const List<String> _monthNames = [
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

  static const List<String> _fullMonthNames = [
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

  @override
  void initState() {
    super.initState();
    _year = widget.initialDate.year;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isSelectedYear = widget.initialDate.year == _year;

    return SafeArea(
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
                  child: const Icon(
                    Icons.calendar_month_rounded,
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
                        'Select Month',
                        style: portalText(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: PortalColors.heading,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'Choose month for attendance summary',
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
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: PortalColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: PortalColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => setState(() => _year--),
                    icon: const Icon(Icons.chevron_left_rounded, size: 24),
                    color: PortalColors.heading,
                    splashRadius: 20,
                  ),
                  Text(
                    '$_year',
                    style: portalText(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: PortalColors.heading,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _year++),
                    icon: const Icon(Icons.chevron_right_rounded, size: 24),
                    color: PortalColors.heading,
                    splashRadius: 20,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 12,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.2,
              ),
              itemBuilder: (ctx, index) {
                final monthNum = index + 1;
                final isSelected =
                    isSelectedYear && widget.initialDate.month == monthNum;
                final isCurrent =
                    now.year == _year && now.month == monthNum;

                return Material(
                  color: isSelected
                      ? PortalColors.brand
                      : (isCurrent ? PortalColors.brandTint : Colors.white),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop(DateTime(_year, monthNum));
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? PortalColors.brand
                              : (isCurrent
                                  ? PortalColors.brand.withValues(alpha: 0.5)
                                  : PortalColors.border),
                          width: isSelected || isCurrent ? 1.4 : 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _monthNames[index],
                            style: portalText(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : (isCurrent
                                      ? PortalColors.brand
                                      : PortalColors.heading),
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            _fullMonthNames[index],
                            style: portalText(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.8)
                                  : PortalColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pop(DateTime(now.year, now.month));
              },
              icon: const Icon(Icons.today_rounded, size: 16),
              label: Text(
                'Current Month (${_monthNames[now.month - 1]} ${now.year})',
                style: portalText(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: PortalColors.brand,
                side: BorderSide(
                  color: PortalColors.brand.withValues(alpha: 0.35),
                ),
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
