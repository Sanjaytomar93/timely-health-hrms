class BulkPayrollFailure implements Exception {
  const BulkPayrollFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
