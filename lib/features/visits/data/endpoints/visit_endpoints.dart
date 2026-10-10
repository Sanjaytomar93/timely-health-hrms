class VisitEndpoints {
  const VisitEndpoints._();

  static const String _base = 'https://api.timelyhealth.in/api';

  static const String add = '$_base/call-data/add';

  static String myVisits(String employeeId) =>
      '$_base/call-data/my?employeeId=${Uri.encodeQueryComponent(employeeId)}';

  static String edit(String id) =>
      '$_base/call-data/edit/${Uri.encodeComponent(id)}';

  static String delete(String id) =>
      '$_base/call-data/delete/${Uri.encodeComponent(id)}';
}
