class AttendanceSummaryEndpoints {
  const AttendanceSummaryEndpoints._();

  static const String _base = 'https://api.timelyhealth.in/api';

  static String pageData(String month) =>
      '$_base/attendancesummary/page-data?month=${Uri.encodeQueryComponent(month)}';
}
