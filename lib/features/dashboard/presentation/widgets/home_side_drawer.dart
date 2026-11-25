import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:timelay_health/core/routes/app_routes.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/admin/leaves/data/datasources/admin_leave_remote_datasource.dart';
import 'package:timelay_health/features/auth/data/auth_session.dart';
import 'package:timelay_health/features/auth/data/auth_sign_out.dart';
import 'package:timelay_health/features/auth/domain/entities/employee.dart';
import 'package:timelay_health/features/dashboard/presentation/screens/employee_home_shell.dart';
import 'package:timelay_health/features/op/dashboard/presentation/screens/op_shell_navigator.dart';

class _OpMenuItem {
  const _OpMenuItem({
    required this.permission,
    required this.title,
    required this.route,
  });

  final String permission;
  final String title;
  final String route;
}

const _opMenuCatalog = <_OpMenuItem>[
  _OpMenuItem(
    permission: 'op_dashboard_view',
    title: 'OP Dashboard',
    route: AppRoutes.opDashboard,
  ),
  _OpMenuItem(
    permission: 'op_patient_records_view',
    title: 'Walkin OP',
    route: AppRoutes.opWalkin,
  ),
  _OpMenuItem(
    permission: 'op_bookings_view',
    title: 'Online Bookings',
    route: AppRoutes.opOnlineBookings,
  ),
  _OpMenuItem(
    permission: 'op_referral_management_view',
    title: 'Referral Management',
    route: AppRoutes.opReferralManagement,
  ),
  _OpMenuItem(
    permission: 'op_referral_bookings_view',
    title: 'Referral Bookings',
    route: AppRoutes.opReferralBookings,
  ),
  _OpMenuItem(
    permission: 'op_appointment_slots_view',
    title: 'Appointment Slots',
    route: AppRoutes.opAppointmentSlots,
  ),
  _OpMenuItem(
    permission: 'op_doctors_view',
    title: 'Doctors',
    route: AppRoutes.opDoctors,
  ),
  _OpMenuItem(
    permission: 'op_services_view',
    title: 'Services',
    route: AppRoutes.opServices,
  ),
  _OpMenuItem(
    permission: 'op_revenue_analytics_view',
    title: 'Revenue Analytics',
    route: AppRoutes.opRevenueAnalytics,
  ),
];

class HomeSideDrawer extends StatefulWidget {
  const HomeSideDrawer({super.key});

  @override
  State<HomeSideDrawer> createState() => _HomeSideDrawerState();
}

class _HomeSideDrawerState extends State<HomeSideDrawer> {
  final Set<String> _expanded = {};
  bool _initializedRoute = false;
  int _pendingLeaveCount = 0;

  @override
  void initState() {
    super.initState();
    if (AuthSession.currentEmployee?.isAdmin ?? false) {
      _loadPendingLeaveCount();
    }
  }

  Future<void> _loadPendingLeaveCount() async {
    try {
      final leaves = await AdminLeaveRemoteDataSource().getLeaves();
      final count = leaves.where((m) {
        final s = m.status.trim().toLowerCase();
        return s.contains('pending') || s.contains('await') || s.isEmpty;
      }).length;
      if (!mounted) return;
      setState(() => _pendingLeaveCount = count);
    } catch (_) {}
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initializedRoute) {
      _initializedRoute = true;
      final currentRoute = ModalRoute.of(context)?.settings.name ?? '';
      final isHome = currentRoute == AppRoutes.home ||
          currentRoute == AppRoutes.adminDashboard ||
          currentRoute == '/' ||
          currentRoute.isEmpty;
      if (currentRoute == AppRoutes.attendanceSummary ||
          currentRoute == AppRoutes.attendanceRecords ||
          currentRoute == AppRoutes.todayAttendance ||
          currentRoute == AppRoutes.absentToday ||
          currentRoute == AppRoutes.lateToday ||
          currentRoute == AppRoutes.workRoster ||
          (isHome && EmployeeHomeShell.tabIndex.value == 1)) {
        _expanded.add('attendance');
      } else if (currentRoute == AppRoutes.employeeList) {
        _expanded.add('employees');
      } else if (currentRoute == AppRoutes.leaves ||
          currentRoute == AppRoutes.leaveList) {
        _expanded.add('requests');
      } else if (currentRoute == AppRoutes.adminShift ||
          currentRoute == AppRoutes.adminExpense ||
          currentRoute == AppRoutes.payrollDashboard ||
          currentRoute == AppRoutes.employeePayroll) {
        _expanded.add('admin');
      } else if (currentRoute == AppRoutes.opManagement ||
          currentRoute == AppRoutes.opDashboard ||
          currentRoute == AppRoutes.opWalkin ||
          currentRoute == AppRoutes.opOnlineBookings ||
          currentRoute == AppRoutes.opReferralManagement ||
          currentRoute == AppRoutes.opReferralBookings ||
          currentRoute == AppRoutes.opAppointmentSlots ||
          currentRoute == AppRoutes.opDoctors ||
          currentRoute == AppRoutes.opServices ||
          currentRoute == AppRoutes.opRevenueAnalytics) {
        _expanded.add('op');
      } else if (currentRoute == AppRoutes.events ||
          currentRoute == AppRoutes.myEvents) {
        _expanded.add('event');
      }
    }
  }

  void _toggle(String id) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_expanded.contains(id)) {
        _expanded.remove(id);
      } else {
        _expanded
          ..remove('employees')
          ..remove('attendance')
          ..remove('requests')
          ..remove('admin')
          ..remove('op')
          ..remove('event');
        _expanded.add(id);
      }
    });
  }

  static const _opRoutes = {
    AppRoutes.opManagement,
    AppRoutes.opDashboard,
    AppRoutes.opWalkin,
    AppRoutes.opOnlineBookings,
    AppRoutes.opReferralManagement,
    AppRoutes.opReferralBookings,
    AppRoutes.opAppointmentSlots,
    AppRoutes.opDoctors,
    AppRoutes.opServices,
    AppRoutes.opRevenueAnalytics,
  };

  Future<void> _open({String? route, String? soonLabel}) async {
    HapticFeedback.lightImpact();
    final messenger = ScaffoldMessenger.maybeOf(context);
    final navigator = Navigator.of(context);
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '';

    final isHomeActive = currentRoute == AppRoutes.home ||
        currentRoute == AppRoutes.adminDashboard ||
        currentRoute == '/' ||
        currentRoute.isEmpty;

    if (route != null &&
        _opRoutes.contains(route) &&
        OpShellNavigator.isActive) {
      navigator.pop();
      final tab = OpShellNavigator.tabFromRoute(route);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        OpShellNavigator.openTab(tab);
      });
      return;
    }

    await Future.delayed(const Duration(milliseconds: 130));
    if (!mounted) return;

    if ((route != null && currentRoute == route) ||
        (route == AppRoutes.adminDashboard && isHomeActive) ||
        (route == AppRoutes.home && isHomeActive)) {
      navigator.pop();
      return;
    }

    if (route == AppRoutes.adminDashboard || route == AppRoutes.home) {
      navigator.pop();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        EmployeeHomeShell.goToDashboard(context);
      });
      return;
    }

    navigator.pop();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (soonLabel != null) {
        messenger?.showSnackBar(
          SnackBar(
            content: Text('$soonLabel — coming soon'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      if (route != null) {
        const subRoutes = {
          AppRoutes.attendanceSummary,
          AppRoutes.attendanceRecords,
          AppRoutes.todayAttendance,
          AppRoutes.absentToday,
          AppRoutes.lateToday,
          AppRoutes.employeeList,
          AppRoutes.leaveList,
          AppRoutes.leaves,
          AppRoutes.workRoster,
          AppRoutes.adminShift,
          AppRoutes.payrollDashboard,
          AppRoutes.adminExpense,
          AppRoutes.events,
          AppRoutes.myEvents,
          AppRoutes.visits,
          AppRoutes.payslips,
          AppRoutes.expense,
          AppRoutes.issues,
          AppRoutes.letters,
          AppRoutes.holidayCalendar,
          AppRoutes.profile,
          AppRoutes.digitalLeads,
          AppRoutes.locationManagement,
          AppRoutes.campManagement,
          ..._opRoutes,
        };

        if (currentRoute.isNotEmpty &&
            subRoutes.contains(currentRoute) &&
            subRoutes.contains(route)) {
          navigator.pushReplacementNamed(route);
        } else {
          navigator.pushNamed(route);
        }
      }
    });
  }

  Future<void> _handleSignOut() async {
    HapticFeedback.lightImpact();
    final navigator = Navigator.of(context, rootNavigator: true);
    await AuthSignOut.run();
    navigator.pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
  }

  Future<void> _openHomeTab(int tab) async {
    HapticFeedback.lightImpact();
    Navigator.of(context).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      EmployeeHomeShell.goToTab(context, tab);
    });
  }

  List<_OpMenuItem> _opItemsFor(Employee? employee, {required bool isAdmin}) {
    if (isAdmin) return _opMenuCatalog;
    if (employee == null) return const [];
    return _opMenuCatalog
        .where((item) => employee.hasPermission(item.permission))
        .toList();
  }

  List<Widget> _opSection({
    required String currentRoute,
    required List<_OpMenuItem> opItems,
  }) {
    if (opItems.isEmpty) return const [];
    return [
      _ExpandableMenuCard(
        title: 'OP Management',
        subtitle: 'Outpatient management',
        icon: Icons.local_hospital_rounded,
        iconBg: const Color(0xFFEFF6FF),
        iconColor: const Color(0xFF2563EB),
        expanded: _expanded.contains('op'),
        onToggle: () => _toggle('op'),
        children: [
          for (final item in opItems)
            _SubTile(
              title: item.title,
              isSelected: currentRoute == item.route ||
                  (item.route == AppRoutes.opDashboard &&
                      currentRoute == AppRoutes.opManagement),
              onTap: () => _open(route: item.route),
            ),
        ],
      ),
    ];
  }

  List<Widget> _adminMenuItems({
    required String currentRoute,
    required bool isHomeActive,
  }) {
    return [
      const _SectionHeader(
        title: 'MANAGEMENT',
        badgeLabel: 'Core',
        badgeBg: PortalColors.brandTint,
        badgeTextColor: PortalColors.brand,
      ),
      const SizedBox(height: 8),
      _MenuCard(
        title: 'Dashboard',
        subtitle: 'Overview & stats',
        icon: Icons.grid_view_rounded,
        iconBg: PortalColors.brand,
        iconColor: Colors.white,
        isSelected: isHomeActive,
        onTap: () => _open(route: AppRoutes.adminDashboard),
      ),
      _ExpandableMenuCard(
        title: 'Employees',
        subtitle: 'Team directory',
        icon: Icons.people_alt_outlined,
        iconBg: PortalColors.brandTint,
        iconColor: PortalColors.brand,
        expanded: _expanded.contains('employees'),
        onToggle: () => _toggle('employees'),
        children: [
          _SubTile(
            title: 'Employee List',
            isSelected: currentRoute == AppRoutes.employeeList,
            onTap: () => _open(route: AppRoutes.employeeList),
          ),
        ],
      ),
      _ExpandableMenuCard(
        title: 'Attendance',
        subtitle: 'Daily & records',
        icon: Icons.calendar_today_rounded,
        iconBg: PortalColors.brandTint,
        iconColor: PortalColors.brand,
        badge: Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            color: Color(0xFF10B981),
            shape: BoxShape.circle,
          ),
        ),
        expanded: _expanded.contains('attendance'),
        onToggle: () => _toggle('attendance'),
        children: [
          _SubTile(
            title: 'Attendance Summary',
            isSelected: currentRoute == AppRoutes.attendanceSummary,
            onTap: () => _open(route: AppRoutes.attendanceSummary),
          ),
          _SubTile(
            title: 'Attendance Records',
            isSelected: currentRoute == AppRoutes.attendanceRecords,
            onTap: () => _open(route: AppRoutes.attendanceRecords),
          ),
          _SubTile(
            title: 'Today Attendance',
            isSelected: currentRoute == AppRoutes.todayAttendance,
            onTap: () => _open(route: AppRoutes.todayAttendance),
          ),
          _SubTile(
            title: 'Absent Today',
            isSelected: currentRoute == AppRoutes.absentToday,
            onTap: () => _open(route: AppRoutes.absentToday),
          ),
          _SubTile(
            title: 'Late Today',
            isSelected: currentRoute == AppRoutes.lateToday,
            onTap: () => _open(route: AppRoutes.lateToday),
          ),
        ],
      ),
      _ExpandableMenuCard(
        title: 'Requests',
        subtitle: 'Leave requests',
        icon: Icons.article_outlined,
        iconBg: const Color(0xFFFEF3C7),
        iconColor: const Color(0xFFD97706),
        badge: _pendingLeaveCount > 0
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFFDE68A),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  '$_pendingLeaveCount pending',
                  style: portalText(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFB45309),
                  ),
                ),
              )
            : null,
        expanded: _expanded.contains('requests'),
        onToggle: () => _toggle('requests'),
        children: [
          _SubTile(
            title: 'Leave List',
            isSelected: currentRoute == AppRoutes.leaveList,
            onTap: () => _open(route: AppRoutes.leaveList),
          ),
        ],
      ),
      _ExpandableMenuCard(
        title: 'Admin',
        subtitle: 'Shift & settings',
        icon: Icons.admin_panel_settings_outlined,
        iconBg: PortalColors.brandTint,
        iconColor: PortalColors.brand,
        expanded: _expanded.contains('admin'),
        onToggle: () => _toggle('admin'),
        children: [
          _SubTile(
            title: 'Payroll Dashboard',
            isSelected: currentRoute == AppRoutes.payrollDashboard,
            onTap: () => _open(route: AppRoutes.payrollDashboard),
          ),
          _SubTile(
            title: 'Payroll',
            isSelected: currentRoute == AppRoutes.employeePayroll,
            onTap: () => _open(route: AppRoutes.employeePayroll),
          ),
          _SubTile(
            title: 'Expenses',
            isSelected: currentRoute == AppRoutes.adminExpense,
            onTap: () => _open(route: AppRoutes.adminExpense),
          ),
          _SubTile(
            title: 'Shift Management',
            isSelected: currentRoute == AppRoutes.adminShift,
            onTap: () => _open(route: AppRoutes.adminShift),
          ),
        ],
      ),
      const SizedBox(height: 16),
      const _SectionHeader(
        title: 'CLINICAL & OPS',
        badgeLabel: 'Healthcare',
        badgeBg: Color(0xFFECFDF5),
        badgeTextColor: Color(0xFF059669),
      ),
      const SizedBox(height: 8),
      ..._opSection(
        currentRoute: currentRoute,
        opItems: _opMenuCatalog,
      ),
      if (AuthSession.campActivated)
        _MenuCard(
          title: 'Camp Management',
          subtitle: 'Camps & patients',
          icon: Icons.medical_services_outlined,
          iconBg: const Color(0xFFFFF1F2),
          iconColor: const Color(0xFFE11D48),
          isSelected: currentRoute == AppRoutes.campManagement,
          onTap: () => _open(route: AppRoutes.campManagement),
        ),
      _MenuCard(
        title: 'Holidays',
        subtitle: 'Company calendar',
        icon: Icons.calendar_month_rounded,
        iconBg: PortalColors.brandTint,
        iconColor: PortalColors.brand,
        isSelected: currentRoute == AppRoutes.holidayCalendar,
        onTap: () => _open(route: AppRoutes.holidayCalendar),
      ),
      _MenuCard(
        title: 'Digital Leads',
        subtitle: 'Lead tracking',
        icon: Icons.filter_alt_outlined,
        iconBg: PortalColors.brandTint,
        iconColor: PortalColors.brand,
        isSelected: currentRoute == AppRoutes.digitalLeads,
        onTap: () => _open(route: AppRoutes.digitalLeads),
      ),
      _ExpandableMenuCard(
        title: 'Event',
        subtitle: 'Company & personal',
        icon: Icons.event_rounded,
        iconBg: const Color(0xFFFEF3C7),
        iconColor: const Color(0xFFD97706),
        expanded: _expanded.contains('event'),
        onToggle: () => _toggle('event'),
        children: [
          _SubTile(
            title: 'Events',
            isSelected: currentRoute == AppRoutes.events,
            onTap: () => _open(route: AppRoutes.events),
          ),
          _SubTile(
            title: 'My Events',
            isSelected: currentRoute == AppRoutes.myEvents,
            onTap: () => _open(route: AppRoutes.myEvents),
          ),
        ],
      ),
      _MenuCard(
        title: 'Location Management',
        subtitle: 'Office & geo-fencing',
        icon: Icons.location_on_outlined,
        iconBg: PortalColors.brandTint,
        iconColor: PortalColors.brand,
        isSelected: currentRoute == AppRoutes.locationManagement,
        onTap: () => _open(route: AppRoutes.locationManagement),
      ),
      _MenuCard(
        title: 'Logout',
        subtitle: 'Sign out of your account',
        icon: Icons.logout_rounded,
        iconBg: const Color(0xFFFFF1F2),
        iconColor: const Color(0xFFE11D48),
        onTap: _handleSignOut,
      ),
    ];
  }

  List<Widget> _employeeMenuItems({
    required String currentRoute,
    required bool isHomeActive,
    required Employee? employee,
  }) {
    final opItems = _opItemsFor(employee, isAdmin: false);
    final homeTab = EmployeeHomeShell.tabIndex.value;
    return [
      const _SectionHeader(
        title: 'MY WORKSPACE',
        badgeLabel: 'Employee',
        badgeBg: PortalColors.brandTint,
        badgeTextColor: PortalColors.brand,
      ),
      const SizedBox(height: 8),
      _MenuCard(
        title: 'Dashboard',
        subtitle: 'Overview & stats',
        icon: Icons.grid_view_rounded,
        iconBg: PortalColors.brand,
        iconColor: Colors.white,
        isSelected:
            isHomeActive && homeTab == 0 && !_opRoutes.contains(currentRoute),
        onTap: () => _openHomeTab(0),
      ),
      ..._opSection(currentRoute: currentRoute, opItems: opItems),
      if (AuthSession.campActivated)
        _MenuCard(
          title: 'Camp Management',
          subtitle: 'Camps & patients',
          icon: Icons.medical_services_outlined,
          iconBg: const Color(0xFFFFF1F2),
          iconColor: const Color(0xFFE11D48),
          isSelected: currentRoute == AppRoutes.campManagement,
          onTap: () => _open(route: AppRoutes.campManagement),
        ),
      _ExpandableMenuCard(
        title: 'Attendance',
        subtitle: 'Daily & records',
        icon: Icons.calendar_today_rounded,
        iconBg: PortalColors.brandTint,
        iconColor: PortalColors.brand,
        expanded: _expanded.contains('attendance'),
        onToggle: () => _toggle('attendance'),
        children: [
          _SubTile(
            title: 'My Attendance',
            isSelected: isHomeActive && homeTab == 1,
            onTap: () => _openHomeTab(1),
          ),
          _SubTile(
            title: 'Rosters',
            isSelected: currentRoute == AppRoutes.workRoster,
            onTap: () => _open(route: AppRoutes.workRoster),
          ),
        ],
      ),
      _MenuCard(
        title: 'Leave',
        subtitle: 'Apply & track leave',
        icon: Icons.event_available_rounded,
        iconBg: const Color(0xFFFEF3C7),
        iconColor: const Color(0xFFD97706),
        isSelected: isHomeActive && homeTab == 2,
        onTap: () => _openHomeTab(2),
      ),
      _MenuCard(
        title: 'Profile',
        subtitle: 'Account & details',
        icon: Icons.person_outline_rounded,
        iconBg: PortalColors.brandTint,
        iconColor: PortalColors.brand,
        isSelected: (isHomeActive && homeTab == 3) ||
            currentRoute == AppRoutes.profile ||
            currentRoute == AppRoutes.profileHub,
        onTap: () => _openHomeTab(3),
      ),
      _MenuCard(
        title: 'Payslips',
        subtitle: 'Salary slips',
        icon: Icons.currency_rupee_rounded,
        iconBg: const Color(0xFFECFDF5),
        iconColor: const Color(0xFF059669),
        isSelected: currentRoute == AppRoutes.payslips,
        onTap: () => _open(route: AppRoutes.payslips),
      ),
      _MenuCard(
        title: 'Expenses',
        subtitle: 'Claims & reimbursements',
        icon: Icons.show_chart_rounded,
        iconBg: const Color(0xFFEFF6FF),
        iconColor: const Color(0xFF2563EB),
        isSelected: currentRoute == AppRoutes.expense,
        onTap: () => _open(route: AppRoutes.expense),
      ),
      _MenuCard(
        title: 'Holidays',
        subtitle: 'Company calendar',
        icon: Icons.calendar_month_rounded,
        iconBg: PortalColors.brandTint,
        iconColor: PortalColors.brand,
        isSelected: currentRoute == AppRoutes.holidayCalendar,
        onTap: () => _open(route: AppRoutes.holidayCalendar),
      ),
      _MenuCard(
        title: 'Relieving Letters',
        subtitle: 'Experience letters',
        icon: Icons.description_outlined,
        iconBg: const Color(0xFFECFDF5),
        iconColor: const Color(0xFF059669),
        isSelected: currentRoute == AppRoutes.letters,
        onTap: () => _open(route: AppRoutes.letters),
      ),
      _MenuCard(
        title: 'My Visits',
        subtitle: 'Field visits',
        icon: Icons.location_on_outlined,
        iconBg: const Color(0xFFE8F1FF),
        iconColor: const Color(0xFF2563EB),
        isSelected: currentRoute == AppRoutes.visits,
        onTap: () => _open(route: AppRoutes.visits),
      ),
      _MenuCard(
        title: 'Issues',
        subtitle: 'Raise & track issues',
        icon: Icons.error_outline_rounded,
        iconBg: const Color(0xFFFFF1F2),
        iconColor: const Color(0xFFE11D48),
        isSelected: currentRoute == AppRoutes.issues,
        onTap: () => _open(route: AppRoutes.issues),
      ),
      _MenuCard(
        title: 'My Events',
        subtitle: 'Your events',
        icon: Icons.event_rounded,
        iconBg: const Color(0xFFFEF3C7),
        iconColor: const Color(0xFFD97706),
        isSelected: currentRoute == AppRoutes.myEvents,
        onTap: () => _open(route: AppRoutes.myEvents),
      ),
      _MenuCard(
        title: 'Logout',
        subtitle: 'Sign out of your account',
        icon: Icons.logout_rounded,
        iconBg: const Color(0xFFFFF1F2),
        iconColor: const Color(0xFFE11D48),
        onTap: _handleSignOut,
      ),
    ];
  }

  void _ensureAttendanceExpanded({
    required String currentRoute,
    required bool isHomeActive,
  }) {
    final need = currentRoute == AppRoutes.workRoster ||
        (isHomeActive && EmployeeHomeShell.tabIndex.value == 1);
    if (!need || _expanded.contains('attendance')) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _expanded.contains('attendance')) return;
      setState(() => _expanded.add('attendance'));
    });
  }

  @override
  Widget build(BuildContext context) {
    final drawerWidth =
        (MediaQuery.sizeOf(context).width * 0.72).clamp(260.0, 285.0);
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '';
    final isHomeActive = currentRoute == AppRoutes.home ||
        currentRoute == AppRoutes.adminDashboard ||
        currentRoute == '/' ||
        currentRoute.isEmpty;

    _ensureAttendanceExpanded(
      currentRoute: currentRoute,
      isHomeActive: isHomeActive,
    );

    final employee = AuthSession.currentEmployee;
    final isAdmin = employee?.isAdmin ?? false;

    final name = (employee?.name ?? '').trim();
    final firstName = (employee?.firstName?.trim().isNotEmpty ?? false)
        ? employee!.firstName!.trim()
        : (name.isEmpty ? 'Sanjay' : name.split(RegExp(r'\s+')).first);

    final initials = (employee != null &&
            employee.initials.isNotEmpty &&
            employee.initials != '?')
        ? employee.initials
        : 'SJ';

    final designation = (employee?.designation.trim().isNotEmpty ?? false)
        ? employee!.designation.trim()
        : ((employee?.role.trim().isNotEmpty ?? false)
            ? employee!.role.trim()
            : 'Developer');

    const radius = BorderRadius.only(
      topRight: Radius.circular(28),
      bottomRight: Radius.circular(28),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Drawer(
        width: drawerWidth,
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: radius),
        child: ClipRRect(
          borderRadius: radius,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(
                initials: initials,
                firstName: firstName,
                designation: designation,
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  children: [
                    if (isAdmin)
                      ..._adminMenuItems(
                        currentRoute: currentRoute,
                        isHomeActive: isHomeActive,
                      )
                    else
                      ..._employeeMenuItems(
                        currentRoute: currentRoute,
                        isHomeActive: isHomeActive,
                        employee: employee,
                      ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              const _Footer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.initials,
    required this.firstName,
    required this.designation,
  });

  final String initials;
  final String firstName;
  final String designation;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;

    return Container(
      padding: EdgeInsets.fromLTRB(14, top + 12, 12, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E1848),
            Color(0xFF161234),
          ],
        ),
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF262057),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF41387E),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  initials,
                  style: portalText(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Positioned(
                right: -1,
                bottom: -1,
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF161234),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hello , $firstName',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        designation,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: portalText(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        '•',
                        style: portalText(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFF064E3B).withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: const Color(0xFF10B981)
                              .withValues(alpha: 0.6),
                          width: 0.7,
                        ),
                      ),
                      child: Text(
                        'Active',
                        style: portalText(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF34D399),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Material(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(9),
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).pop();
              },
              borderRadius: BorderRadius.circular(9),
              child: const SizedBox(
                width: 30,
                height: 30,
                child: Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.badgeLabel,
    required this.badgeBg,
    required this.badgeTextColor,
  });

  final String title;
  final String badgeLabel;
  final Color badgeBg;
  final Color badgeTextColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Text(
            title,
            style: portalText(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF8C95A6),
              letterSpacing: 0.8,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              badgeLabel,
              style: portalText(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: badgeTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.onTap,
    this.isSelected = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF6F4FB) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected
                ? PortalColors.brand.withValues(alpha: 0.25)
                : const Color(0xFFF1F5F9),
            width: isSelected ? 1.3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.025),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(15),
            hoverColor: const Color(0xFFF6F4FB),
            splashColor: PortalColors.brand.withValues(alpha: 0.14),
            highlightColor: PortalColors.brand.withValues(alpha: 0.07),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 19, color: iconColor),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: portalText(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w700,
                            color: isSelected
                                ? PortalColors.brand
                                : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 1.5),
                        Text(
                          subtitle,
                          style: portalText(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF8C95A6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isSelected
                        ? Icons.check_circle_rounded
                        : Icons.chevron_right_rounded,
                    color: isSelected
                        ? PortalColors.brand
                        : const Color(0xFF94A3B8),
                    size: isSelected ? 18 : 19,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpandableMenuCard extends StatelessWidget {
  const _ExpandableMenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.expanded,
    required this.onToggle,
    required this.children,
    this.badge,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final bool expanded;
  final VoidCallback onToggle;
  final List<Widget> children;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: expanded
                ? const Color(0xFFE2E8F0)
                : const Color(0xFFF1F5F9),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.025),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            children: [
              InkWell(
                onTap: onToggle,
                borderRadius: expanded
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      )
                    : BorderRadius.circular(15),
                hoverColor: const Color(0xFFF6F4FB),
                splashColor: PortalColors.brand.withValues(alpha: 0.12),
                highlightColor: PortalColors.brand.withValues(alpha: 0.06),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: iconBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, size: 19, color: iconColor),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: portalText(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 1.5),
                            Text(
                              subtitle,
                              style: portalText(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF8C95A6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (badge != null) ...[
                        badge!,
                        const SizedBox(width: 6),
                      ],
                      Icon(
                        expanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: const Color(0xFF94A3B8),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              if (expanded) ...[
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 4, 6, 6),
                  child: Column(children: children),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SubTile extends StatelessWidget {
  const _SubTile({
    required this.title,
    required this.onTap,
    this.isSelected = false,
  });

  final String title;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF3F1F9) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isSelected
                ? Border.all(
                    color: PortalColors.brand.withValues(alpha: 0.22),
                    width: 1,
                  )
                : null,
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            hoverColor: const Color(0xFFF6F4FB),
            splashColor: PortalColors.brand.withValues(alpha: 0.16),
            highlightColor: PortalColors.brand.withValues(alpha: 0.08),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8.5),
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? PortalColors.brand
                          : const Color(0xFF94A3B8),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: portalText(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected
                            ? PortalColors.brand
                            : const Color(0xFF334155),
                      ),
                    ),
                  ),
                  Icon(
                    isSelected
                        ? Icons.check_circle_rounded
                        : Icons.chevron_right_rounded,
                    color: isSelected
                        ? PortalColors.brand
                        : const Color(0xFFCBD5E1),
                    size: 15,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatefulWidget {
  const _Footer();

  @override
  State<_Footer> createState() => _FooterState();
}

class _FooterState extends State<_Footer> {
  String _versionLabel = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      final build = info.buildNumber.trim();
      setState(() {
        _versionLabel = build.isEmpty
            ? 'v${info.version}'
            : 'v${info.version}+$build';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _versionLabel = '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: PortalColors.brand,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            'Timely Health',
            style: portalText(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
          const Spacer(),
          if (_versionLabel.isNotEmpty)
            Text(
              _versionLabel,
              style: portalText(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF94A3B8),
              ),
            ),
        ],
      ),
    );
  }
}
