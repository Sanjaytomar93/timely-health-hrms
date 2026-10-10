import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:timelay_health/features/auth/data/endpoints/auth_endpoints.dart';
import 'package:timelay_health/features/auth/data/models/employee_model.dart';
import 'package:timelay_health/features/auth/domain/failures/auth_failure.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Future<EmployeeModel> login({
    required String email,
    required String password,
    required double latitude,
    required double longitude,
    required String fcmToken,
  }) async {
    late final http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse(AuthEndpoints.login),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email.trim(),
              'password': password,
              'latitude': latitude,
              'longitude': longitude,
              'fcmToken': fcmToken,
            }),
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const AuthFailure(
        'Unable to reach server. Check your internet connection.',
      );
    }

    final body = _decodeBody(response.body);
    final parsed = LoginResponseModel.fromJson(body);

    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        parsed.success &&
        parsed.employee != null) {
      return parsed.employee!;
    }

    throw AuthFailure(
      parsed.message.isNotEmpty
          ? parsed.message
          : 'Login failed. Please check your credentials.',
    );
  }

  Future<void> logout({
    required String employeeId,
    required String email,
    required String fcmToken,
  }) async {
    final id = employeeId.trim();
    final token = fcmToken.trim();
    if (id.isEmpty && token.isEmpty) return;

    try {
      await _client
          .post(
            Uri.parse(AuthEndpoints.logout),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'employeeId': id,
              if (email.trim().isNotEmpty) 'email': email.trim(),
              'fcmToken': token,
            }),
          )
          .timeout(const Duration(seconds: 15));
    } catch (_) {}
  }

  Future<EmployeeModel> getEmployee({required String employeeId}) async {
    late final http.Response response;
    try {
      response = await _client
          .get(
            Uri.parse(AuthEndpoints.getEmployee(employeeId)),
            headers: const {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const AuthFailure(
        'Unable to reach server. Check your internet connection.',
      );
    }

    final body = _decodeBody(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = body['message']?.toString();
      throw AuthFailure(
        message?.isNotEmpty == true
            ? message!
            : 'Failed to load employee profile.',
      );
    }

    try {
      final parsed = EmployeeDetailResponseModel.fromJson(body);
      if (!parsed.success) {
        throw const AuthFailure('Failed to load employee profile.');
      }
      return parsed.employee;
    } on AuthFailure {
      rethrow;
    } catch (_) {
      throw const AuthFailure('Failed to load employee profile.');
    }
  }

  Map<String, dynamic> _decodeBody(String raw) {
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      throw const AuthFailure('Unexpected server response. Please try again.');
    }
  }
}
