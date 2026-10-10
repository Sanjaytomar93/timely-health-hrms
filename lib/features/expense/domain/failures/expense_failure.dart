class ExpenseFailure implements Exception {
  const ExpenseFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
