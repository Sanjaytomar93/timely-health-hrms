import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:timelay_health/features/admin/shift/data/endpoints/admin_shift_endpoints.dart';
import 'package:timelay_health/features/admin/shift/domain/failures/admin_shift_failure.dart';

class AdminShiftRemoteDataSource {
  AdminShiftRemoteDataSource({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>> getAssignments() async {
    late final http.Response response;
    try {
      response = await _client
          .get(
            Uri.parse(AdminShiftEndpoints.assignments),
            headers: const {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const AdminShiftFailure(
        'Unable to reach server. Please check your internet connection.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const AdminShiftFailure('Failed to load shift assignments.');
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      throw const AdminShiftFailure(
        'Unexpected response format from server.',
      );
    } catch (e) {
      if (e is AdminShiftFailure) rethrow;
      throw const AdminShiftFailure('Invalid JSON response from server.');
    }
  }
}
