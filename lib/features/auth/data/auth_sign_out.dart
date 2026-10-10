import 'package:timelay_health/core/notifications/push_notification_service.dart';
import 'package:timelay_health/features/auth/data/auth_session.dart';
import 'package:timelay_health/features/auth/data/datasources/auth_remote_datasource.dart';

class AuthSignOut {
  AuthSignOut._();

  static Future<void> run() async {
    final employee = AuthSession.currentEmployee ?? await AuthSession.load();
    final liveToken = await PushNotificationService.currentToken();
    final storedToken = await AuthSession.loadFcmToken();
    final fcmToken = liveToken.isNotEmpty ? liveToken : storedToken;

    await AuthRemoteDataSource().logout(
      employeeId: employee?.employeeId ?? '',
      email: employee?.email ?? '',
      fcmToken: fcmToken,
    );
    await PushNotificationService.deleteLocalToken();
    await AuthSession.clear();
  }
}
