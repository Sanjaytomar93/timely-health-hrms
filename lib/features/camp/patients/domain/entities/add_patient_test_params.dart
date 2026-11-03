class AddPatientTestParams {
  const AddPatientTestParams({
    required this.patientId,
    required this.type,
    required this.value,
    required this.unit,
    required this.bmi,
    required this.campType,
    required this.campDate,
    required this.campId,
    required this.campLocation,
    required this.campName,
    required this.date,
    this.doctorVerificationStatus = 'pending',
  });

  final String patientId;
  final String type;
  final num value;
  final String unit;
  final double bmi;
  final String campType;
  final DateTime campDate;
  final String campId;
  final String campLocation;
  final String campName;
  final DateTime date;
  final String doctorVerificationStatus;
}
