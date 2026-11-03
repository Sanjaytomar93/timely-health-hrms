import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:timelay_health/features/camp/camps/data/endpoints/camp_endpoints.dart';
import 'package:timelay_health/features/camp/camps/data/models/camp_model.dart';
import 'package:timelay_health/features/camp/camps/domain/failures/camp_failure.dart';

class CampRemoteDataSource {
  CampRemoteDataSource({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Future<CampPatientModel> getPatientById(String patientId) async {
    final id = patientId.trim();
    if (id.isEmpty) {
      throw const CampFailure('Patient id missing.');
    }

    late final http.Response response;
    try {
      response = await _client
          .get(
            Uri.parse(CampEndpoints.patientById(id)),
            headers: const {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const CampFailure(
        'Unable to reach server. Check your internet connection.',
      );
    }

    final body = _decode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw CampFailure(_message(body, 'Failed to load patient.'));
    }

    try {
      final raw = body['data'] is Map<String, dynamic>
          ? body['data'] as Map<String, dynamic>
          : body;
      if (raw.isEmpty || (raw['_id'] == null && raw['id'] == null)) {
        throw const FormatException('Unexpected patient response');
      }
      return CampPatientModel.fromJson(raw);
    } on CampFailure {
      rethrow;
    } catch (_) {
      throw const CampFailure(
        'Unexpected server response. Please try again.',
      );
    }
  }

  Future<List<CampModel>> getAssignedCamps(String employeeName) async {
    final name = employeeName.trim();
    if (name.isEmpty) {
      throw const CampFailure('Employee name missing. Please login again.');
    }

    late final http.Response response;
    try {
      response = await _client
          .get(
            Uri.parse(CampEndpoints.assignedCamps(name)),
            headers: const {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const CampFailure(
        'Unable to reach server. Check your internet connection.',
      );
    }

    final body = _decode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw CampFailure(_message(body, 'Failed to load camps.'));
    }

    try {
      if (body['success'] == false) {
        throw CampFailure(_message(body, 'Failed to load camps.'));
      }
      final raw = body['data'];
      if (raw is! List) return const [];
      return raw
          .whereType<Map<String, dynamic>>()
          .map(CampModel.fromJson)
          .toList();
    } on CampFailure {
      rethrow;
    } catch (_) {
      throw const CampFailure(
        'Unexpected server response. Please try again.',
      );
    }
  }

  Map<String, dynamic> _decode(String raw) {
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : const {};
    } catch (_) {
      return const {};
    }
  }

  String _message(Map<String, dynamic> body, String fallback) {
    final message = body['message']?.toString().trim() ?? '';
    return message.isNotEmpty ? message : fallback;
  }
}
