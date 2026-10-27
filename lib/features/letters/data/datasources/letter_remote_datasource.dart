import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:timelay_health/features/letters/data/endpoints/letter_endpoints.dart';
import 'package:timelay_health/features/letters/data/models/letter_model.dart';
import 'package:timelay_health/features/letters/data/models/resignation_model.dart';
import 'package:timelay_health/features/letters/domain/failures/letter_failure.dart';

class LetterRemoteDataSource {
  LetterRemoteDataSource({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<LetterModel>> getEmployeeLetters(String employeeId) async {
    late final http.Response response;
    try {
      response = await _client
          .get(
            Uri.parse(LetterEndpoints.adminLetters(employeeId)),
            headers: const {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const LetterFailure(
        'Unable to reach server. Check your internet connection.',
      );
    }

    if (response.statusCode == 404) return const [];
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const LetterFailure('Failed to load letters.');
    }

    try {
      final decoded = jsonDecode(response.body);
      final raw = decoded is Map<String, dynamic>
          ? decoded['data'] ?? decoded['letters']
          : decoded;
      final resignation = decoded is Map<String, dynamic>
          ? decoded['resignation']
          : null;
      if (raw is List) {
        return [
          ...raw.whereType<Map<String, dynamic>>().map(LetterModel.fromJson),
          if (resignation is Map<String, dynamic>)
            LetterModelResignation.fromResignation(resignation),
        ];
      }
      throw const FormatException('Unexpected letters response');
    } catch (_) {
      throw const LetterFailure(
        'Unexpected server response. Please try again.',
      );
    }
  }

  /// Returns `null` when the employee has not submitted a resignation.
  Future<ResignationModel?> getResignation(String employeeId) async {
    final response = await _client
        .get(
          Uri.parse(LetterEndpoints.adminLetters(employeeId)),
          headers: const {'Content-Type': 'application/json'},
        )
        .timeout(const Duration(seconds: 30));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP ${response.statusCode}');
    }
    final decoded = jsonDecode(response.body);
    final raw = decoded is Map<String, dynamic> ? decoded['resignation'] : null;
    return raw is Map<String, dynamic> ? ResignationModel.fromJson(raw) : null;
  }

  Future<void> submitResignation(Map<String, dynamic> body) async {
    late final http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse(LetterEndpoints.submitResignation),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const LetterFailure(
        'Unable to reach server. Check your internet connection.',
      );
    }

    Map<String, dynamic>? decoded;
    try {
      final value = jsonDecode(response.body);
      if (value is Map<String, dynamic>) decoded = value;
    } catch (_) {}
    final ok = response.statusCode >= 200 && response.statusCode < 300;
    if (!ok || decoded?['success'] == false) {
      throw LetterFailure(
        decoded?['message']?.toString() ?? 'Failed to submit resignation.',
      );
    }
  }

  Future<Uint8List> downloadLetter(String fileUrl) async {
    late final http.Response response;
    try {
      response = await _client
          .get(Uri.parse(fileUrl))
          .timeout(const Duration(seconds: 60));
    } catch (_) {
      throw const LetterFailure(
        'Unable to reach server. Check your internet connection.',
      );
    }

    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        response.bodyBytes.isEmpty) {
      throw const LetterFailure('Letter file is not available.');
    }
    return response.bodyBytes;
  }
}
