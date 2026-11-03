class CampFailure implements Exception {
  const CampFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
