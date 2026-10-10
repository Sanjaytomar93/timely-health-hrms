class NotificationEndpoints {
  const NotificationEndpoints._();

  static const String _base = 'https://api.timelyhealth.in/api';

  static String list(String employeeId) =>
      '$_base/notifications/${Uri.encodeComponent(employeeId)}';

  static String readAll(String employeeId) =>
      '$_base/notifications/read-all/${Uri.encodeComponent(employeeId)}';

  static String readOne(String id) =>
      '$_base/notifications/read/${Uri.encodeComponent(id)}';

  static const String delete = '$_base/notifications/delete';
}
