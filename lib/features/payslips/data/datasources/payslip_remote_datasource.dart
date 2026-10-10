import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:timelay_health/features/payslips/data/endpoints/payslip_endpoints.dart';
import 'package:timelay_health/features/payslips/data/models/payslip_model.dart';
import 'package:timelay_health/features/payslips/data/models/salary_summary_model.dart';
import 'package:timelay_health/features/payslips/domain/failures/payslip_failure.dart';

class PayslipRemoteDataSource {
  PayslipRemoteDataSource({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Future<PayslipModel> getSalaryForDate({
    required String employeeId,
    required String date,
  }) async {
    final id = employeeId.trim();
    if (id.isEmpty) {
      throw const PayslipFailure('Employee ID missing. Please login again.');
    }

    late final http.Response response;
    try {
      response = await _client
          .get(
            Uri.parse(
              PayslipEndpoints.salaryForDate(employeeId: id, date: date),
            ),
            headers: const {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const PayslipFailure(
        'Unable to reach server. Check your internet connection.',
      );
    }

    final body = _decode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw PayslipFailure(_message(body, 'Failed to load payslip.'));
    }

    try {
      final data = body['data'];
      if (data is Map<String, dynamic>) {
        return PayslipModel.fromJson(data);
      }
      if (body['salaryPerMonth'] != null) {
        return PayslipModel.fromJson(body);
      }
      throw const FormatException('Unexpected payslip response');
    } on PayslipFailure {
      rethrow;
    } catch (_) {
      throw const PayslipFailure(
        'Unexpected server response. Please try again.',
      );
    }
  }

  Future<SalarySummaryModel> getSalarySummary({
    required String employeeId,
    required String month,
  }) async {
    final id = employeeId.trim();
    if (id.isEmpty) {
      throw const PayslipFailure('Employee ID missing. Please login again.');
    }

    late final http.Response response;
    try {
      response = await _client
          .get(
            Uri.parse(
              PayslipEndpoints.salarySummary(employeeId: id, month: month),
            ),
            headers: const {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const PayslipFailure(
        'Unable to reach server. Check your internet connection.',
      );
    }

    final body = _decode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw PayslipFailure(_message(body, 'Failed to load salary summary.'));
    }
    if (body['success'] == false) {
      throw PayslipFailure(_message(body, 'Failed to load salary summary.'));
    }

    try {
      return SalarySummaryModel.fromJson(body);
    } catch (_) {
      throw const PayslipFailure(
        'Unexpected server response. Please try again.',
      );
    }
  }

  Map<String, dynamic> _decode(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      return const {};
    } catch (_) {
      return const {};
    }
  }

  String _message(Map<String, dynamic> body, String fallback) {
    final msg = body['message'] ?? body['error'] ?? body['msg'];
    if (msg is String && msg.trim().isNotEmpty) return msg.trim();
    return fallback;
  }
}
