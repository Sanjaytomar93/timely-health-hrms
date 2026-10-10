import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:timelay_health/features/roster/data/endpoints/roster_endpoints.dart';
import 'package:timelay_health/features/roster/data/models/week_off_model.dart';
import 'package:timelay_health/features/roster/domain/failures/roster_failure.dart';

class RosterRemoteDataSource {
  RosterRemoteDataSource({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Future<WeekOffModel> getMyWeekOff({
    required String employeeId,
    required String month,
  }) async {
    final id = employeeId.trim();
    if (id.isEmpty) {
      throw const RosterFailure('Employee ID missing. Please login again.');
    }

    late final http.Response response;
    try {
      response = await _client
          .get(
            Uri.parse(RosterEndpoints.myWeekOff(employeeId: id, month: month)),
            headers: const {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const RosterFailure(
        'Unable to reach server. Check your internet connection.',
      );
    }

    final body = _decodeBody(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw RosterFailure(_message(body, 'Failed to load week-offs.'));
    }

    final parsed = MyWeekOffResponseModel.fromJson(body);
    if (!parsed.success) {
      throw RosterFailure(_message(body, 'Failed to load week-offs.'));
    }
    return parsed.data;
  }

  Map<String, dynamic> _decodeBody(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      return const {};
    } catch (_) {
      throw const RosterFailure(
        'Unexpected server response. Please try again.',
      );
    }
  }

  String _message(Map<String, dynamic> body, String fallback) {
    final error = body['error']?.toString().trim();
    if (error != null && error.isNotEmpty) return error;
    final msg = body['message']?.toString().trim();
    if (msg != null && msg.isNotEmpty) return msg;
    return fallback;
  }
}
