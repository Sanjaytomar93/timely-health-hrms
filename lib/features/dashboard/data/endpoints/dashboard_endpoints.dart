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
}
