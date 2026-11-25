class TodayAttendanceEndpoints {
  const TodayAttendanceEndpoints._();

  static const String _base = 'https://api.timelyhealth.in/api';

  static String today({
    String? fromDate,
    String? toDate,
    int page = 1,
    int limit = 100,
  }) {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (fromDate != null && fromDate.trim().isNotEmpty) {
      params['fromDate'] = fromDate.trim();
    }
    if (toDate != null && toDate.trim().isNotEmpty) {
      params['toDate'] = toDate.trim();
    }
    return Uri.parse('$_base/attendance/today')
        .replace(queryParameters: params)
        .toString();
  }
}
