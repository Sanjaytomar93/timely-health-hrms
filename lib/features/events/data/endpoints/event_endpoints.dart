class EventEndpoints {
  const EventEndpoints._();

  static const String _base = 'https://api.timelyhealth.in/api';

  static const String create = '$_base/events';

  static String myEvents(String userId) => '$_base/events/my-events/$userId';

  static String byId(String eventId) => '$_base/events/$eventId';
}
