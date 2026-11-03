class PatientEndpoints {
  const PatientEndpoints._();

  static const String _base = 'http://62.72.29.27:5000/api';

  static const String patients = '$_base/patients';

  static String assignedPatients(String employeeName) =>
      '$patients/assignedpatients'
      '?employeeName=${Uri.encodeQueryComponent(employeeName)}';

  static String patientById(String patientId) =>
      '$patients/${Uri.encodeComponent(patientId.trim())}';

  static String patientTests(String patientId) =>
      '${patientById(patientId)}/tests';
}
