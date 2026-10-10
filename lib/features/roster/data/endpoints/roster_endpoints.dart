class RosterEndpoints {
  const RosterEndpoints._();

  static const String _base = 'https://api.timelyhealth.in/api';

  static String myWeekOff({
    required String employeeId,
    required String month,
  }) =>
      '$_base/shifts/my-week-off'
      '?employeeId=${Uri.encodeQueryComponent(employeeId)}'
      '&month=${Uri.encodeQueryComponent(month)}';
}
