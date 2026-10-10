class IssueFailure implements Exception {
  const IssueFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
