class PayslipEndpoints {
  const PayslipEndpoints._();

  static const String _base = 'https://api.timelyhealth.in/api';

  static String salaryForDate({
    required String employeeId,
    required String date,
  }) {
    return '$_base/employees/${Uri.encodeComponent(employeeId)}'
        '/salary-for-date?date=${Uri.encodeQueryComponent(date)}';
  }

  static String salarySummary({
    required String employeeId,
    required String month,
  }) {
    return Uri.parse(
      '$_base/employees/salary-summary/${Uri.encodeComponent(employeeId)}',
    ).replace(queryParameters: {'month': month}).toString();
  }
}
