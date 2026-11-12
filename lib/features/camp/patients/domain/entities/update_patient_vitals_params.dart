class UpdatePatientTestItem {
  const UpdatePatientTestItem({
    required this.testId,
    required this.type,
    required this.value,
    required this.unit,
  });

  final String testId;
  final String type;
  final num value;
  final String unit;
}

class UpdatePatientVitalsParams {
  const UpdatePatientVitalsParams({
    required this.patientId,
    required this.tests,
  });

  final String patientId;
  final List<UpdatePatientTestItem> tests;
}
