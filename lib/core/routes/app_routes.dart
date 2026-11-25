import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/widgets/portal_safe_area.dart';
import 'package:timelay_health/features/admin/attendance/presentation/screens/absent_today_screen.dart';
import 'package:timelay_health/features/admin/attendance/presentation/screens/attendance_records_screen.dart';
import 'package:timelay_health/features/admin/attendance/presentation/screens/attendance_summary_screen.dart';
import 'package:timelay_health/features/admin/attendance/presentation/screens/late_today_screen.dart';
import 'package:timelay_health/features/admin/attendance/presentation/screens/today_attendance_screen.dart';
import 'package:timelay_health/features/admin/employees/presentation/screens/employee_list_screen.dart';
import 'package:timelay_health/features/admin/expense/presentation/screens/admin_expense_management_screen.dart';
import 'package:timelay_health/features/admin/leaves/presentation/screens/admin_leave_requests_screen.dart';
import 'package:timelay_health/features/admin/payroll/presentation/screens/employee_payroll_screen.dart';
import 'package:timelay_health/features/admin/payroll/presentation/screens/payroll_overview_screen.dart';
import 'package:timelay_health/features/admin/shift/presentation/screens/admin_shift_management_screen.dart';
import 'package:timelay_health/features/auth/domain/entities/employee.dart';
import 'package:timelay_health/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:timelay_health/features/auth/presentation/screens/login_screen.dart';
import 'package:timelay_health/features/auth/presentation/screens/splash_screen.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/screens/camp_management_shell.dart';
import 'package:timelay_health/features/admin/dashboard/presentation/screens/admin_dashboard_screen.dart';
import 'package:timelay_health/features/dashboard/presentation/screens/employee_home_shell.dart';
import 'package:timelay_health/features/admin/digital_leads/presentation/screens/digital_leads_screen.dart';
import 'package:timelay_health/features/admin/location_management/presentation/screens/location_management_screen.dart';
import 'package:timelay_health/features/leaves/presentation/screens/leaves_screen.dart';
import 'package:timelay_health/features/events/presentation/screens/admin_events_screen.dart';
import 'package:timelay_health/features/events/presentation/screens/my_events_screen.dart';
import 'package:timelay_health/features/expense/presentation/screens/expense_screen.dart';
import 'package:timelay_health/features/issues/presentation/screens/issues_screen.dart';
import 'package:timelay_health/features/letters/presentation/models/employee_letter.dart';
import 'package:timelay_health/features/letters/presentation/screens/letter_viewer_screen.dart';
import 'package:timelay_health/features/letters/presentation/screens/my_letters_screen.dart';
import 'package:timelay_health/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:timelay_health/features/op/dashboard/presentation/screens/op_management_shell.dart';
import 'package:timelay_health/features/permissions/presentation/screens/permissions_screen.dart';
import 'package:timelay_health/features/profile/presentation/screens/employee_details_screen.dart';
import 'package:timelay_health/features/profile/presentation/screens/holiday_calendar_screen.dart';
import 'package:timelay_health/features/profile/presentation/screens/payslips_screen.dart';
import 'package:timelay_health/features/profile/presentation/screens/admin_profile_screen.dart';
import 'package:timelay_health/features/profile/presentation/screens/profile_hub_screen.dart';
import 'package:timelay_health/features/profile/presentation/screens/profile_section_placeholder_screen.dart';
import 'package:timelay_health/features/profile/presentation/screens/profile_screen.dart';
import 'package:timelay_health/features/roster/presentation/screens/work_roster_screen.dart';
import 'package:timelay_health/features/visits/presentation/screens/visits_screen.dart';

abstract final class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const forgotPassword = '/forgot-password';
  static const home = '/home';
  static const adminDashboard = '/admin-dashboard';
  static const permissions = '/permissions';
  static const notifications = '/notifications';
  static const profile = '/profile';
  static const adminProfile = '/admin-profile';
  static const profileHub = '/profile-hub';
  static const employeeDetails = '/profile/details';
  static const holidayCalendar = '/profile/calendar';
  static const payslips = '/profile/payslips';
  static const expense = '/profile/expense';
  static const issues = '/profile/issues';
  static const visits = '/profile/visits';
  static const letters = '/profile/letters';
  static const letterViewer = '/profile/letter-viewer';
  static const events = '/profile/events';
  static const myEvents = '/profile/my-events';
  static const workRoster = '/profile/work-roster';
  static const placeholder = '/profile/placeholder';
  static const campManagement = '/camp-management';
  static const opManagement = '/op-management';
  static const opDashboard = '/op/dashboard';
  static const opWalkin = '/op/walkin';
  static const opOnlineBookings = '/op/online-bookings';
  static const opReferralManagement = '/op/referral-management';
  static const opReferralBookings = '/op/referral-bookings';
  static const opAppointmentSlots = '/op/appointment-slots';
  static const opDoctors = '/op/doctors';
  static const opServices = '/op/services';
  static const opRevenueAnalytics = '/op/revenue-analytics';
  static const employeeList = '/admin/employee-list';
  static const attendanceSummary = '/admin/attendance-summary';
  static const attendanceRecords = '/admin/attendance-records';
  static const todayAttendance = '/admin/today-attendance';
  static const absentToday = '/admin/absent-today';
  static const lateToday = '/admin/late-today';
  static const leaveList = '/admin/leave-list';
  static const payrollDashboard = '/admin/payroll-dashboard';
  static const employeePayroll = '/admin/employee-payroll';
  static const adminShift = '/admin/shift';
  static const adminExpense = '/admin/expense';
  static const leaves = '/leaves';
  static const digitalLeads = '/digital-leads';
  static const locationManagement = '/admin/location-management';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _fadeRoute(const SplashScreen(), settings);

      case login:
        return _fadeRoute(const LoginScreen(), settings);

      case forgotPassword:
        return MaterialPageRoute<void>(
          builder: (_) => const ForgotPasswordScreen(),
          settings: settings,
        );

      case home:
        return _fadeRoute(const EmployeeHomeShell(), settings);

      case adminDashboard:
        return MaterialPageRoute<void>(
          builder: (_) => const Scaffold(
            body: PortalSafeArea(
              bottom: false,
              statusBarColor: PortalColors.brand,
              child: AdminDashboardScreen(),
            ),
          ),
          settings: settings,
        );

      case permissions:
        return MaterialPageRoute<void>(
          builder: (_) => const PermissionsScreen(),
          settings: settings,
        );

      case notifications:
        return MaterialPageRoute<void>(
          builder: (_) => const NotificationsScreen(),
          settings: settings,
        );

      case profile:
        return MaterialPageRoute<void>(
          builder: (_) => const ProfileScreen(),
          settings: settings,
        );

      case adminProfile:
        return MaterialPageRoute<void>(
          builder: (_) => const AdminProfileScreen(),
          settings: settings,
        );

      case profileHub:
        return MaterialPageRoute<void>(
          builder: (_) => const ProfileHubScreen(),
          settings: settings,
        );

      case employeeDetails:
        final employee = settings.arguments as Employee?;
        if (employee == null) {
          return _errorRoute('Employee details data is missing.');
        }
        return MaterialPageRoute<void>(
          builder: (_) => EmployeeDetailsScreen(employee: employee),
          settings: settings,
        );

      case holidayCalendar:
        return MaterialPageRoute<void>(
          builder: (_) => const HolidayCalendarScreen(),
          settings: settings,
        );

      case payslips:
        return MaterialPageRoute<void>(
          builder: (_) => const PayslipsScreen(),
          settings: settings,
        );

      case expense:
        return MaterialPageRoute<void>(
          builder: (_) => const ExpenseScreen(),
          settings: settings,
        );

      case adminExpense:
        return MaterialPageRoute<void>(
          builder: (_) => const AdminExpenseManagementScreen(),
          settings: settings,
        );

      case issues:
        return MaterialPageRoute<void>(
          builder: (_) => const IssuesScreen(),
          settings: settings,
        );

      case visits:
        return MaterialPageRoute<void>(
          builder: (_) => const VisitsScreen(),
          settings: settings,
        );

      case letters:
        return MaterialPageRoute<void>(
          builder: (_) => const MyLettersScreen(),
          settings: settings,
        );

      case letterViewer:
        final letter = settings.arguments as EmployeeLetter?;
        if (letter == null) {
          return _errorRoute('Letter file data is missing.');
        }
        return MaterialPageRoute<void>(
          builder: (_) => LetterViewerScreen(letter: letter),
          settings: settings,
        );

      case events:
        return MaterialPageRoute<void>(
          builder: (_) => const AdminEventsScreen(),
          settings: settings,
        );

      case myEvents:
        return MaterialPageRoute<void>(
          builder: (_) => const MyEventsScreen(),
          settings: settings,
        );

      case workRoster:
        return MaterialPageRoute<void>(
          builder: (_) => const WorkRosterScreen(),
          settings: settings,
        );

      case adminShift:
        return MaterialPageRoute<void>(
          builder: (_) => const AdminShiftManagementScreen(),
          settings: settings,
        );

      case placeholder:
        final title = (settings.arguments as String?) ?? 'Portal';
        return MaterialPageRoute<void>(
          builder: (_) => ProfileSectionPlaceholderScreen(title: title),
          settings: settings,
        );

      case digitalLeads:
        return MaterialPageRoute<void>(
          builder: (_) => const DigitalLeadsScreen(),
          settings: settings,
        );

      case locationManagement:
        return MaterialPageRoute<void>(
          builder: (_) => const LocationManagementScreen(),
          settings: settings,
        );

      case campManagement:
        return MaterialPageRoute<void>(
          builder: (_) => const CampManagementShell(),
          settings: settings,
        );

      case opManagement:
      case opDashboard:
        return MaterialPageRoute<void>(
          builder: (_) => const OpManagementShell(initialTab: 0),
          settings: settings,
        );

      case opWalkin:
        return MaterialPageRoute<void>(
          builder: (_) => const OpManagementShell(initialTab: 1),
          settings: settings,
        );

      case opDoctors:
        return MaterialPageRoute<void>(
          builder: (_) => const OpManagementShell(initialTab: 2),
          settings: settings,
        );

      case opServices:
        return MaterialPageRoute<void>(
          builder: (_) => const OpManagementShell(initialTab: 3),
          settings: settings,
        );

      case opOnlineBookings:
        return MaterialPageRoute<void>(
          builder: (_) => const OpManagementShell(initialTab: 4),
          settings: settings,
        );

      case opReferralManagement:
        return MaterialPageRoute<void>(
          builder: (_) => const OpManagementShell(initialTab: 5),
          settings: settings,
        );

      case opReferralBookings:
        return MaterialPageRoute<void>(
          builder: (_) => const OpManagementShell(initialTab: 6),
          settings: settings,
        );

      case opAppointmentSlots:
        return MaterialPageRoute<void>(
          builder: (_) => const OpManagementShell(initialTab: 7),
          settings: settings,
        );

      case opRevenueAnalytics:
        return MaterialPageRoute<void>(
          builder: (_) => const OpManagementShell(initialTab: 8),
          settings: settings,
        );

      case employeeList:
        return MaterialPageRoute<void>(
          builder: (_) => const EmployeeListScreen(),
          settings: settings,
        );

      case attendanceSummary:
        return MaterialPageRoute<void>(
          builder: (_) => const AttendanceSummaryScreen(),
          settings: settings,
        );

      case attendanceRecords:
        return MaterialPageRoute<void>(
          builder: (_) => const AttendanceRecordsScreen(),
          settings: settings,
        );

      case todayAttendance:
        return MaterialPageRoute<void>(
          builder: (_) => const TodayAttendanceScreen(),
          settings: settings,
        );

      case absentToday:
        return MaterialPageRoute<void>(
          builder: (_) => const AbsentTodayScreen(),
          settings: settings,
        );

      case lateToday:
        return MaterialPageRoute<void>(
          builder: (_) => const LateTodayScreen(),
          settings: settings,
        );

      case leaveList:
        return MaterialPageRoute<void>(
          builder: (_) => const AdminLeaveRequestsScreen(),
          settings: settings,
        );

      case payrollDashboard:
        return MaterialPageRoute<void>(
          builder: (_) => const PayrollOverviewScreen(),
          settings: settings,
        );

      case employeePayroll:
        return MaterialPageRoute<void>(
          builder: (_) => const EmployeePayrollScreen(),
          settings: settings,
        );

      case leaves:
        return MaterialPageRoute<void>(
          builder: (_) => const LeavesScreen(),
          settings: settings,
        );

      default:
        return _errorRoute('Route not found: ${settings.name}');
    }
  }

  static PageRouteBuilder<T> _fadeRoute<T>(Widget page, RouteSettings settings) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (_, animation, secondaryAnimation) => page,
      transitionsBuilder: (_, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
      transitionDuration: const Duration(milliseconds: 320),
    );
  }

  static MaterialPageRoute<void> _errorRoute(String message) {
    return MaterialPageRoute<void>(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  static Future<T?> push<T>(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.of(context).pushNamed<T>(routeName, arguments: arguments);
  }

  static Future<T?> pushReplacement<T, TO>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    TO? result,
  }) {
    return Navigator.of(context).pushReplacementNamed<T, TO>(
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  static Future<T?> pushAndRemoveUntil<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    bool Function(Route<dynamic>)? predicate,
  }) {
    return Navigator.of(context).pushNamedAndRemoveUntil<T>(
      routeName,
      predicate ?? (_) => false,
      arguments: arguments,
    );
  }
}
