import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timelay_health/core/routes/app_routes.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/admin/leaves/data/datasources/admin_leave_remote_datasource.dart';
import 'package:timelay_health/features/auth/data/auth_session.dart';
import 'package:timelay_health/features/auth/data/auth_sign_out.dart';
import 'package:timelay_health/features/op/dashboard/presentation/screens/op_shell_navigator.dart';

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
    _loadPendingLeaveCount();
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
      if (currentRoute == AppRoutes.attendanceSummary ||
          currentRoute == AppRoutes.attendanceRecords ||
          currentRoute == AppRoutes.todayAttendance ||
          currentRoute == AppRoutes.absentToday ||
          currentRoute == AppRoutes.lateToday) {
        _expanded.add('attendance');
      } else if (currentRoute == AppRoutes.employeeList) {
        _expanded.add('employees');
      } else if (currentRoute == AppRoutes.leaves ||
          currentRoute == AppRoutes.leaveList) {
        _expanded.add('requests');
      } else if (currentRoute == AppRoutes.adminShift ||
          currentRoute == AppRoutes.expense ||
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
          ..remove('op');
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
        (route == AppRoutes.adminDashboard && isHomeActive)) {
      navigator.pop();
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
          AppRoutes.expense,
          AppRoutes.events,
          AppRoutes.visits,
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
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Sign Out',
          style: portalText(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: PortalColors.heading,
          ),
        ),
        content: Text(
          'Are you sure you want to sign out from your account?',
          style: portalText(
            fontSize: 13.5,
            color: PortalColors.secondaryText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: portalText(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: PortalColors.muted,
              ),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE11D48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Sign Out',
              style: portalText(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;
    Navigator.of(context).pop();
    await AuthSignOut.run();
    if (!mounted) return;
    AppRoutes.pushAndRemoveUntil(context, AppRoutes.login);
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

    final employee = AuthSession.currentEmployee;

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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2.5),
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
                        isSelected:
                            currentRoute == AppRoutes.payrollDashboard,
                        onTap: () =>
                            _open(route: AppRoutes.payrollDashboard),
                      ),
                      _SubTile(
                        title: 'Payroll',
                        isSelected:
                            currentRoute == AppRoutes.employeePayroll,
                        onTap: () =>
                            _open(route: AppRoutes.employeePayroll),
                      ),
                      _SubTile(
                        title: 'Expenses',
                        isSelected: currentRoute == AppRoutes.expense,
                        onTap: () => _open(route: AppRoutes.expense),
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
                  _ExpandableMenuCard(
                    title: 'OP Management',
                    subtitle: 'Outpatient management',
                    icon: Icons.local_hospital_rounded,
                    iconBg: const Color(0xFFEFF6FF),
                    iconColor: const Color(0xFF2563EB),
                    expanded: _expanded.contains('op'),
                    onToggle: () => _toggle('op'),
                    children: [
                      _SubTile(
                        title: 'OP Dashboard',
                        isSelected: currentRoute == AppRoutes.opManagement ||
                            currentRoute == AppRoutes.opDashboard,
                        onTap: () => _open(route: AppRoutes.opDashboard),
                      ),
                      _SubTile(
                        title: 'Walkin OP',
                        isSelected: currentRoute == AppRoutes.opWalkin,
                        onTap: () => _open(route: AppRoutes.opWalkin),
                      ),
                      _SubTile(
                        title: 'Online Bookings',
                        isSelected: currentRoute == AppRoutes.opOnlineBookings,
                        onTap: () => _open(route: AppRoutes.opOnlineBookings),
                      ),
                      _SubTile(
                        title: 'Referral Management',
                        isSelected:
                            currentRoute == AppRoutes.opReferralManagement,
                        onTap: () =>
                            _open(route: AppRoutes.opReferralManagement),
                      ),
                      _SubTile(
                        title: 'Referral Bookings',
                        isSelected:
                            currentRoute == AppRoutes.opReferralBookings,
                        onTap: () =>
                            _open(route: AppRoutes.opReferralBookings),
                      ),
                      _SubTile(
                        title: 'Appointment Slots',
                        isSelected:
                            currentRoute == AppRoutes.opAppointmentSlots,
                        onTap: () =>
                            _open(route: AppRoutes.opAppointmentSlots),
                      ),
                      _SubTile(
                        title: 'Doctors',
                        isSelected: currentRoute == AppRoutes.opDoctors,
                        onTap: () => _open(route: AppRoutes.opDoctors),
                      ),
                      _SubTile(
                        title: 'Services',
                        isSelected: currentRoute == AppRoutes.opServices,
                        onTap: () => _open(route: AppRoutes.opServices),
                      ),
                      _SubTile(
                        title: 'Revenue Analytics',
                        isSelected:
                            currentRoute == AppRoutes.opRevenueAnalytics,
                        onTap: () =>
                            _open(route: AppRoutes.opRevenueAnalytics),
                      ),
                    ],
                  ),
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
                    title: 'Digital Leads',
                    subtitle: 'Lead tracking',
                    icon: Icons.filter_alt_outlined,
                    iconBg: PortalColors.brandTint,
                    iconColor: PortalColors.brand,
                    onTap: () => _open(soonLabel: 'Digital Leads'),
                  ),
                  _MenuCard(
                    title: 'Event',
                    subtitle: 'Company events',
                    icon: Icons.event_rounded,
                    iconBg: const Color(0xFFFEF3C7),
                    iconColor: const Color(0xFFD97706),
                    isSelected: currentRoute == AppRoutes.events,
                    onTap: () => _open(route: AppRoutes.events),
                  ),
                  _MenuCard(
                    title: 'Location',
                    subtitle: 'Visits & locations',
                    icon: Icons.location_on_outlined,
                    iconBg: PortalColors.brandTint,
                    iconColor: PortalColors.brand,
                    isSelected: currentRoute == AppRoutes.visits,
                    onTap: () => _open(route: AppRoutes.visits),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: _SignOutButton(onTap: _handleSignOut),
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

class _SignOutButton extends StatelessWidget {
  const _SignOutButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFE4E6)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          splashColor: const Color(0xFFE11D48).withValues(alpha: 0.12),
          highlightColor: const Color(0xFFE11D48).withValues(alpha: 0.06),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 11),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.logout_rounded,
                  size: 17,
                  color: Color(0xFFE11D48),
                ),
                const SizedBox(width: 7),
                Text(
                  'Sign Out',
                  style: portalText(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFE11D48),
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

class _Footer extends StatelessWidget {
  const _Footer();

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
          Text(
            'v2.0',
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
