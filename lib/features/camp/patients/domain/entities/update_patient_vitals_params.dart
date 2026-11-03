class UpdatePatientVitalsParams {
  const UpdatePatientVitalsParams({
    required this.patientId,
    required this.weight,
    required this.height,
    required this.sugar,
    required this.systolic,
    required this.diastolic,
    required this.sugarType,
  });

  final String patientId;
  final num weight;
  final num height;
  final num sugar;
  final num systolic;
  final num diastolic;
  final String sugarType;
}
