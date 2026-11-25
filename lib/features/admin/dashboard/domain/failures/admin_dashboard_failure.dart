class AdminDashboardFailure implements Exception {
  const AdminDashboardFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
