class NotificationFailure implements Exception {
  const NotificationFailure(this.message);
  final String message;

  @override
  String toString() => message;
}
