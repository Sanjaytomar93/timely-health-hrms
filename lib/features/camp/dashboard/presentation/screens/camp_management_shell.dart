import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timelay_health/core/widgets/portal_safe_area.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/screens/camp_dashboard_screen.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/theme/camp_colors.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/theme/camp_ui_scope.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/widgets/camp_bottom_nav.dart';
import 'package:timelay_health/features/camp/profile/presentation/screens/camp_profile_screen.dart';
import 'package:timelay_health/features/camp/camps/presentation/screens/camp_list_screen.dart';
import 'package:timelay_health/features/camp/patients/presentation/screens/patients_screen.dart';

class CampManagementShell extends StatefulWidget {
  const CampManagementShell({super.key});

  @override
  State<CampManagementShell> createState() => _CampManagementShellState();
}

class _CampManagementShellState extends State<CampManagementShell> {
  int _index = 0;
  final Set<int> _visited = {0};
  Timer? _prefetchCamps;
  Timer? _prefetchPatients;

  @override
  void initState() {
    super.initState();
    _prefetchCamps = Timer(const Duration(milliseconds: 1500), () {
      if (!mounted || _visited.contains(1)) return;
      setState(() => _visited.add(1));
    });
    _prefetchPatients = Timer(const Duration(milliseconds: 3000), () {
      if (!mounted || _visited.contains(2)) return;
      setState(() => _visited.add(2));
    });
  }

  @override
  void dispose() {
    _prefetchCamps?.cancel();
    _prefetchPatients?.cancel();
    super.dispose();
  }

  void _openTab(int value) {
    setState(() {
      _visited.add(value);
      _index = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CampUiScope(
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
        ),
        child: Scaffold(
          backgroundColor: CampColors.background,
          body: PortalSafeArea(
            bottom: false,
            statusBarColor: CampColors.surface,
            child: IndexedStack(
              index: _index,
              children: [
                const CampDashboardScreen(),
                _visited.contains(1)
                    ? const CampListScreen()
                    : const SizedBox.shrink(),
                _visited.contains(2)
                    ? const PatientsScreen()
                    : const SizedBox.shrink(),
                _visited.contains(3)
                    ? const CampProfileScreen()
                    : const SizedBox.shrink(),
              ],
            ),
          ),
          bottomNavigationBar: CampBottomNav(
            currentIndex: _index,
            onTap: _openTab,
          ),
        ),
      ),
    );
  }
}
