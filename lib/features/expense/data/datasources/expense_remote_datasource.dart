import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:timelay_health/features/expense/data/endpoints/expense_endpoints.dart';
import 'package:timelay_health/features/expense/data/models/add_expense_request_model.dart';
import 'package:timelay_health/features/expense/data/models/expense_claim_model.dart';
import 'package:timelay_health/features/expense/data/models/update_expense_request_model.dart';
import 'package:timelay_health/features/expense/domain/entities/add_expense_params.dart';
import 'package:timelay_health/features/expense/domain/entities/update_expense_params.dart';
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

  Future<ExpenseClaimModel> updateExpense(UpdateExpenseParams params) async {
    final id = params.id.trim();
    if (id.isEmpty) {
      throw const ExpenseFailure('Expense ID missing.');
    }
    if (params.purpose.trim().isEmpty) {
      throw const ExpenseFailure('Please enter purpose of travel.');
    }
    if (params.stops.isEmpty) {
      throw const ExpenseFailure('Please add at least one stop.');
    }

    final request = UpdateExpenseRequestModel.fromParams(params);
    final uri = Uri.parse(ExpenseEndpoints.update(id));

    late final http.Response response;
    try {
      response = await _client
          .put(
            uri,
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const ExpenseFailure(
        'Unable to reach server. Check your internet connection.',
      );
    }

    final body = response.body.trim().isEmpty
        ? <String, dynamic>{}
        : _tryDecodeBody(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = body['message']?.toString();
      throw ExpenseFailure(
        message?.isNotEmpty == true ? message! : 'Failed to update expense.',
      );
    }

    final success = body['success'];
    if (success == false) {
      final message = body['message']?.toString();
      throw ExpenseFailure(
        message?.isNotEmpty == true ? message! : 'Failed to update expense.',
      );
    }

    final expenseJson = body['expense'] ?? body['data'];
    if (expenseJson is Map<String, dynamic>) {
      return ExpenseClaimModel.fromJson(expenseJson);
    }

    return ExpenseClaimModel(
      id: id,
      employeeId: '',
      purpose: params.purpose,
      date: params.date,
      km: params.km,
      rateApplied: 0,
      totalAmount: 0,
      orderValue: params.orderValue,
      upsellValue: params.upsellValue,
      remark: params.remark,
      stops: [
        for (final s in params.stops)
          ExpenseStopModel(
            id: '',
            locationName: s.locationName,
            outcome: s.outcome,
            orderValue: s.orderValue,
            upsellValue: s.upsellValue,
            km: s.km,
            amount: 0,
          ),
      ],
    );
  }

  Future<void> deleteExpense({required String id}) async {
    final expenseId = id.trim();
    if (expenseId.isEmpty) {
      throw const ExpenseFailure('Expense ID missing.');
    }

    late final http.Response response;
    try {
      response = await _client
          .delete(
            Uri.parse(ExpenseEndpoints.delete(expenseId)),
            headers: const {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const ExpenseFailure(
        'Unable to reach server. Check your internet connection.',
      );
    }

    final body = response.body.trim().isEmpty
        ? <String, dynamic>{}
        : _decodeBody(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = body['message']?.toString();
      throw ExpenseFailure(
        message?.isNotEmpty == true ? message! : 'Failed to delete expense.',
      );
    }

    final success = body['success'] as bool? ?? true;
    if (!success) {
      final message = body['message']?.toString();
      throw ExpenseFailure(
        message?.isNotEmpty == true ? message! : 'Failed to delete expense.',
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

  Map<String, dynamic> _tryDecodeBody(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      return <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }
}
