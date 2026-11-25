import 'dart:async';

import 'package:timelay_health/core/notifications/push_notification_service.dart';
import 'package:timelay_health/features/auth/data/auth_session.dart';
import 'package:timelay_health/features/auth/data/datasources/auth_remote_datasource.dart';

class AuthSignOut {
  AuthSignOut._();

  /// Instant local logout (same feel as old account logout).
  /// Server/FCM cleanup runs in background.
  static Future<void> run() async {
    final employee = AuthSession.currentEmployee;
    final employeeId = employee?.employeeId ?? '';
    final email = employee?.email ?? '';
    final fcmToken = await AuthSession.loadFcmToken();

    AuthSession.currentEmployee = null;
    await AuthSession.clear();

    unawaited(
      _remoteCleanup(
        employeeId: employeeId,
        email: email,
        fcmToken: fcmToken,
      ),
    );
  }

  static Future<void> _remoteCleanup({
    required String employeeId,
    required String email,
    required String fcmToken,
  }) async {
    try {
      await AuthRemoteDataSource()
          .logout(
            employeeId: employeeId,
            email: email,
            fcmToken: fcmToken,
          )
          .timeout(const Duration(seconds: 3));
    } catch (_) {}
    try {
      await PushNotificationService.deleteLocalToken().timeout(
        const Duration(seconds: 2),
      );
    } catch (_) {}
  }
}
