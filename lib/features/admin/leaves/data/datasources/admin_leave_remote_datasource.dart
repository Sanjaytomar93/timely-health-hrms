import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:timelay_health/features/admin/leaves/data/endpoints/admin_leave_endpoints.dart';
import 'package:timelay_health/features/admin/leaves/data/models/admin_leave_model.dart';
import 'package:timelay_health/features/admin/leaves/domain/failures/admin_leave_failure.dart';

class AdminLeaveRemoteDataSource {
  AdminLeaveRemoteDataSource({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<AdminLeaveModel>> getLeaves() async {
    late final http.Response response;
    try {
      response = await _client
          .get(
            Uri.parse(AdminLeaveEndpoints.getLeaves),
            headers: const {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const AdminLeaveFailure(
        'Unable to reach server. Please check your internet connection.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const AdminLeaveFailure('Failed to load leave requests.');
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(AdminLeaveModel.fromJson)
            .toList();
      }

      if (decoded is Map<String, dynamic>) {
        final listRaw = decoded['leaves'] ??
            decoded['data'] ??
            decoded['records'] ??
            decoded['result'];
        if (listRaw is List) {
          return listRaw
              .whereType<Map<String, dynamic>>()
              .map(AdminLeaveModel.fromJson)
              .toList();
        }
      }

      return const <AdminLeaveModel>[];
    } catch (e) {
      if (e is AdminLeaveFailure) rethrow;
      throw const AdminLeaveFailure('Unexpected response format from server.');
    }
  }

  Future<void> updateLeave({
    required String id,
    required String status,
    required String adminName,
    required String adminEmail,
    required String adminRole,
    required String actionAt,
  }) async {
    final leaveId = id.trim();
    if (leaveId.isEmpty) {
      throw const AdminLeaveFailure('Leave ID missing.');
    }

    late final http.Response response;
    try {
      response = await _client
          .put(
            Uri.parse(AdminLeaveEndpoints.updateLeave(leaveId)),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'status': status,
              'adminName': adminName,
              'adminEmail': adminEmail,
              'adminRole': adminRole,
              'actionAt': actionAt,
            }),
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const AdminLeaveFailure(
        'Unable to reach server. Please check your internet connection.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AdminLeaveFailure(_errorMessage(response.body));
    }
  }

  static String _errorMessage(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        final msg = decoded['message'] ?? decoded['error'] ?? decoded['msg'];
        if (msg != null && msg.toString().trim().isNotEmpty) {
          return msg.toString().trim();
        }
      }
    } catch (_) {}
    return 'Failed to update leave request.';
  }
}
