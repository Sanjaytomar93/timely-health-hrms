class AttendanceFailure implements Exception {
  const AttendanceFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
