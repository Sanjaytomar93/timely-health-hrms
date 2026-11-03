class DashboardEndpoints {
  const DashboardEndpoints._();

  static const String _base = 'http://62.72.29.27:5000/api';

  static String volunteerDashboard(String employeeName) =>
      '$_base/camps/getvolunteerdashboard'
      '?employeeName=${Uri.encodeQueryComponent(employeeName)}';
}
