class EventEndpoints {
  const EventEndpoints._();

  static const String _base = 'https://api.timelyhealth.in/api';

  static const String create = '$_base/events';

  static String myEvents(String userId) => '$_base/events/my-events/$userId';

  static String byId(String eventId) => '$_base/events/$eventId';

  /// Company birthdays/anniversaries. [month] format: `YYYY-MM` (optional).
  static String companyByEmployee({String? month}) {
    final uri = Uri.parse('$_base/events/company-by-employee');
    if (month == null || month.isEmpty) return uri.toString();
    return uri.replace(queryParameters: {'month': month}).toString();
  }
}
