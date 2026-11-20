import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:timelay_health/features/admin/attendance/data/endpoints/late_today_endpoints.dart';
import 'package:timelay_health/features/admin/attendance/domain/failures/attendance_records_failure.dart';

class LateTodayRemoteDataSource {
  LateTodayRemoteDataSource({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>> getLateToday({
    String? date,
    String? month,
  }) async {
    final url = LateTodayEndpoints.lateToday(date: date, month: month);

    late final http.Response response;
    try {
      response = await _client.get(
        Uri.parse(url),
        headers: const {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const AttendanceRecordsFailure(
        'Unable to reach server. Please check your internet connection.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const AttendanceRecordsFailure('Failed to load late attendance records.');
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      throw const AttendanceRecordsFailure('Unexpected response format from server.');
    } catch (e) {
      if (e is AttendanceRecordsFailure) rethrow;
      throw const AttendanceRecordsFailure('Invalid JSON response from server.');
    }
  }
}
