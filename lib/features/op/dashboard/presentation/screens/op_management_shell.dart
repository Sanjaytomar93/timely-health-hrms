import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/widgets/portal_safe_area.dart';
import 'package:timelay_health/features/dashboard/presentation/screens/employee_home_shell.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/employee_bottom_nav.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/home_side_drawer.dart';
import 'package:timelay_health/features/op/appointments/presentation/screens/op_appointment_slots_screen.dart';
import 'package:timelay_health/features/op/dashboard/presentation/screens/op_dashboard_screen.dart';
import 'package:timelay_health/features/op/dashboard/presentation/screens/op_revenue_analytics_screen.dart';
import 'package:timelay_health/features/op/doctors/presentation/screens/op_doctors_screen.dart';
import 'package:timelay_health/features/op/online_booking/presentation/screens/op_online_booking_screen.dart';
import 'package:timelay_health/features/op/referral/presentation/screens/op_referral_booking_screen.dart';
import 'package:timelay_health/features/op/referral/presentation/screens/op_referral_management_screen.dart';
import 'package:timelay_health/features/op/services/presentation/screens/op_services_screen.dart';
import 'package:timelay_health/features/op/walkin/presentation/screens/op_walkin_screen.dart';
import 'package:timelay_health/features/op/dashboard/presentation/screens/op_shell_navigator.dart';
import 'package:timelay_health/features/op/dashboard/presentation/theme/op_colors.dart';

class OpManagementShell extends StatefulWidget {
  const OpManagementShell({super.key, this.initialTab = 0});

  final int initialTab;

  static int tabFromRoute(String? routeName) =>
      OpShellNavigator.tabFromRoute(routeName);

  @override
  State<OpManagementShell> createState() => _OpManagementShellState();
}

class _OpManagementShellState extends State<OpManagementShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late int _stackIndex;

  static const _pageCount = 9;

  late final void Function(int) _boundOpenTab = openTab;

  @override
  void initState() {
    super.initState();
    OpShellNavigator.bind(_boundOpenTab);
    _stackIndex = widget.initialTab.clamp(0, _pageCount - 1);
  }

  @override
  void dispose() {
    OpShellNavigator.unbind(_boundOpenTab);
    super.dispose();
  }

  void openTab(int stackIndex) {
    final next = stackIndex.clamp(0, _pageCount - 1);
    if (next == _stackIndex) return;
    setState(() => _stackIndex = next);
  }

  void _onMenuTap() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _onBottomNavTap(int index) {
    // Avoid re-entrant pop when already highlighting Home.
    if (index == 0) {
      EmployeeHomeShell.goToDashboard(context);
      return;
    }
    EmployeeHomeShell.goToTab(context, index);
  }

  Widget _wrapSafe({
    required Color statusBarColor,
    required Widget child,
  }) {
    return PortalSafeArea(
      bottom: false,
      statusBarColor: statusBarColor,
      child: child,
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 1:
        return _wrapSafe(
          statusBarColor: Colors.white,
          child: OpWalkinScreen(onMenuTap: _onMenuTap),
        );
      case 2:
        return _wrapSafe(
          statusBarColor: OpColors.primary,
          child: OpDoctorsScreen(onMenuTap: _onMenuTap),
        );
      case 3:
        return _wrapSafe(
          statusBarColor: OpColors.primary,
          child: OpServicesScreen(onMenuTap: _onMenuTap),
        );
      case 4:
        return _wrapSafe(
          statusBarColor: Colors.white,
          child: OpOnlineBookingScreen(onMenuTap: _onMenuTap),
        );
      case 5:
        return const OpReferralManagementScreen();
      case 6:
        return const OpReferralBookingScreen();
      case 7:
        return _wrapSafe(
          statusBarColor: OpColors.primary,
          child: OpAppointmentSlotsScreen(onMenuTap: _onMenuTap),
        );
      case 8:
        return OpRevenueAnalyticsScreen(onMenuTap: _onMenuTap);
      case 0:
      default:
        return _wrapSafe(
          statusBarColor: Colors.white,
          child: OpDashboardScreen(
            onOpenTab: openTab,
            onMenuTap: _onMenuTap,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWhiteHeader = _stackIndex == 0 ||
        _stackIndex == 1 ||
        _stackIndex == 4 ||
        _stackIndex == 5 ||
        _stackIndex == 6 ||
        _stackIndex == 8;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (isWhiteHeader ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light)
          .copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: OpColors.background,
        drawer: const HomeSideDrawer(),
        drawerScrimColor: PortalColors.brand.withValues(alpha: 0.28),
        body: _buildPage(_stackIndex),
        bottomNavigationBar: EmployeeBottomNav(
          currentIndex: 0,
          onTap: _onBottomNavTap,
        ),
      ),
    );
  }
}
