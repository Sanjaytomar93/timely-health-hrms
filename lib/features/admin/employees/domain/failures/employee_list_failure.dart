class EmployeeListFailure implements Exception {
  const EmployeeListFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
