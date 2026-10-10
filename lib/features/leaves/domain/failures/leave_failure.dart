class LeaveFailure implements Exception {
  const LeaveFailure(this.message);
  final String message;

  @override
  String toString() => message;
}
