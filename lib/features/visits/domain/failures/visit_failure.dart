class VisitFailure implements Exception {
  const VisitFailure(this.message);
  final String message;
  @override
  String toString() => message;
}
