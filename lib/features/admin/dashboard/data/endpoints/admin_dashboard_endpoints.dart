class AdminDashboardEndpoints {
  const AdminDashboardEndpoints._();

  static const String _base = 'https://api.timelyhealth.in/api';

  static String summary({required int month, required int year}) =>
      '$_base/dashboard/summary?month=$month&year=$year';
}
