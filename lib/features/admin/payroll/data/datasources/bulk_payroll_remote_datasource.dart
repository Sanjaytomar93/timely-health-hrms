import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:timelay_health/features/admin/payroll/data/endpoints/bulk_payroll_endpoints.dart';
import 'package:timelay_health/features/admin/payroll/domain/failures/bulk_payroll_failure.dart';

class BulkPayrollRemoteDataSource {
  BulkPayrollRemoteDataSource({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>> getBulkPayroll({required String month}) async {
    late final http.Response response;
    try {
      response = await _client
          .get(
            Uri.parse(BulkPayrollEndpoints.bulkPayroll(month)),
            headers: const {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 45));
    } catch (_) {
      throw const BulkPayrollFailure(
        'Unable to reach server. Check your internet connection.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const BulkPayrollFailure('Failed to load payroll data.');
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const BulkPayrollFailure('Unexpected response format from server.');
      }
      if (decoded['success'] == false) {
        final msg = decoded['message'] ?? decoded['error'] ?? decoded['msg'];
        throw BulkPayrollFailure(
          msg is String && msg.trim().isNotEmpty
              ? msg.trim()
              : 'Failed to load payroll data.',
        );
      }
      return decoded;
    } on BulkPayrollFailure {
      rethrow;
    } catch (_) {
      throw const BulkPayrollFailure('Failed to parse payroll response.');
    }
  }
}
