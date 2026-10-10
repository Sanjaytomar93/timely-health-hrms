import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:timelay_health/features/issues/data/endpoints/issue_endpoints.dart';
import 'package:timelay_health/features/issues/data/mappers/issue_mapper.dart';
import 'package:timelay_health/features/issues/data/models/issue_model.dart';
import 'package:timelay_health/features/issues/domain/entities/issue.dart';
import 'package:timelay_health/features/issues/domain/failures/issue_failure.dart';

class IssueRemoteDataSource {
  IssueRemoteDataSource({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<IssueModel>> getMyIssues({required String employeeId}) async {
    final id = employeeId.trim();
    if (id.isEmpty) {
      throw const IssueFailure('Employee ID missing. Please login again.');
    }

    final response = await _get(IssueEndpoints.myIssues(id));
    final body = _decode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw IssueFailure(_message(body, 'Failed to load issues.'));
    }

    return MyIssuesResponseModel.fromJson(body).data;
  }

  Future<IssueModel> raiseIssue(RaiseIssueParams params) async {
    final id = params.employeeId.trim();
    if (id.isEmpty) {
      throw const IssueFailure('Employee ID missing. Please login again.');
    }
    if (params.issueTitle.trim().isEmpty) {
      throw const IssueFailure('Please enter issue title.');
    }
    if (params.issueDescription.trim().isEmpty) {
      throw const IssueFailure('Please enter issue description.');
    }

    late final http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse(IssueEndpoints.raise(id)),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(IssueMapper.toRequest(params).toJson()),
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const IssueFailure(
        'Unable to reach server. Check your internet connection.',
      );
    }

    final body = _decode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw IssueFailure(_message(body, 'Failed to raise issue.'));
    }

    try {
      final parsed = RaiseIssueResponseModel.fromJson(body);
      if (!parsed.success) {
        throw IssueFailure(
          parsed.message.isNotEmpty ? parsed.message : 'Failed to raise issue.',
        );
      }
      return parsed.data;
    } on IssueFailure {
      rethrow;
    } catch (_) {
      throw const IssueFailure('Unexpected server response. Please try again.');
    }
  }

  Future<IssueModel> updateIssue({
    required String issueId,
    required RaiseIssueParams params,
  }) async {
    final id = issueId.trim();
    if (id.isEmpty) {
      throw const IssueFailure('Issue ID missing.');
    }
    if (params.issueTitle.trim().isEmpty) {
      throw const IssueFailure('Please enter issue title.');
    }
    if (params.issueDescription.trim().isEmpty) {
      throw const IssueFailure('Please enter issue description.');
    }

    late final http.Response response;
    try {
      response = await _client
          .put(
            Uri.parse(IssueEndpoints.update(id)),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(IssueMapper.toRequest(params).toJson()),
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const IssueFailure(
        'Unable to reach server. Check your internet connection.',
      );
    }

    final body = _decode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw IssueFailure(_message(body, 'Failed to update issue.'));
    }

    try {
      final parsed = RaiseIssueResponseModel.fromJson(body);
      if (!parsed.success) {
        throw const IssueFailure('Failed to update issue.');
      }
      return parsed.data;
    } on IssueFailure {
      rethrow;
    } catch (_) {
      throw const IssueFailure('Unexpected server response. Please try again.');
    }
  }

  Future<void> deleteIssue({required String issueId}) async {
    final id = issueId.trim();
    if (id.isEmpty) {
      throw const IssueFailure('Issue ID missing.');
    }

    late final http.Response response;
    try {
      response = await _client
          .delete(
            Uri.parse(IssueEndpoints.delete(id)),
            headers: const {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const IssueFailure(
        'Unable to reach server. Check your internet connection.',
      );
    }

    final body = _decode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw IssueFailure(_message(body, 'Failed to delete issue.'));
    }

    final success = body['success'] as bool? ?? true;
    if (!success) {
      throw IssueFailure(_message(body, 'Failed to delete issue.'));
    }
  }

  Future<http.Response> _get(String url) async {
    try {
      return await _client
          .get(
            Uri.parse(url),
            headers: const {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const IssueFailure(
        'Unable to reach server. Check your internet connection.',
      );
    }
  }

  Map<String, dynamic> _decode(String raw) {
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      throw const IssueFailure('Unexpected server response. Please try again.');
    }
  }

  String _message(Map<String, dynamic> body, String fallback) {
    final message = body['message']?.toString();
    return message?.isNotEmpty == true ? message! : fallback;
  }
}
