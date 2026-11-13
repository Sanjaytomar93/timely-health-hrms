class PayslipEndpoints {
  const PayslipEndpoints._();

  static const String _base = 'https://api.timelyhealth.in/api';

  static String salarySummary({
    required String employeeId,
    required String month,
  }) {
    return Uri.parse(
      '$_base/employees/salary-summary/${Uri.encodeComponent(employeeId)}',
    ).replace(queryParameters: {'month': month}).toString();
  }
}
