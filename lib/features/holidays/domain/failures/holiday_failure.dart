class HolidayFailure implements Exception {
  const HolidayFailure(this.message);
  final String message;

  @override
  String toString() => message;
}
