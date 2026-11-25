class NotificationEndpoints {
  const NotificationEndpoints._();

  static const String _base = 'https://api.timelyhealth.in/api';

  static String list(String userId) =>
      '$_base/notifications/${userId.trim()}';

  static String readAll(String userId) =>
      '$_base/notifications/read-all/${userId.trim()}';

  static String readOne(String id) =>
      '$_base/notifications/read/${id.trim()}';

  static const String delete = '$_base/notifications/delete';
}
