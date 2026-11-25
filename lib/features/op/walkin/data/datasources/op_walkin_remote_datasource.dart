import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:timelay_health/features/op/walkin/data/endpoints/op_walkin_endpoints.dart';
import 'package:timelay_health/features/op/walkin/presentation/models/op_inactive_patient_ui.dart';

class OpWalkinRemoteDataSource {
  OpWalkinRemoteDataSource({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;
  static final Map<String, Map<String, dynamic>> _bookingsCache = {};

  Future<List<OpInactivePatientUi>> getInactiveBookings() async {
    final response = await _client
        .get(
          Uri.parse(OpWalkinEndpoints.getAllInactiveBookings()),
          headers: const {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Cache-Control': 'no-cache, no-store, must-revalidate',
            'Pragma': 'no-cache',
            'Expires': '0',
          },
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic> && decoded['bookings'] is List) {
        final list = decoded['bookings'] as List;
        return list
            .whereType<Map<String, dynamic>>()
            .map(OpInactivePatientUi.fromJson)
            .toList();
      }
    }
    throw Exception('Failed to load inactive bookings: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> getAllBookings({
    String? apptFrom,
    String? apptTo,
  }) async {
    final url = OpWalkinEndpoints.getAllBookings(
      apptFrom: apptFrom,
      apptTo: apptTo,
    );
    final response = await _client
        .get(
          Uri.parse(url),
          headers: const {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Cache-Control': 'no-cache, no-store, must-revalidate',
            'Pragma': 'no-cache',
            'Expires': '0',
          },
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        _bookingsCache[url] = decoded;
        return decoded;
      }
    } else if (response.statusCode == 304 && _bookingsCache.containsKey(url)) {
      // If 304 Not Modified is returned, serve cached response safely
      return _bookingsCache[url]!;
    }
    throw Exception('Failed to load bookings: ${response.statusCode}');
  }
}
