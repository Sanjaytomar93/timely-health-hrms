class DashboardFailure implements Exception {
  const DashboardFailure(this.message);
  final String message;

  @override
  String toString() => message;
}
