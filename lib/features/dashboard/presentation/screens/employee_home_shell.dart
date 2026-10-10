import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/features/auth/data/auth_session.dart';
import 'package:timelay_health/features/attendance/presentation/screens/attendance_screen.dart';
import 'package:timelay_health/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:timelay_health/features/dashboard/presentation/bloc/monthly_performance_cubit.dart';
import 'package:timelay_health/features/dashboard/presentation/bloc/monthly_performance_state.dart';
import 'package:timelay_health/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/employee_bottom_nav.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/monthly_performance_dialog.dart';
import 'package:timelay_health/features/leaves/presentation/screens/leaves_screen.dart';
import 'package:timelay_health/features/profile/presentation/screens/profile_hub_screen.dart';
import 'package:timelay_health/core/widgets/portal_safe_area.dart';

class EmployeeHomeShell extends StatefulWidget {
  const EmployeeHomeShell({super.key});

  @override
  State<EmployeeHomeShell> createState() => _EmployeeHomeShellState();
}

class _EmployeeHomeShellState extends State<EmployeeHomeShell> {
  int _index = 0;
  final Set<int> _visited = {0};
  bool _performanceShown = false;

  void _showPerformanceIfNeeded(
    BuildContext context,
    MonthlyPerformanceState state,
  ) {
    if (_performanceShown || state is! MonthlyPerformanceReady) return;
    _performanceShown = true;
    final review = state.review;
    final employeeKey = review.employeeCode.trim().isNotEmpty
        ? review.employeeCode.trim()
        : (AuthSession.currentEmployee?.performanceCode ?? '');
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final already = await AuthSession.wasPerformancePopupShown(employeeKey);
      if (!mounted || already) return;
      await AuthSession.markPerformancePopupShown(employeeKey);
      await Future<void>.delayed(const Duration(milliseconds: 280));
      if (!mounted) return;
      await showMonthlyPerformanceDialog(this.context, review: review);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => DashboardCubit()..load()),
        BlocProvider(create: (_) => MonthlyPerformanceCubit()..load()),
      ],
      child: BlocListener<MonthlyPerformanceCubit, MonthlyPerformanceState>(
        listener: _showPerformanceIfNeeded,
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
          ),
          child: PopScope(
            canPop: _index == 0,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) _openTab(0);
            },
            child: Scaffold(
              backgroundColor: PortalColors.background,
              body: PortalSafeArea(
                bottom: false,
                child: IndexedStack(
                  index: _index,
                  children: [
                    DashboardScreen(
                      onOpenAttendance: () => _openTab(1),
                      onOpenLeaves: () => _openTab(2),
                    ),
                    _visited.contains(1)
                        ? AttendanceScreen(isActive: _index == 1)
                        : const SizedBox.shrink(),
                    _visited.contains(2)
                        ? const LeavesScreen()
                        : const SizedBox.shrink(),
                    _visited.contains(3)
                        ? const ProfileHubScreen()
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
              bottomNavigationBar: EmployeeBottomNav(
                currentIndex: _index,
                onTap: _openTab,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openTab(int value) {
    setState(() {
      _visited.add(value);
      _index = value;
    });
  }
}
