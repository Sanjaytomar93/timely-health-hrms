class CampEndpoints {
  const CampEndpoints._();

  static const String _base = 'http://62.72.29.27:5000/api';

  static String assignedCamps(String employeeName) =>
      '$_base/camps/assignedcamps'
      '?employeeName=${Uri.encodeQueryComponent(employeeName)}';

  static String patientById(String patientId) =>
      '$_base/patients/${Uri.encodeComponent(patientId.trim())}';
}
