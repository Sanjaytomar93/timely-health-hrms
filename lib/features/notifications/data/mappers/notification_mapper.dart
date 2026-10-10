import 'package:timelay_health/features/notifications/data/models/notification_model.dart';
import 'package:timelay_health/features/notifications/domain/entities/app_notification.dart';

class NotificationMapper {
  const NotificationMapper._();

  static AppNotification toEntity(NotificationModel model) {
    return AppNotification(
      id: model.id,
      userId: model.userId,
      role: model.role,
      title: model.title,
      message: model.message,
      type: model.type,
      isRead: model.isRead,
      createdAt: model.createdAt,
    );
  }
}
