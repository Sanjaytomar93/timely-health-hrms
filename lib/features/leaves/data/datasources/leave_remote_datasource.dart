import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:timelay_health/features/leaves/data/endpoints/leave_endpoints.dart';
import 'package:timelay_health/features/leaves/data/mappers/leave_mapper.dart';
import 'package:timelay_health/features/leaves/data/models/leave_record_model.dart';
import 'package:timelay_health/features/leaves/domain/entities/leave_record.dart';
import 'package:timelay_health/features/leaves/domain/failures/leave_failure.dart';

class LeaveRemoteDataSource {
  LeaveRemoteDataSource({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Future<EmployeeLeavesResponseModel> getEmployeeLeaves({
    required String employeeId,
    required int month,
    required int year,
  }) async {
    final id = employeeId.trim();
    if (id.isEmpty) {
      throw const LeaveFailure('Employee ID missing. Please login again.');
    }

    late final http.Response response;
    try {
      response = await _client
          .get(
            Uri.parse(
              LeaveEndpoints.employeeLeaves(id, month: month, year: year),
            ),
            headers: const {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const LeaveFailure(
        'Unable to reach server. Check your internet connection.',
      );
    }

    final body = _decode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw LeaveFailure(_message(body, 'Failed to load leaves.'));
    }

    final parsed = EmployeeLeavesResponseModel.fromJson(body);
    if (!parsed.success) {
      throw const LeaveFailure('Failed to load leaves.');
    }
    return parsed;
  }

  Future<CompOffRequestsResponseModel> getCompOffRequests({
    required String employeeId,
  }) async {
    final id = employeeId.trim();
    if (id.isEmpty) {
      throw const LeaveFailure('Employee ID missing. Please login again.');
    }

    late final http.Response response;
    try {
      response = await _client
          .get(
            Uri.parse(LeaveEndpoints.compOffRequests(id)),
            headers: const {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const LeaveFailure(
        'Unable to reach server. Check your internet connection.',
      );
    }

    final body = _decode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw LeaveFailure(_message(body, 'Failed to load comp-off requests.'));
    }

    final parsed = CompOffRequestsResponseModel.fromJson(body);
    if (!parsed.success) {
      throw const LeaveFailure('Failed to load comp-off requests.');
    }
    return parsed;
  }

  Future<LeaveRecordModel> addLeave(AddLeaveParams params) async {
    if (params.employeeId.trim().isEmpty) {
      throw const LeaveFailure('Employee ID missing. Please login again.');
    }
    if (params.leaveType.trim().isEmpty) {
      throw const LeaveFailure('Please select leave type.');
    }
    if (params.reason.trim().isEmpty) {
      throw const LeaveFailure('Please enter reason.');
    }
    if (params.days <= 0) {
      throw const LeaveFailure('Please select a valid date range.');
    }

    late final http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse(LeaveEndpoints.add),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(LeaveMapper.toAddRequest(params).toJson()),
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const LeaveFailure(
        'Unable to reach server. Check your internet connection.',
      );
    }

    final body = _decode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw LeaveFailure(_message(body, 'Failed to apply leave.'));
    }

    try {
      return AddLeaveResponseModel.fromJson(body).leave;
    } catch (_) {
      throw const LeaveFailure('Unexpected server response. Please try again.');
    }
  }

  Map<String, dynamic> _decode(String raw) {
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      throw const LeaveFailure('Unexpected server response. Please try again.');
    }
  }

  String _message(Map<String, dynamic> body, String fallback) {
    final message = body['message']?.toString();
    return message?.isNotEmpty == true ? message! : fallback;
  }
}
