class LateTodayEndpoints {
  const LateTodayEndpoints._();

  static const String _base = 'https://api.timelyhealth.in/api';

  static String lateToday({String? date, String? month}) {
    final params = <String, String>{};

    if (date != null && date.trim().isNotEmpty && date.trim() != 'null') {
      params['today'] = date.trim();
    } else {
      params['today'] = 'null';
    }

    if (month != null && month.trim().isNotEmpty && month.trim() != 'null') {
      params['month'] = month.trim();
    }

    return Uri.parse('$_base/attendance/latetoday')
        .replace(queryParameters: params)
        .toString();
  }
}
