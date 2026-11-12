import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/widgets/portal_safe_area.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/home_side_drawer.dart';
import 'package:timelay_health/features/op/dashboard/presentation/screens/op_dashboard_screen.dart';
import 'package:timelay_health/features/op/dashboard/presentation/screens/op_doctors_screen.dart';
import 'package:timelay_health/features/op/dashboard/presentation/screens/op_services_screen.dart';
import 'package:timelay_health/features/op/dashboard/presentation/screens/op_walkin_screen.dart';
import 'package:timelay_health/features/op/dashboard/presentation/theme/op_colors.dart';
import 'package:timelay_health/features/op/dashboard/presentation/theme/op_ui_scope.dart';
import 'package:timelay_health/features/op/dashboard/presentation/widgets/op_bottom_nav.dart';

class OpManagementShell extends StatefulWidget {
  const OpManagementShell({super.key});

  @override
  State<OpManagementShell> createState() => _OpManagementShellState();
}

class _OpManagementShellState extends State<OpManagementShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _index = 0;

  void _openTab(int value) {
    setState(() => _index = value);
  }

  void _onMenuTap() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return OpUiScope(
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
        ),
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: OpColors.background,
          drawer: const HomeSideDrawer(),
          drawerScrimColor: PortalColors.brand.withValues(alpha: 0.28),
          body: PortalSafeArea(
            bottom: false,
            statusBarColor: OpColors.primary,
            child: IndexedStack(
              index: _index,
              children: [
                OpDashboardScreen(
                  onOpenTab: _openTab,
                  onMenuTap: _onMenuTap,
                ),
                OpWalkinScreen(onMenuTap: _onMenuTap),
                OpDoctorsScreen(onMenuTap: _onMenuTap),
                OpServicesScreen(onMenuTap: _onMenuTap),
              ],
            ),
          ),
          bottomNavigationBar: OpBottomNav(
            currentIndex: _index,
            onTap: _openTab,
          ),
        ),
      ),
    );
  }
}
