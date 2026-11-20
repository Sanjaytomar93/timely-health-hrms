class AttendanceSummaryFailure implements Exception {
  const AttendanceSummaryFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
