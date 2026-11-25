class AdminShiftFailure implements Exception {
  const AdminShiftFailure(this.message);
  final String message;

  @override
  String toString() => message;
}
