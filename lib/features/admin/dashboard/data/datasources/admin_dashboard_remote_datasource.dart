import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:timelay_health/features/admin/dashboard/data/endpoints/admin_dashboard_endpoints.dart';
import 'package:timelay_health/features/admin/dashboard/domain/failures/admin_dashboard_failure.dart';

class AdminDashboardRemoteDataSource {
  AdminDashboardRemoteDataSource({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>> getSummary({
    required int month,
    required int year,
  }) async {
    late final http.Response response;
    try {
      response = await _client
          .get(
            Uri.parse(
              AdminDashboardEndpoints.summary(month: month, year: year),
            ),
            headers: const {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 45));
    } catch (_) {
      throw const AdminDashboardFailure(
        'Unable to reach server. Check your internet connection.',
      );
    }

    Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw const AdminDashboardFailure(
        'Unexpected server response. Please try again.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = body['message']?.toString();
      throw AdminDashboardFailure(
        message?.isNotEmpty == true
            ? message!
            : 'Failed to load admin dashboard.',
      );
    }

    final success = body['success'] as bool? ?? true;
    if (!success) {
      throw AdminDashboardFailure(
        body['message']?.toString().isNotEmpty == true
            ? body['message'].toString()
            : 'Failed to load admin dashboard.',
      );
    }

    final data = body['data'];
    if (data is Map<String, dynamic>) return data;
    if (body.containsKey('stats')) return body;

    throw const AdminDashboardFailure(
      'Unexpected server response. Please try again.',
    );
  }
}
