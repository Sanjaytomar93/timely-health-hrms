class AttendanceRecordsFailure implements Exception {
  const AttendanceRecordsFailure(this.message);
  final String message;

  @override
  String toString() => message;
}
