import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:timelay_health/features/admin/employees/data/endpoints/employee_list_endpoints.dart';
import 'package:timelay_health/features/admin/employees/domain/failures/employee_list_failure.dart';

class EmployeeListRawData {
  const EmployeeListRawData({
    required this.employees,
    this.stats,
  });

  final List<Map<String, dynamic>> employees;
  final Map<String, dynamic>? stats;
}

class EmployeeListRemoteDataSource {
  EmployeeListRemoteDataSource({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  Future<EmployeeListRawData> getEmployeeData() async {
    late final http.Response response;
    try {
      response = await _client
          .get(
            Uri.parse(EmployeeListEndpoints.getEmployees),
            headers: const {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const EmployeeListFailure(
        'Unable to reach server. Please check your internet connection.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const EmployeeListFailure('Failed to load employee list.');
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return EmployeeListRawData(
          employees: decoded.whereType<Map<String, dynamic>>().toList(),
        );
      }
      if (decoded is Map<String, dynamic>) {
        final rawEmployees = decoded['employees'] ??
            decoded['data'] ??
            decoded['records'] ??
            decoded['result'];
        final list = (rawEmployees is List)
            ? rawEmployees.whereType<Map<String, dynamic>>().toList()
            : <Map<String, dynamic>>[];
        final stats = decoded['stats'] is Map<String, dynamic>
            ? decoded['stats'] as Map<String, dynamic>
            : null;
        return EmployeeListRawData(
          employees: list,
          stats: stats,
        );
      }
      return const EmployeeListRawData(employees: []);
    } catch (_) {
      throw const EmployeeListFailure('Unexpected response format from server.');
    }
  }

  Future<List<Map<String, dynamic>>> getEmployees() async {
    final raw = await getEmployeeData();
    return raw.employees;
  }
}
