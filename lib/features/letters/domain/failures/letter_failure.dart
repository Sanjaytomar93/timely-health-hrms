class LetterFailure implements Exception {
  const LetterFailure(this.message);
  final String message;

  @override
  String toString() => message;
}
