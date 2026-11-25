import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_system_ui.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/core/widgets/portal_safe_area.dart';
import 'package:timelay_health/core/widgets/shimmer.dart';
import 'package:timelay_health/features/admin/employees/presentation/bloc/employee_list_cubit.dart';
import 'package:timelay_health/features/admin/employees/presentation/bloc/employee_list_state.dart';
import 'package:timelay_health/features/admin/employees/presentation/models/employee_list_ui.dart';
import 'package:timelay_health/features/dashboard/presentation/screens/employee_home_shell.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/employee_bottom_nav.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/home_side_drawer.dart';
import 'package:timelay_health/features/notifications/presentation/widgets/top_notification_button.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchCtrl = TextEditingController();
  late final EmployeeListCubit _cubit;

  String _dept = 'All Departments';
  String _designation = 'All Designations';

  /// 'all' | 'ACTIVE' | 'INACTIVE' | 'departments' | 'locations'
  String _statFilter = 'all';
  String? _location;

  @override
  void initState() {
    super.initState();
    _cubit = EmployeeListCubit()..load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _cubit.close();
    super.dispose();
  }

  List<EmployeeListItem> _filterList(List<EmployeeListItem> employees) {
    final q = _searchCtrl.text.trim().toLowerCase();
    return employees.where((e) {
      final matchQ = q.isEmpty ||
          e.name.toLowerCase().contains(q) ||
          e.employeeId.toLowerCase().contains(q) ||
          e.phone.contains(q);
      final matchDept =
          _dept == 'All Departments' || e.department == _dept;
      final matchDes =
          _designation == 'All Designations' || e.role == _designation;
      final matchStatus = _statFilter == 'all' ||
          _statFilter == 'departments' ||
          _statFilter == 'locations' ||
          e.status == _statFilter;
      final matchLoc = _location == null || e.location == _location;
      return matchQ && matchDept && matchDes && matchStatus && matchLoc;
    }).toList();
  }

  void _onStatTap(String key, EmployeeListUi ui) {
    if (key == 'departments' || key == 'locations') {
      return;
    }
    setState(() {
      _statFilter = key;
      if (key == 'all') {
        _dept = 'All Departments';
        _designation = 'All Designations';
        _location = null;
      } else {
        _location = null;
      }
    });
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
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: active
                                        ? accent.withValues(alpha: 0.35)
                                        : PortalColors.border,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item,
                                        style: portalText(
                                          fontSize: 13.5,
                                          fontWeight: active
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          color: active
                                              ? accent
                                              : PortalColors.heading,
                                        ),
                                      ),
                                    ),
                                    if (active)
                                      Icon(
                                        Icons.check_circle_rounded,
                                        size: 18,
                                        color: accent,
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
    if (picked != null) {
      onPick(picked);
    }
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
                  child: BlocBuilder<EmployeeListCubit, EmployeeListState>(
                    builder: (context, state) {
                      if (state is EmployeeListLoading &&
                          state.ui.employees.isEmpty) {
                        return const _LoadingView();
                      }

                      if (state is EmployeeListFailureState &&
                          state.ui.employees.isEmpty) {
                        return _ErrorView(
                          message: state.message,
                          onRetry: () => _cubit.load(),
                        );
                      }

                      final ui = state.ui;
                      final allEmployees = ui.employees;

                      final deptsSet = <String>{
                        for (final e in allEmployees)
                          if (e.department.isNotEmpty && e.department != 'General')
                            e.department,
                      };
                      final departments = [
                        'All Departments',
                        ...deptsSet.toList()..sort(),
                      ];
                      if (!departments.contains(_dept)) {
                        _dept = 'All Departments';
                      }

                      final desigSet = <String>{
                        for (final e in allEmployees)
                          if (e.role.isNotEmpty && e.role != 'Staff')
                            e.role,
                      };
                      final designations = [
                        'All Designations',
                        ...desigSet.toList()..sort(),
                      ];
                      if (!designations.contains(_designation)) {
                        _designation = 'All Designations';
                      }

                      final list = _filterList(allEmployees);

                      return RefreshIndicator(
                        color: PortalColors.brand,
                        onRefresh: () => _cubit.load(isRefresh: true),
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                          children: [
                            _SearchField(
                              controller: _searchCtrl,
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 10),
                            _FilterRow(
                              dept: _dept,
                              designation: _designation,
                              onDeptTap: () => _pickFromSheet(
                                title: 'Departments',
                                subtitle: 'Filter employees by department',
                                icon: Icons.apartment_rounded,
                                accent: PortalColors.brand,
                                accentTint: PortalColors.brandTint,
                                items: departments,
                                selected: _dept,
                                onPick: (v) => setState(() => _dept = v),
                              ),
                              onDeptClear: () => setState(
                                () => _dept = 'All Departments',
                              ),
                              onDesignationTap: () => _pickFromSheet(
                                title: 'Designations',
                                subtitle: 'Filter employees by designation',
                                icon: Icons.badge_outlined,
                                accent: PortalColors.brandLight,
                                accentTint: PortalColors.brandTint,
                                items: designations,
                                selected: _designation,
                                onPick: (v) => setState(() => _designation = v),
                              ),
                              onDesignationClear: () => setState(
                                () => _designation = 'All Designations',
                              ),
                            ),
                            const SizedBox(height: 14),
                            _StatsRow(
                              stats: ui.stats,
                              selected: _statFilter,
                              onTap: (key) => _onStatTap(key, ui),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'SHOWING ${list.length} RECORDS',
                                  style: portalText(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: PortalColors.muted,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                if (_dept != 'All Departments' ||
                                    _designation != 'All Designations' ||
                                    _statFilter != 'all' ||
                                    _location != null ||
                                    _searchCtrl.text.isNotEmpty)
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _dept = 'All Departments';
                                        _designation = 'All Designations';
                                        _statFilter = 'all';
                                        _location = null;
                                        _searchCtrl.clear();
                                      });
                                    },
                                    child: Text(
                                      'Reset Filters',
                                      style: portalText(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: PortalColors.brand,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            if (list.isEmpty)
                              _EmptyView(
                                onReset: () {
                                  setState(() {
                                    _dept = 'All Departments';
                                    _designation = 'All Designations';
                                    _statFilter = 'all';
                                    _location = null;
                                    _searchCtrl.clear();
                                  });
                                },
                              )
                            else
                              for (final emp in list) ...[
                                _EmployeeCard(item: emp),
                                const SizedBox(height: 10),
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
            currentIndex: 0,
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
    return const AdminListShimmer(statCount: 3, cardCount: 6);
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
              'Failed to load employees',
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
                  'Employee List',
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
                  'Team directory & active staff',
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

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.stats,
    required this.selected,
    required this.onTap,
  });

  final EmployeeListStats stats;
  final String selected;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final cards = [
      (
        'all',
        _StatCard(
          label: 'TOTAL EMPLOYEES',
          value: '${stats.total}',
          subtitle: 'all registered staff',
          icon: Icons.groups_rounded,
          iconColor: const Color(0xFF3B82F6),
          iconBg: const Color(0xFFE8F0FE),
          selected: selected == 'all',
          onTap: () => onTap('all'),
        ),
      ),
      (
        'ACTIVE',
        _StatCard(
          label: 'ACTIVE EMPLOYEES',
          value: '${stats.active}',
          subtitle: 'currently working',
          icon: Icons.person_rounded,
          iconColor: const Color(0xFF22C55E),
          iconBg: const Color(0xFFE8F8EF),
          selected: selected == 'ACTIVE',
          onTap: () => onTap('ACTIVE'),
        ),
      ),
      (
        'INACTIVE',
        _StatCard(
          label: 'INACTIVE EMPLOYEES',
          value: '${stats.inactive}',
          subtitle: 'hidden from reports',
          icon: Icons.person_off_rounded,
          iconColor: const Color(0xFFEF4444),
          iconBg: const Color(0xFFFDECEC),
          selected: selected == 'INACTIVE',
          onTap: () => onTap('INACTIVE'),
        ),
      ),
      (
        'departments',
        _StatCard(
          label: 'DEPARTMENTS',
          value: '${stats.departments}',
          subtitle: 'unique dept. units',
          icon: Icons.work_outline_rounded,
          iconColor: const Color(0xFF6366F1),
          iconBg: const Color(0xFFEEF0FF),
          selected: false,
          onTap: null,
        ),
      ),
      (
        'locations',
        _StatCard(
          label: 'WORK LOCATIONS',
          value: '${stats.workLocations}',
          subtitle: 'assigned office sites',
          icon: Icons.location_on_rounded,
          iconColor: const Color(0xFF14B8A6),
          iconBg: const Color(0xFFE6F7F5),
          selected: false,
          onTap: null,
        ),
      ),
    ];

    final screenW = MediaQuery.sizeOf(context).width;
    const gap = 10.0;
    final cardW = (screenW - 32 - (gap * 2)) / 3;

    return SizedBox(
      height: 102,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cards.length,
        separatorBuilder: (_, _) => const SizedBox(width: gap),
        itemBuilder: (_, i) => SizedBox(
          width: cardW,
          child: cards[i].$2,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? PortalColors.brand : PortalColors.border,
              width: selected ? 1.4 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: PortalColors.brand.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: portalText(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: PortalColors.muted,
                        letterSpacing: 0.3,
                        height: 1.25,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon, size: 15, color: iconColor),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                value,
                style: portalText(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: PortalColors.heading,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: portalText(
                  fontSize: 10,
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

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final hasText = controller.text.isNotEmpty;
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasText
              ? PortalColors.brand.withValues(alpha: 0.35)
              : PortalColors.border,
          width: hasText ? 1.3 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: PortalColors.brand.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: PortalColors.brandGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(9),
              boxShadow: [
                BoxShadow(
                  color: PortalColors.brand.withValues(alpha: 0.22),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.search_rounded,
              size: 17,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: portalText(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: PortalColors.heading,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: 'Search by employee name, ID or phone...',
                hintStyle: portalText(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: PortalColors.muted,
                ),
              ),
            ),
          ),
          if (hasText)
            GestureDetector(
              onTap: () {
                controller.clear();
                onChanged('');
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(left: 6),
                decoration: const BoxDecoration(
                  color: PortalColors.brandTint,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: PortalColors.brand,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.dept,
    required this.designation,
    required this.onDeptTap,
    required this.onDeptClear,
    required this.onDesignationTap,
    required this.onDesignationClear,
  });

  final String dept;
  final String designation;
  final VoidCallback onDeptTap;
  final VoidCallback onDeptClear;
  final VoidCallback onDesignationTap;
  final VoidCallback onDesignationClear;

  @override
  Widget build(BuildContext context) {
    final isDeptActive = dept != 'All Departments';
    final isDesigActive = designation != 'All Designations';

    return Row(
      children: [
        Expanded(
          child: _FilterCard(
            label: 'DEPARTMENT',
            value: isDeptActive ? dept : 'All',
            icon: Icons.apartment_rounded,
            isActive: isDeptActive,
            onTap: onDeptTap,
            onClear: onDeptClear,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _FilterCard(
            label: 'DESIGNATION',
            value: isDesigActive ? designation : 'All',
            icon: Icons.badge_outlined,
            isActive: isDesigActive,
            onTap: onDesignationTap,
            onClear: onDesignationClear,
          ),
        ),
      ],
    );
  }
}

class _FilterCard extends StatelessWidget {
  const _FilterCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.isActive,
    required this.onTap,
    required this.onClear,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 52,
          padding: const EdgeInsets.fromLTRB(10, 7, 8, 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: isActive
                ? LinearGradient(
                    colors: [
                      PortalColors.brand.withValues(alpha: 0.08),
                      PortalColors.brandLight.withValues(alpha: 0.06),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isActive ? null : Colors.white,
            border: Border.all(
              color: isActive
                  ? PortalColors.brand.withValues(alpha: 0.45)
                  : PortalColors.border,
              width: isActive ? 1.4 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: PortalColors.brand
                    .withValues(alpha: isActive ? 0.10 : 0.04),
                blurRadius: isActive ? 12 : 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: isActive
                      ? const LinearGradient(
                          colors: PortalColors.brandGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isActive ? null : PortalColors.brandTint,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color:
                                PortalColors.brand.withValues(alpha: 0.22),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: 15,
                  color: isActive ? Colors.white : PortalColors.brand,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: portalText(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                        color: isActive
                            ? PortalColors.brandLight
                            : PortalColors.muted,
                        letterSpacing: 0.35,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: portalText(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isActive
                            ? PortalColors.brand
                            : PortalColors.heading,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              if (isActive)
                GestureDetector(
                  onTap: onClear,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: PortalColors.brand.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: PortalColors.brand,
                    ),
                  ),
                )
              else
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: PortalColors.background,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
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

class _EmployeeCard extends StatelessWidget {
  const _EmployeeCard({required this.item});

  final EmployeeListItem item;

  void _showDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => _EmployeeDetailBottomSheet(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isActive = item.status == 'ACTIVE';

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => _showDetails(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            border: Border.all(color: PortalColors.border),
            boxShadow: [
              BoxShadow(
                color: PortalColors.brand.withValues(alpha: 0.07),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isActive
                          ? const [PortalColors.green, Color(0xFF34D399)]
                          : const [PortalColors.red, Color(0xFFF87171)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 11),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                gradient: const LinearGradient(
                                  colors: PortalColors.brandGradient,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: PortalColors.brand
                                        .withValues(alpha: 0.22),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: item.profileImageUrl.isNotEmpty
                                  ? Image.network(
                                      item.profileImageUrl,
                                      width: 44,
                                      height: 44,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => Center(
                                        child: Text(
                                          item.initials,
                                          style: portalText(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Center(
                                      child: Text(
                                        item.initials,
                                        style: portalText(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 11),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: portalText(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: PortalColors.heading,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${item.role} • ${item.department}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: portalText(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                      color: PortalColors.brandLight,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: PortalColors.brandTint,
                                      borderRadius: BorderRadius.circular(6),
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
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? PortalColors.greenTint
                                    : PortalColors.redTint,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isActive
                                      ? PortalColors.green
                                          .withValues(alpha: 0.25)
                                      : PortalColors.red
                                          .withValues(alpha: 0.25),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? PortalColors.green
                                          : PortalColors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    item.status,
                                    style: portalText(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                      color: isActive
                                          ? PortalColors.green
                                          : PortalColors.red,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
                          decoration: BoxDecoration(
                            color: PortalColors.background,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _InfoCell(
                                      label: 'PHONE',
                                      value: item.phone,
                                      icon: Icons.phone_outlined,
                                    ),
                                  ),
                                  Expanded(
                                    child: _InfoCell(
                                      label: 'SALARY',
                                      value: item.salary,
                                      icon: Icons.payments_outlined,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: _InfoCell(
                                      label: 'SHIFT & OFF',
                                      value: item.shiftOff,
                                      icon: Icons.schedule_outlined,
                                    ),
                                  ),
                                  Expanded(
                                    child: _InfoCell(
                                      label: 'JOINED',
                                      value: item.joiningDate,
                                      icon: Icons.event_outlined,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: PortalColors.brandTint,
                                borderRadius: BorderRadius.circular(7),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.location_on_rounded,
                                size: 12,
                                color: PortalColors.brand,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                item.location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: portalText(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: PortalColors.secondaryText,
                                ),
                              ),
                            ),
                            Text(
                              item.trackingId,
                              style: portalText(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: PortalColors.muted,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(
                              Icons.chevron_right_rounded,
                              size: 16,
                              color: PortalColors.brandLight,
                            ),
                          ],
                        ),
                      ],
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
}

class _InfoCell extends StatelessWidget {
  const _InfoCell({
    required this.label,
    required this.value,
    this.icon,
  });

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 13, color: PortalColors.brandLight),
          const SizedBox(width: 5),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: portalText(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                  color: PortalColors.muted,
                  letterSpacing: 0.35,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: portalText(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: PortalColors.heading,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmployeeDetailBottomSheet extends StatelessWidget {
  const _EmployeeDetailBottomSheet({required this.item});

  final EmployeeListItem item;

  @override
  Widget build(BuildContext context) {
    final isActive = item.status == 'ACTIVE';

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.78,
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
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: PortalColors.brandGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: item.profileImageUrl.isNotEmpty
                          ? Image.network(
                              item.profileImageUrl,
                              width: 52,
                              height: 52,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Center(
                                child: Text(
                                  item.initials,
                                  style: portalText(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                item.initials,
                                style: portalText(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
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
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: PortalColors.heading,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: PortalColors.brandTint,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item.employeeId,
                                style: portalText(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: PortalColors.brand,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${item.role} • ${item.department}',
                          style: portalText(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: PortalColors.brandLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? PortalColors.greenTint
                          : PortalColors.redTint,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.status,
                      style: portalText(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color:
                            isActive ? PortalColors.green : PortalColors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: PortalColors.border),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  _SectionCard(
                    title: 'CONTACT & PERSONAL DETAILS',
                    icon: Icons.person_outline_rounded,
                    rows: [
                      _DetailRow(label: 'Phone Number', value: item.phone),
                      if (item.email.isNotEmpty)
                        _DetailRow(label: 'Email', value: item.email),
                      if (item.employmentType.isNotEmpty)
                        _DetailRow(
                          label: 'Employment Type',
                          value: item.employmentType.toUpperCase(),
                        ),
                      if (item.gender.isNotEmpty)
                        _DetailRow(label: 'Gender', value: item.gender),
                      if (item.dob.isNotEmpty && item.dob != 'N/A')
                        _DetailRow(label: 'Date of Birth', value: item.dob),
                      if (item.address.isNotEmpty)
                        _DetailRow(label: 'Address', value: item.address),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _SectionCard(
                    title: 'EMPLOYMENT & COMPENSATION',
                    icon: Icons.badge_outlined,
                    rows: [
                      _DetailRow(label: 'Designation / Role', value: item.role),
                      _DetailRow(label: 'Department', value: item.department),
                      _DetailRow(
                        label: 'Salary / Compensation',
                        value: item.salary,
                      ),
                      _DetailRow(label: 'Shift & Off', value: item.shiftOff),
                      _DetailRow(
                        label: 'Joining Date',
                        value: item.joiningDate,
                      ),
                      _DetailRow(label: 'Work Location', value: item.location),
                      _DetailRow(label: 'Tracking ID', value: item.trackingId),
                    ],
                  ),
                  if (item.lastCheckInAddress.isNotEmpty ||
                      item.lastCheckOutAddress.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _SectionCard(
                      title: 'LAST LOCATION ACTIVITY',
                      icon: Icons.location_on_outlined,
                      rows: [
                        if (item.lastCheckInAddress.isNotEmpty)
                          _DetailRow(
                            label: 'Last Check-In',
                            value: item.lastCheckInAddress,
                          ),
                        if (item.lastCheckOutAddress.isNotEmpty)
                          _DetailRow(
                            label: 'Last Check-Out',
                            value: item.lastCheckOutAddress,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.rows,
  });

  final String title;
  final IconData icon;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PortalColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: PortalColors.brand),
              const SizedBox(width: 7),
              Text(
                title,
                style: portalText(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: PortalColors.muted,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: PortalColors.border),
          const SizedBox(height: 6),
          ...rows,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: portalText(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: PortalColors.muted,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: portalText(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: PortalColors.heading,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
