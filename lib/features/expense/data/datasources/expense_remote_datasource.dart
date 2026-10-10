import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:timelay_health/features/expense/data/endpoints/expense_endpoints.dart';
import 'package:timelay_health/features/expense/data/models/add_expense_request_model.dart';
import 'package:timelay_health/features/expense/data/models/expense_claim_model.dart';
import 'package:timelay_health/features/expense/domain/entities/add_expense_params.dart';
import 'package:timelay_health/features/expense/domain/failures/expense_failure.dart';

class ExpenseRemoteDataSource {
  ExpenseRemoteDataSource({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Future<MyExpensesResponseModel> getMyExpenses({
    required String employeeId,
  }) async {
    final id = employeeId.trim();
    if (id.isEmpty) {
      throw const ExpenseFailure('Employee ID missing. Please login again.');
    }

    late final http.Response response;
    try {
      response = await _client
          .get(
            Uri.parse(ExpenseEndpoints.myExpenses(id)),
            headers: const {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const ExpenseFailure(
        'Unable to reach server. Check your internet connection.',
      );
    }

    final body = _decodeBody(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = body['message']?.toString();
      throw ExpenseFailure(
        message?.isNotEmpty == true ? message! : 'Failed to load expenses.',
      );
    }

    final parsed = MyExpensesResponseModel.fromJson(body);
    if (!parsed.success) {
      throw const ExpenseFailure('Failed to load expenses.');
    }
    return parsed;
  }

  Future<ExpenseClaimModel> addExpense(AddExpenseParams params) async {
    if (params.employeeId.trim().isEmpty) {
      throw const ExpenseFailure('Employee ID missing. Please login again.');
    }
    if (params.purpose.trim().isEmpty) {
      throw const ExpenseFailure('Please enter purpose of travel.');
    }
    if (params.stops.isEmpty) {
      throw const ExpenseFailure('Please add at least one stop.');
    }

    final request = AddExpenseRequestModel.fromParams(params);

    late final http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse(ExpenseEndpoints.add),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const ExpenseFailure(
        'Unable to reach server. Check your internet connection.',
      );
    }

    final body = _decodeBody(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = body['message']?.toString();
      throw ExpenseFailure(
        message?.isNotEmpty == true ? message! : 'Failed to record expense.',
      );
    }

    try {
      final parsed = AddExpenseResponseModel.fromJson(body);
      if (!parsed.success) {
        throw ExpenseFailure(
          parsed.message.isNotEmpty
              ? parsed.message
              : 'Failed to record expense.',
        );
      }
      return parsed.expense;
    } on ExpenseFailure {
      rethrow;
    } catch (_) {
      throw const ExpenseFailure(
        'Unexpected server response. Please try again.',
      );
    }
  }

  Map<String, dynamic> _decodeBody(String raw) {
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      throw const ExpenseFailure(
        'Unexpected server response. Please try again.',
      );
    }
  }
}
