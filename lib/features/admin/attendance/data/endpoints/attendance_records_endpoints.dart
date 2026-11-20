class AttendanceRecordsEndpoints {
  const AttendanceRecordsEndpoints._();

  static const String _base = 'https://api.timelyhealth.in/api';

  static String pageData({
    required String month,
    int page = 1,
    int limit = 15,
    String? employeeId,
    String? department,
    String? designation,
    String? date,
  }) {
    final params = <String, String>{
      'month': month,
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (employeeId != null && employeeId.trim().isNotEmpty) {
      params['employeeId'] = employeeId.trim();
    }
    if (department != null &&
        department.trim().isNotEmpty &&
        department != 'All Departments') {
      params['department'] = department.trim();
    }
    if (designation != null &&
        designation.trim().isNotEmpty &&
        designation != 'All Designations') {
      params['designation'] = designation.trim();
    }
    if (date != null && date.trim().isNotEmpty) {
      params['date'] = date.trim();
    }
    return Uri.parse('$_base/attendance/page-data')
        .replace(queryParameters: params)
        .toString();
  }
}
