import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:timelay_health/features/camp/dashboard/data/endpoints/dashboard_endpoints.dart';
import 'package:timelay_health/features/camp/dashboard/data/models/volunteer_dashboard_model.dart';
import 'package:timelay_health/features/camp/dashboard/domain/failures/dashboard_failure.dart';

class DashboardRemoteDataSource {
  DashboardRemoteDataSource({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  Future<VolunteerDashboardModel> getVolunteerDashboard(
    String employeeName,
  ) async {
    final name = employeeName.trim();
    if (name.isEmpty) {
      throw const DashboardFailure(
        'Employee name missing. Please login again.',
      );
    }

    late final http.Response response;
    try {
      response = await _client
          .get(
            Uri.parse(DashboardEndpoints.volunteerDashboard(name)),
            headers: const {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const DashboardFailure(
        'Unable to reach server. Check your internet connection.',
      );
    }

    final body = _decode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw DashboardFailure(_message(body, 'Failed to load dashboard.'));
    }

    try {
      if (body['success'] == false) {
        throw DashboardFailure(_message(body, 'Failed to load dashboard.'));
      }
      final raw = body['data'];
      if (raw is! Map<String, dynamic>) {
        throw const FormatException('Unexpected dashboard response');
      }
      return VolunteerDashboardModel.fromJson(raw);
    } on DashboardFailure {
      rethrow;
    } catch (_) {
      throw const DashboardFailure(
        'Unexpected server response. Please try again.',
      );
    }
  }

  Map<String, dynamic> _decode(String raw) {
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : const {};
    } catch (_) {
      return const {};
    }
  }

  String _message(Map<String, dynamic> body, String fallback) {
    final message = body['message']?.toString().trim() ?? '';
    return message.isNotEmpty ? message : fallback;
  }
}
