class DigitalLeadsEndpoints {
  const DigitalLeadsEndpoints._();

  static const String _base = 'https://api.timelyhealth.in/api';

  static String consultationLeads({int page = 1, int limit = 100}) =>
      '$_base/consultation-leads?page=$page&limit=$limit';
}
