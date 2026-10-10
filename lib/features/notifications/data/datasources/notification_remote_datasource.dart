import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:timelay_health/features/notifications/data/endpoints/notification_endpoints.dart';
import 'package:timelay_health/features/notifications/data/models/notification_model.dart';
import 'package:timelay_health/features/notifications/domain/failures/notification_failure.dart';

class NotificationRemoteDataSource {
  NotificationRemoteDataSource({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<NotificationModel>> getNotifications({
    required String employeeId,
  }) async {
    final id = employeeId.trim();
    if (id.isEmpty) {
      throw const NotificationFailure(
        'Employee ID missing. Please login again.',
      );
    }

    late final http.Response response;
    try {
      response = await _client
          .get(
            Uri.parse(NotificationEndpoints.list(id)),
            headers: const {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const NotificationFailure(
        'Unable to reach server. Check your internet connection.',
      );
    }

    final decoded = _decodeBody(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw NotificationFailure(
        _message(decoded, 'Failed to load notifications.'),
      );
    }

    final list = _asList(decoded);
    return list
        .whereType<Map>()
        .map((e) => NotificationModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> markAllRead({required String employeeId}) async {
    final id = employeeId.trim();
    if (id.isEmpty) {
      throw const NotificationFailure(
        'Employee ID missing. Please login again.',
      );
    }

    late final http.Response response;
    try {
      response = await _client
          .put(
            Uri.parse(NotificationEndpoints.readAll(id)),
            headers: const {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const NotificationFailure(
        'Unable to reach server. Check your internet connection.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final decoded = _decodeBody(response.body);
      throw NotificationFailure(
        _message(decoded, 'Failed to mark notifications as read.'),
      );
    }
  }

  Future<void> markRead({required String notificationId}) async {
    final id = notificationId.trim();
    if (id.isEmpty) {
      throw const NotificationFailure('Notification ID missing.');
    }

    late final http.Response response;
    try {
      response = await _client
          .put(
            Uri.parse(NotificationEndpoints.readOne(id)),
            headers: const {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const NotificationFailure(
        'Unable to reach server. Check your internet connection.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final decoded = _decodeBody(response.body);
      throw NotificationFailure(
        _message(decoded, 'Failed to mark notification as read.'),
      );
    }
  }

  Future<int> deleteNotifications({
    required List<String> notificationIds,
  }) async {
    final ids = notificationIds
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (ids.isEmpty) {
      throw const NotificationFailure('Select a notification to delete.');
    }

    late final http.Response response;
    try {
      response = await _client
          .delete(
            Uri.parse(NotificationEndpoints.delete),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({'notificationIds': ids}),
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const NotificationFailure(
        'Unable to reach server. Check your internet connection.',
      );
    }

    final decoded = _decodeBody(response.body);
    final map = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw NotificationFailure(
        _message(map, 'Failed to delete notifications.'),
      );
    }
    if (map['success'] == false) {
      throw NotificationFailure(
        _message(map, 'Failed to delete notifications.'),
      );
    }
    final count = map['deletedCount'];
    if (count is num) return count.toInt();
    return ids.length;
  }

  dynamic _decodeBody(String body) {
    if (body.trim().isEmpty) return null;
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  List<dynamic> _asList(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is Map) {
      final map = Map<String, dynamic>.from(decoded);
      final raw = map['data'] ?? map['notifications'] ?? map['records'];
      if (raw is List) return raw;
    }
    return const [];
  }

  String _message(dynamic body, String fallback) {
    if (body is Map) {
      final map = Map<String, dynamic>.from(body);
      final msg = map['message'] ?? map['error'] ?? map['msg'];
      if (msg != null && msg.toString().trim().isNotEmpty) {
        return msg.toString().trim();
      }
    }
    return fallback;
  }
}
