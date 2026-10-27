class DashboardEndpoints {
  const DashboardEndpoints._();

  static const String _base = 'https://api.timelyhealth.in/api';

  static String empDashboard(
    String employeeId, {
    required int month,
    required int year,
  }) =>
      '$_base/employees/empdashboard/${Uri.encodeComponent(employeeId)}'
      '?month=$month&year=$year';

  // Unused — performance popup now uses empdashboard stats (same as web).
  // static String employeePerformance({
  //   required String employeeCode,
  //   required int month,
  //   required int year,
  // }) {
  //   return Uri.parse(
  //     '$_base/dashboard/employee-performance/${Uri.encodeComponent(employeeCode)}',
  //   ).replace(queryParameters: {'month': '$month', 'year': '$year'}).toString();
  // }
}
