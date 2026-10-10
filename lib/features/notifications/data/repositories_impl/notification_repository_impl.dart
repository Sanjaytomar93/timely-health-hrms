import 'package:timelay_health/features/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:timelay_health/features/notifications/data/mappers/notification_mapper.dart';
import 'package:timelay_health/features/notifications/domain/entities/app_notification.dart';
import 'package:timelay_health/features/notifications/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl({NotificationRemoteDataSource? remoteDataSource})
    : _remote = remoteDataSource ?? NotificationRemoteDataSource();

  final NotificationRemoteDataSource _remote;

  @override
  Future<List<AppNotification>> getNotifications(String employeeId) async {
    final models = await _remote.getNotifications(employeeId: employeeId);
    return models.map(NotificationMapper.toEntity).toList();
  }

  @override
  Future<void> markAllRead(String employeeId) {
    return _remote.markAllRead(employeeId: employeeId);
  }

  @override
  Future<void> markRead(String notificationId) {
    return _remote.markRead(notificationId: notificationId);
  }

  @override
  Future<int> deleteNotifications(List<String> notificationIds) {
    return _remote.deleteNotifications(notificationIds: notificationIds);
  }
}
