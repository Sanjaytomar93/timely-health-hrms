import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:timelay_health/features/permissions/data/endpoints/permission_endpoints.dart';

class PermissionRequestException implements Exception {
  const PermissionRequestException(this.message);

  final String message;
}

class PermissionRecordModel {
  const PermissionRecordModel({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.reason,
    required this.duration,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String employeeId;
  final String employeeName;
  final String reason;
  final int duration;
  final String status;
  final DateTime? createdAt;

  factory PermissionRecordModel.fromJson(Map<String, dynamic> json) {
    final rawDuration = json['duration'];
    return PermissionRecordModel(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      employeeId: json['employeeId']?.toString() ?? '',
      employeeName: json['employeeName']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
      duration: rawDuration is num
          ? rawDuration.toInt()
          : int.tryParse(rawDuration?.toString() ?? '') ?? 0,
      status: json['status']?.toString() ?? 'PENDING',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}

class PermissionRemoteDataSource {
  PermissionRemoteDataSource({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Future<PermissionRecordModel> requestPermission({
    required String employeeId,
    required String employeeName,
    required String reason,
    required int duration,
  }) async {
    late final http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse(PermissionEndpoints.request),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'employeeId': employeeId.trim(),
              'employeeName': employeeName.trim(),
              'reason': reason.trim(),
              'duration': duration,
            }),
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const PermissionRequestException(
        'Unable to reach server. Check your internet connection.',
      );
    }

    final body = _decode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw PermissionRequestException(
        body['message']?.toString().trim().isNotEmpty == true
            ? body['message'].toString()
            : 'Failed to send permission request.',
      );
    }

    final data = body['data'];
    if (data is! Map<String, dynamic>) {
      throw const PermissionRequestException(
        'Unexpected server response. Please try again.',
      );
    }
    return PermissionRecordModel.fromJson(data);
  }

  Future<List<PermissionRecordModel>> getMyPermissions({
    required String employeeId,
  }) async {
    final id = employeeId.trim();
    if (id.isEmpty) {
      throw const PermissionRequestException(
        'Employee ID missing. Please login again.',
      );
    }

    late final http.Response response;
    try {
      response = await _client
          .get(
            Uri.parse(PermissionEndpoints.myPermissions(id)),
            headers: const {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const PermissionRequestException(
        'Unable to reach server. Check your internet connection.',
      );
    }

    final body = _decodeJson(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw PermissionRequestException(
        _message(body, 'Failed to load permissions.'),
      );
    }

    final records = body is List<dynamic>
        ? body
        : body is Map<String, dynamic>
        ? body['data'] is List<dynamic>
              ? body['data'] as List<dynamic>
              : null
        : null;
    if (records == null) {
      throw const PermissionRequestException(
        'Unexpected server response. Please try again.',
      );
    }
    return records
        .whereType<Map<String, dynamic>>()
        .map(PermissionRecordModel.fromJson)
        .toList();
  }

  Map<String, dynamic> _decode(String raw) {
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      throw const PermissionRequestException(
        'Unexpected server response. Please try again.',
      );
    }
  }

  dynamic _decodeJson(String raw) {
    try {
      return jsonDecode(raw);
    } catch (_) {
      throw const PermissionRequestException(
        'Unexpected server response. Please try again.',
      );
    }
  }

  String _message(dynamic body, String fallback) {
    if (body is! Map<String, dynamic>) return fallback;
    final message = body['message']?.toString().trim();
    return message?.isNotEmpty == true ? message! : fallback;
  }
}
