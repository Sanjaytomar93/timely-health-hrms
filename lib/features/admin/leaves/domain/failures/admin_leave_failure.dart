class AdminLeaveFailure implements Exception {
  const AdminLeaveFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
