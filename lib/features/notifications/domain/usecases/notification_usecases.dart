import 'package:timelay_health/features/notifications/domain/entities/app_notification.dart';
import 'package:timelay_health/features/notifications/domain/repositories/notification_repository.dart';

class GetNotificationsUseCase {
  const GetNotificationsUseCase(this._repository);
  final NotificationRepository _repository;

  Future<List<AppNotification>> call(String employeeId) {
    return _repository.getNotifications(employeeId);
  }
}

class MarkAllNotificationsReadUseCase {
  const MarkAllNotificationsReadUseCase(this._repository);
  final NotificationRepository _repository;

  Future<void> call(String employeeId) {
    return _repository.markAllRead(employeeId);
  }
}

class DeleteNotificationsUseCase {
  const DeleteNotificationsUseCase(this._repository);
  final NotificationRepository _repository;

  Future<int> call(List<String> notificationIds) {
    return _repository.deleteNotifications(notificationIds);
  }
}

class MarkNotificationReadUseCase {
  const MarkNotificationReadUseCase(this._repository);
  final NotificationRepository _repository;

  Future<void> call(String notificationId) {
    return _repository.markRead(notificationId);
  }
}
