import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:timelay_health/features/events/data/endpoints/event_endpoints.dart';
import 'package:timelay_health/features/events/data/models/celebration_event_model.dart';
import 'package:timelay_health/features/events/data/models/my_event.dart';

class EventFailure implements Exception {
  const EventFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

class EventRemoteDataSource {
  EventRemoteDataSource({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  static const _headers = {'Content-Type': 'application/json'};
  static const _timeout = Duration(seconds: 30);

  Future<List<MyEvent>> getMyEvents(String userId) async {
    final body = await _send(
      () => _client.get(
        Uri.parse(EventEndpoints.myEvents(userId)),
        headers: _headers,
      ),
      'Failed to load events.',
    );
    final raw = body['events'] ?? body['data'];
    if (raw is! List) return const [];
    return raw.whereType<Map<String, dynamic>>().map(MyEvent.fromJson).toList();
  }

  /// Company birthdays & anniversaries.
  /// [month] format: `YYYY-MM` (e.g. `2026-11`). Omit for all months.
  Future<CompanyEventsResult> getCompanyEventsByEmployee({String? month}) async {
    final body = await _send(
      () => _client.get(
        Uri.parse(EventEndpoints.companyByEmployee(month: month)),
        headers: _headers,
      ),
      'Failed to load company events.',
    );
    final raw = body['events'];
    final events = raw is List
        ? raw
            .whereType<Map<String, dynamic>>()
            .map(CelebrationEvent.fromJson)
            .toList()
        : const <CelebrationEvent>[];
    final statsRaw = body['stats'];
    return CompanyEventsResult(
      stats: statsRaw is Map<String, dynamic>
          ? CompanyEventStats.fromJson(statsRaw)
          : CompanyEventStats.empty,
      events: events,
      totalFiltered: int.tryParse('${body['totalFiltered'] ?? events.length}') ??
          events.length,
    );
  }

  Future<void> createEvent({
    required String userId,
    required String userRole,
    required EventInput input,
  }) async {
    await _send(
      () => _client.post(
        Uri.parse(EventEndpoints.create),
        headers: _headers,
        body: jsonEncode(input.toJson(userId: userId, userRole: userRole)),
      ),
      'Failed to add event.',
    );
  }

  Future<void> updateEvent({
    required String eventId,
    required String userId,
    required String userRole,
    required EventInput input,
  }) async {
    await _send(
      () => _client.put(
        Uri.parse(EventEndpoints.byId(eventId)),
        headers: _headers,
        body: jsonEncode(input.toJson(userId: userId, userRole: userRole)),
      ),
      'Failed to update event.',
    );
  }

  Future<void> deleteEvent(String eventId) async {
    await _send(
      () => _client.delete(
        Uri.parse(EventEndpoints.byId(eventId)),
        headers: _headers,
      ),
      'Failed to delete event.',
    );
  }

  Future<Map<String, dynamic>> _send(
    Future<http.Response> Function() request,
    String fallback,
  ) async {
    late final http.Response response;
    try {
      response = await request().timeout(_timeout);
    } catch (_) {
      throw const EventFailure(
        'Unable to reach server. Check your internet connection.',
      );
    }

    Map<String, dynamic> body;
    try {
      final decoded = jsonDecode(response.body);
      body = decoded is Map<String, dynamic> ? decoded : const {};
    } catch (_) {
      body = const {};
    }

    final ok = response.statusCode >= 200 && response.statusCode < 300;
    if (!ok || body['success'] == false) {
      final message = body['message']?.toString() ?? '';
      final detail = body['error']?.toString() ?? '';
      throw EventFailure(
        [
          message.isNotEmpty ? message : fallback,
          if (detail.isNotEmpty) detail,
        ].join('\n'),
      );
    }
    return body;
  }
}
