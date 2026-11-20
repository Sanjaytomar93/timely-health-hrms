class AbsentTodayEndpoints {
  const AbsentTodayEndpoints._();

  static const String _base = 'https://api.timelyhealth.in/api';

  static String absentToday({
    required String fromDate,
    required String toDate,
  }) {
    final params = <String, String>{
      'fromDate': fromDate.trim(),
      'toDate': toDate.trim(),
    };
    return Uri.parse('$_base/attendance/absenttoday')
        .replace(queryParameters: params)
        .toString();
  }
}
