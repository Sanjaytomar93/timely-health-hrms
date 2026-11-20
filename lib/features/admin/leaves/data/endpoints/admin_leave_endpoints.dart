class AdminLeaveEndpoints {
  const AdminLeaveEndpoints._();

  static const String _base = 'https://api.timelyhealth.in/api';

  static const String getLeaves = '$_base/leaves/leaves';

  static String updateLeave(String id) => '$_base/leaves/updateleaves/$id';
}
