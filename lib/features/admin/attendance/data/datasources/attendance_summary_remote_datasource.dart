import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:timelay_health/features/admin/attendance/data/endpoints/attendance_summary_endpoints.dart';
import 'package:timelay_health/features/admin/attendance/domain/failures/attendance_summary_failure.dart';

class AttendanceSummaryRemoteDataSource {
  AttendanceSummaryRemoteDataSource({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>> getPageData({required String month}) async {
    late final http.Response response;
    try {
      response = await _client
          .get(
            Uri.parse(AttendanceSummaryEndpoints.pageData(month)),
            headers: const {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const AttendanceSummaryFailure(
        'Unable to reach server. Please check your internet connection.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const AttendanceSummaryFailure('Failed to load attendance summary.');
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      throw const AttendanceSummaryFailure('Unexpected response format from server.');
    } catch (e) {
      if (e is AttendanceSummaryFailure) rethrow;
      throw const AttendanceSummaryFailure('Failed to parse attendance summary response.');
    }
  }
}
