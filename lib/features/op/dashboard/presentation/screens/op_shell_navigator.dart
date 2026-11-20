import 'package:timelay_health/core/routes/app_routes.dart';

typedef OpShellTabOpener = void Function(int tab);

class OpShellNavigator {
  OpShellNavigator._();

  static OpShellTabOpener? _openTab;
  static bool _mounted = false;

  static bool get isActive => _mounted && _openTab != null;

  static void bind(OpShellTabOpener openTab) {
    _openTab = openTab;
    _mounted = true;
  }

  static void unbind(OpShellTabOpener openTab) {
    if (_openTab == openTab) {
      _openTab = null;
      _mounted = false;
    }
  }

  static bool openTab(int tab) {
    final opener = _openTab;
    if (!_mounted || opener == null) return false;
    opener(tab);
    return true;
  }

  static int tabFromRoute(String? routeName) {
    switch (routeName) {
      case AppRoutes.opWalkin:
        return 1;
      case AppRoutes.opDoctors:
        return 2;
      case AppRoutes.opServices:
        return 3;
      case AppRoutes.opOnlineBookings:
        return 4;
      case AppRoutes.opReferralManagement:
        return 5;
      case AppRoutes.opReferralBookings:
        return 6;
      case AppRoutes.opAppointmentSlots:
        return 7;
      case AppRoutes.opRevenueAnalytics:
        return 8;
      case AppRoutes.opDashboard:
      case AppRoutes.opManagement:
      default:
        return 0;
    }
  }
}
