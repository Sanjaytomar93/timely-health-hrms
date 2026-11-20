import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:timelay_health/features/admin/attendance/data/endpoints/today_attendance_endpoints.dart';
import 'package:timelay_health/features/admin/attendance/domain/failures/attendance_records_failure.dart';

class TodayAttendanceRemoteDataSource {
  TodayAttendanceRemoteDataSource({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>> getTodayAttendance() async {
    final url = TodayAttendanceEndpoints.today();

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
      throw const AttendanceRecordsFailure('Failed to load today attendance records.');
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
