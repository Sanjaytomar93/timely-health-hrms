class LeaveEndpoints {
  const LeaveEndpoints._();

  static const String _base = 'https://api.timelyhealth.in/api';

  static const String add = '$_base/leaves/add-leave';

  static String employeeLeaves(
    String employeeId, {
    required int month,
    required int year,
  }) =>
      '$_base/leaves/employeeleaves/${Uri.encodeComponent(employeeId)}'
      '?month=$month&year=$year';

  static String compOffRequests(String employeeId) =>
      '$_base/leaves/comp-off-requests/employee/${Uri.encodeComponent(employeeId)}';

  static String extraWorkedDays(String employeeId) =>
      '$_base/leaves/extra-worked-days/${Uri.encodeComponent(employeeId)}';

  static const String addCompOff = '$_base/leaves/comp-off-requests';
}
