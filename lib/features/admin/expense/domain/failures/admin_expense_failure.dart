class AdminExpenseFailure implements Exception {
  const AdminExpenseFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
