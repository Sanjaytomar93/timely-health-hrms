import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:timelay_health/features/holidays/data/endpoints/holiday_endpoints.dart';
import 'package:timelay_health/features/holidays/data/models/holiday_model.dart';
import 'package:timelay_health/features/holidays/domain/failures/holiday_failure.dart';

class HolidayRemoteDataSource {
  HolidayRemoteDataSource({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<HolidayModel>> getAllHolidays() async {
    late final http.Response response;
    try {
      response = await _client
          .get(
            Uri.parse(HolidayEndpoints.all),
            headers: const {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const HolidayFailure(
        'Unable to reach server. Check your internet connection.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const HolidayFailure('Failed to load holidays.');
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(HolidayModel.fromJson)
            .toList();
      }
      if (decoded is Map<String, dynamic>) {
        final raw =
            decoded['data'] ?? decoded['records'] ?? decoded['holidays'];
        if (raw is List) {
          return raw
              .whereType<Map<String, dynamic>>()
              .map(HolidayModel.fromJson)
              .toList();
        }
      }
      throw const FormatException('Unexpected holidays response');
    } on HolidayFailure {
      rethrow;
    } catch (_) {
      throw const HolidayFailure(
        'Unexpected server response. Please try again.',
      );
    }
  }
}
