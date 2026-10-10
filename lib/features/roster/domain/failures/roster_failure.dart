class RosterFailure implements Exception {
  const RosterFailure(this.message);
  final String message;

  @override
  String toString() => message;
}
