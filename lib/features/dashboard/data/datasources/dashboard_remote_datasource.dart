import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:timelay_health/features/dashboard/data/endpoints/dashboard_endpoints.dart';
import 'package:timelay_health/features/dashboard/data/models/employee_dashboard_model.dart';
import 'package:timelay_health/features/dashboard/data/models/employee_performance_model.dart';
import 'package:timelay_health/features/dashboard/domain/failures/dashboard_failure.dart';

class DashboardRemoteDataSource {
  DashboardRemoteDataSource({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Future<EmployeeDashboardModel> getEmployeeDashboard({
    required String employeeId,
    required int month,
    required int year,
  }) async {
    final id = employeeId.trim();
    if (id.isEmpty) {
      throw const DashboardFailure('Employee ID missing. Please login again.');
    }

    late final http.Response response;
    try {
      response = await _client
          .get(
            Uri.parse(
              DashboardEndpoints.empDashboard(id, month: month, year: year),
            ),
            headers: const {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const DashboardFailure(
        'Unable to reach server. Check your internet connection.',
      );
    }

    Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw const DashboardFailure(
        'Unexpected server response. Please try again.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = body['message']?.toString();
      throw DashboardFailure(
        message?.isNotEmpty == true ? message! : 'Failed to load dashboard.',
      );
    }

    final success = body['success'] as bool? ?? true;
    if (!success) {
      throw DashboardFailure(
        body['message']?.toString().isNotEmpty == true
            ? body['message'].toString()
            : 'Failed to load dashboard.',
      );
    }

    try {
      return EmployeeDashboardModel.fromJson(body);
    } catch (_) {
      throw const DashboardFailure(
        'Unexpected server response. Please try again.',
      );
    }
  }

  Future<EmployeePerformanceModel> getEmployeePerformance({
    required String employeeCode,
    required int month,
    required int year,
  }) async {
    final code = employeeCode.trim();
    if (code.isEmpty) {
      throw const DashboardFailure(
        'Employee code missing. Please login again.',
      );
    }

    // Web portal uses empdashboard stats for the monthly review popup.
    late final http.Response response;
    try {
      response = await _client
          .get(
            Uri.parse(
              DashboardEndpoints.empDashboard(code, month: month, year: year),
            ),
            headers: const {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const DashboardFailure(
        'Unable to reach server. Check your internet connection.',
      );
    }

    Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw const DashboardFailure(
        'Unexpected server response. Please try again.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = body['message']?.toString();
      throw DashboardFailure(
        message?.isNotEmpty == true ? message! : 'Failed to load performance.',
      );
    }

    final success = body['success'] as bool? ?? true;
    if (!success) {
      throw DashboardFailure(
        body['message']?.toString().isNotEmpty == true
            ? body['message'].toString()
            : 'Failed to load performance.',
      );
    }

    try {
      return EmployeePerformanceModel.fromDashboardJson(
        body,
        month: month,
        year: year,
      );
    } catch (_) {
      throw const DashboardFailure(
        'Unexpected server response. Please try again.',
      );
    }
  }
}
