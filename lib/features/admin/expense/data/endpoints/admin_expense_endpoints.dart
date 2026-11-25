class AdminExpenseEndpoints {
  const AdminExpenseEndpoints._();

  static const String _base = 'https://api.timelyhealth.in/api';

  static String all({String? month, String? year, String? date}) {
    final params = <String, String>{};
    if (month != null && month.trim().isNotEmpty) {
      params['month'] = month.trim();
    }
    if (year != null && year.trim().isNotEmpty) {
      params['year'] = year.trim();
    }
    if (date != null && date.trim().isNotEmpty) {
      params['date'] = date.trim();
    }
    if (params.isEmpty) return '$_base/expense/all';
    return Uri.parse('$_base/expense/all').replace(queryParameters: params).toString();
  }
}
