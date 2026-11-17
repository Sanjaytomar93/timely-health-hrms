import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/widgets/portal_safe_area.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/home_side_drawer.dart';
import 'package:timelay_health/features/op/dashboard/presentation/screens/op_dashboard_screen.dart';
import 'package:timelay_health/features/op/doctors/presentation/screens/op_doctors_screen.dart';
import 'package:timelay_health/features/op/online_booking/presentation/screens/op_online_booking_screen.dart';
import 'package:timelay_health/features/op/services/presentation/screens/op_services_screen.dart';
import 'package:timelay_health/features/op/walkin/presentation/screens/op_walkin_screen.dart';
import 'package:timelay_health/features/op/dashboard/presentation/theme/op_colors.dart';
import 'package:timelay_health/features/op/dashboard/presentation/widgets/op_bottom_nav.dart';

class OpManagementShell extends StatefulWidget {
  const OpManagementShell({super.key});

  @override
  State<OpManagementShell> createState() => _OpManagementShellState();
}

class _OpManagementShellState extends State<OpManagementShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _stackIndex = 0;
  int _navIndex = 0;

  void _openTab(int stackIndex) {
    setState(() {
      _stackIndex = stackIndex.clamp(0, 4);
      _navIndex = _stackIndex;
    });
  }

  void _onNavTap(int navIndex) {
    setState(() {
      _navIndex = navIndex;
      _stackIndex = navIndex.clamp(0, 4);
    });
  }

  void _onMenuTap() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final isWhiteHeader =
        _stackIndex == 0 || _stackIndex == 1 || _stackIndex == 4;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (isWhiteHeader ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light)
          .copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: OpColors.background,
        drawer: const HomeSideDrawer(),
        drawerScrimColor: PortalColors.brand.withValues(alpha: 0.28),
        body: PortalSafeArea(
          bottom: false,
          statusBarColor: isWhiteHeader ? Colors.white : OpColors.primary,
          child: IndexedStack(
            index: _stackIndex,
            children: [
              OpDashboardScreen(
                onOpenTab: _openTab,
                onMenuTap: _onMenuTap,
              ),
              OpWalkinScreen(onMenuTap: _onMenuTap),
              OpDoctorsScreen(onMenuTap: _onMenuTap),
              OpServicesScreen(onMenuTap: _onMenuTap),
              OpOnlineBookingScreen(onMenuTap: _onMenuTap),
            ],
          ),
        ),
        bottomNavigationBar: OpBottomNav(
          currentIndex: _navIndex,
          onTap: _onNavTap,
        ),
      ),
    );
  }
}
