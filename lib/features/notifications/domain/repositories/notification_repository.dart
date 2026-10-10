import 'package:timelay_health/features/notifications/domain/entities/app_notification.dart';

abstract class NotificationRepository {
  Future<List<AppNotification>> getNotifications(String employeeId);
  Future<void> markAllRead(String employeeId);
  Future<void> markRead(String notificationId);
  Future<int> deleteNotifications(List<String> notificationIds);
}
