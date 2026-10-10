import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:timelay_health/features/visits/data/endpoints/visit_endpoints.dart';
import 'package:timelay_health/features/visits/data/mappers/visit_mapper.dart';
import 'package:timelay_health/features/visits/data/models/visit_model.dart';
import 'package:timelay_health/features/visits/domain/entities/visit.dart';
import 'package:timelay_health/features/visits/domain/failures/visit_failure.dart';

class VisitRemoteDataSource {
  VisitRemoteDataSource({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<VisitModel>> getMyVisits({required String employeeId}) async {
    final id = employeeId.trim();
    if (id.isEmpty) {
      throw const VisitFailure('Employee ID missing. Please login again.');
    }

    late final http.Response response;
    try {
      response = await _client
          .get(
            Uri.parse(VisitEndpoints.myVisits(id)),
            headers: const {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const VisitFailure(
        'Unable to reach server. Check your internet connection.',
      );
    }

    final body = _decode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VisitFailure(_message(body, 'Failed to load visits.'));
    }

    final parsed = MyVisitsResponseModel.fromJson(body);
    if (!parsed.success) {
      throw const VisitFailure('Failed to load visits.');
    }
    return parsed.data;
  }

  Future<VisitModel> addVisit(AddVisitParams params) async {
    if (params.employeeId.trim().isEmpty) {
      throw const VisitFailure('Employee ID missing. Please login again.');
    }
    if (params.centerName.trim().isEmpty) {
      throw const VisitFailure('Please enter center name.');
    }
    if (params.clientName.trim().isEmpty) {
      throw const VisitFailure('Please enter client name.');
    }
    if (params.contact.trim().isEmpty) {
      throw const VisitFailure('Please enter contact number.');
    }
    if (params.address.trim().isEmpty) {
      throw const VisitFailure('Please enter address.');
    }

    late final http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse(VisitEndpoints.add),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(VisitMapper.toRequest(params).toJson()),
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const VisitFailure(
        'Unable to reach server. Check your internet connection.',
      );
    }

    final body = _decode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VisitFailure(_message(body, 'Failed to add visit.'));
    }

    try {
      final parsed = AddVisitResponseModel.fromJson(body);
      if (!parsed.success) {
        throw VisitFailure(
          parsed.message.isNotEmpty ? parsed.message : 'Failed to add visit.',
        );
      }
      return parsed.callData;
    } on VisitFailure {
      rethrow;
    } catch (_) {
      throw const VisitFailure('Unexpected server response. Please try again.');
    }
  }

  Future<VisitModel> updateVisit(UpdateVisitParams params) async {
    final id = params.id.trim();
    if (id.isEmpty) {
      throw const VisitFailure('Visit ID missing.');
    }
    if (params.employeeId.trim().isEmpty) {
      throw const VisitFailure('Employee ID missing. Please login again.');
    }
    if (params.centerName.trim().isEmpty) {
      throw const VisitFailure('Please enter center name.');
    }
    if (params.clientName.trim().isEmpty) {
      throw const VisitFailure('Please enter client name.');
    }
    if (params.contact.trim().isEmpty) {
      throw const VisitFailure('Please enter contact number.');
    }
    if (params.address.trim().isEmpty) {
      throw const VisitFailure('Please enter address.');
    }

    late final http.Response response;
    try {
      response = await _client
          .put(
            Uri.parse(VisitEndpoints.edit(id)),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(VisitMapper.toUpdateRequest(params).toJson()),
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const VisitFailure(
        'Unable to reach server. Check your internet connection.',
      );
    }

    final body = _decode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VisitFailure(_message(body, 'Failed to update visit.'));
    }

    try {
      final parsed = AddVisitResponseModel.fromJson(body);
      if (!parsed.success) {
        throw VisitFailure(
          parsed.message.isNotEmpty
              ? parsed.message
              : 'Failed to update visit.',
        );
      }
      return parsed.callData;
    } on VisitFailure {
      rethrow;
    } catch (_) {
      throw const VisitFailure('Unexpected server response. Please try again.');
    }
  }

  Future<void> deleteVisit({required String id}) async {
    final visitId = id.trim();
    if (visitId.isEmpty) {
      throw const VisitFailure('Visit ID missing.');
    }

    late final http.Response response;
    try {
      response = await _client
          .delete(
            Uri.parse(VisitEndpoints.delete(visitId)),
            headers: const {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const VisitFailure(
        'Unable to reach server. Check your internet connection.',
      );
    }

    final body = _decode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VisitFailure(_message(body, 'Failed to delete visit.'));
    }

    final success = body['success'] as bool? ?? true;
    if (!success) {
      throw VisitFailure(_message(body, 'Failed to delete visit.'));
    }
  }

  Map<String, dynamic> _decode(String raw) {
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      throw const VisitFailure('Unexpected server response. Please try again.');
    }
  }

  String _message(Map<String, dynamic> body, String fallback) {
    final message = body['message']?.toString();
    return message?.isNotEmpty == true ? message! : fallback;
  }
}
