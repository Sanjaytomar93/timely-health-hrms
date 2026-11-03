class PatientFailure implements Exception {
  const PatientFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
