import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:timelay_health/features/admin/expense/data/endpoints/admin_expense_endpoints.dart';
import 'package:timelay_health/features/admin/expense/domain/failures/admin_expense_failure.dart';

class AdminExpenseRemoteDataSource {
  AdminExpenseRemoteDataSource({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>> getAllExpenses({
    String? month,
    String? year,
    String? date,
  }) async {
    late final http.Response response;
    try {
      response = await _client
          .get(
            Uri.parse(
              AdminExpenseEndpoints.all(
                month: month,
                year: year,
                date: date,
              ),
            ),
            headers: const {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 45));
    } catch (_) {
      throw const AdminExpenseFailure(
        'Unable to reach server. Check your internet connection.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const AdminExpenseFailure('Failed to load expenses.');
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const AdminExpenseFailure(
          'Unexpected response format from server.',
        );
      }
      if (decoded['success'] == false) {
        final msg = decoded['message'] ?? decoded['error'] ?? decoded['msg'];
        throw AdminExpenseFailure(
          msg is String && msg.trim().isNotEmpty
              ? msg.trim()
              : 'Failed to load expenses.',
        );
      }
      return decoded;
    } on AdminExpenseFailure {
      rethrow;
    } catch (_) {
      throw const AdminExpenseFailure('Failed to parse expense response.');
    }
  }
}
