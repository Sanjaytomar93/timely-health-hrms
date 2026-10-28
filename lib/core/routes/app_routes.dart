import 'package:flutter/material.dart';
import 'package:timelay_health/features/auth/domain/entities/employee.dart';
import 'package:timelay_health/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:timelay_health/features/auth/presentation/screens/login_screen.dart';
import 'package:timelay_health/features/auth/presentation/screens/splash_screen.dart';
import 'package:timelay_health/features/camp/presentation/screens/camp_management_shell.dart';
import 'package:timelay_health/features/dashboard/presentation/screens/employee_home_shell.dart';
import 'package:timelay_health/features/events/presentation/screens/my_events_screen.dart';
import 'package:timelay_health/features/expense/presentation/screens/expense_screen.dart';
import 'package:timelay_health/features/issues/presentation/screens/issues_screen.dart';
import 'package:timelay_health/features/letters/presentation/models/employee_letter.dart';
import 'package:timelay_health/features/letters/presentation/screens/letter_viewer_screen.dart';
import 'package:timelay_health/features/letters/presentation/screens/my_letters_screen.dart';
import 'package:timelay_health/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:timelay_health/features/permissions/presentation/screens/permissions_screen.dart';
import 'package:timelay_health/features/profile/presentation/screens/employee_details_screen.dart';
import 'package:timelay_health/features/profile/presentation/screens/holiday_calendar_screen.dart';
import 'package:timelay_health/features/profile/presentation/screens/payslips_screen.dart';
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
  static const permissions = '/permissions';
  static const notifications = '/notifications';
  static const profile = '/profile';
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
  static const workRoster = '/profile/work-roster';
  static const placeholder = '/profile/placeholder';
  static const campManagement = '/camp-management';

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
          builder: (_) => const MyEventsScreen(),
          settings: settings,
        );

      case workRoster:
        return MaterialPageRoute<void>(
          builder: (_) => const WorkRosterScreen(),
          settings: settings,
        );

      case placeholder:
        final title = (settings.arguments as String?) ?? 'Portal';
        return MaterialPageRoute<void>(
          builder: (_) => ProfileSectionPlaceholderScreen(title: title),
          settings: settings,
        );

      case campManagement:
        return MaterialPageRoute<void>(
          builder: (_) => const CampManagementShell(),
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

  // Helper shortcuts for navigation
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
