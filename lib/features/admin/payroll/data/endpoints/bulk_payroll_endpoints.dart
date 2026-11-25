class BulkPayrollEndpoints {
  const BulkPayrollEndpoints._();

  static const String _base = 'https://api.timelyhealth.in/api';

  static String bulkPayroll(String month) =>
      '$_base/attendancesummary/bulk-payroll?month=${Uri.encodeQueryComponent(month)}';
}
