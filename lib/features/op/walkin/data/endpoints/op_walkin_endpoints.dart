class OpWalkinEndpoints {
  const OpWalkinEndpoints._();

  static const String _base = 'https://api.timelyhealth.in/api';

  static String getAllInactiveBookings() =>
      '$_base/appointment-slots/getallinactivebookings';

  static String getAllBookings({String? apptFrom, String? apptTo}) {
    final params = <String, String>{};
    if (apptFrom != null && apptFrom.isNotEmpty) {
      params['apptFrom'] = apptFrom;
    }
    if (apptTo != null && apptTo.isNotEmpty) {
      params['apptTo'] = apptTo;
    }
    return Uri.parse('$_base/appointment-slots/getallbookings')
        .replace(queryParameters: params.isNotEmpty ? params : null)
        .toString();
  }
}
