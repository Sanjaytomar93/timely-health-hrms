import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timelay_health/core/widgets/portal_safe_area.dart';
import 'package:timelay_health/features/camp/presentation/screens/camp_dashboard_screen.dart';
import 'package:timelay_health/features/camp/presentation/screens/camp_list_screen.dart';
import 'package:timelay_health/features/camp/presentation/screens/patients_screen.dart';
import 'package:timelay_health/features/camp/presentation/theme/camp_colors.dart';
import 'package:timelay_health/features/camp/presentation/widgets/camp_bottom_nav.dart';

class CampManagementShell extends StatefulWidget {
  const CampManagementShell({super.key});

  @override
  State<CampManagementShell> createState() => _CampManagementShellState();
}

class _CampManagementShellState extends State<CampManagementShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
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
            children: const [
              CampDashboardScreen(),
              CampListScreen(),
              PatientsScreen(),
              CampPlaceholderTab(title: 'Profile'),
            ],
          ),
        ),
        bottomNavigationBar: CampBottomNav(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
        ),
      ),
    );
  }
}
