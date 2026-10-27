import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:timelay_health/features/attendance/data/endpoints/attendance_endpoints.dart';
import 'package:timelay_health/features/attendance/data/models/attendance_record_model.dart';
import 'package:timelay_health/features/attendance/data/models/employee_location_model.dart';
import 'package:timelay_health/features/attendance/data/models/employee_shift_model.dart';
import 'package:timelay_health/features/attendance/domain/entities/check_in_params.dart';
import 'package:timelay_health/features/attendance/domain/entities/check_in_result.dart';
import 'package:timelay_health/features/attendance/domain/entities/ot_claim_params.dart';
import 'package:timelay_health/features/attendance/domain/failures/attendance_failure.dart';

class AttendanceRemoteDataSource {
  AttendanceRemoteDataSource({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Future<MyAttendanceResponseModel> getMyAttendance({
    required String employeeId,
  }) async {
    final id = employeeId.trim();
    if (id.isEmpty) {
      throw const AttendanceFailure('Employee ID missing. Please login again.');
    }

    late final http.Response response;
    try {
      response = await _client
          .get(
            Uri.parse(AttendanceEndpoints.myAttendance(id)),
            headers: const {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const AttendanceFailure(
        'Unable to reach server. Check your internet connection.',
      );
    }

    final body = _decodeBody(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = body['message']?.toString();
      throw AttendanceFailure(
        message?.isNotEmpty == true ? message! : 'Failed to load attendance.',
      );
    }

    return MyAttendanceResponseModel.fromJson(body);
  }

  Future<EmployeeShiftModel> getMyShift({required String employeeId}) async {
    final id = employeeId.trim();
    if (id.isEmpty) {
      throw const AttendanceFailure('Employee ID missing. Please login again.');
    }

    late final http.Response response;
    try {
      response = await _client
          .get(
            Uri.parse(AttendanceEndpoints.myShift(id)),
            headers: const {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const AttendanceFailure(
        'Unable to reach server. Check your internet connection.',
      );
    }

    final body = _decodeBody(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = body['message']?.toString();
      throw AttendanceFailure(
        message?.isNotEmpty == true ? message! : 'Failed to load shift.',
      );
    }

    final parsed = MyShiftResponseModel.fromJson(body);
    if (!parsed.success || parsed.data == null) {
      throw const AttendanceFailure('No shift assigned.');
    }
    return parsed.data!;
  }

  Future<EmployeeLocationAssignmentModel> getMyLocation({
    required String employeeId,
  }) async {
    final id = employeeId.trim();
    if (id.isEmpty) {
      throw const AttendanceFailure('Employee ID missing. Please login again.');
    }

    late final http.Response response;
    try {
      response = await _client
          .get(
            Uri.parse(AttendanceEndpoints.myLocation(id)),
            headers: const {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const AttendanceFailure(
        'Unable to reach server. Check your internet connection.',
      );
    }

    final body = _decodeBody(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = body['message']?.toString();
      throw AttendanceFailure(
        message?.isNotEmpty == true ? message! : 'Failed to load location.',
      );
    }

    final parsed = MyLocationResponseModel.fromJson(body);
    if (!parsed.success || parsed.location == null) {
      throw const AttendanceFailure('No location assigned.');
    }
    return parsed.location!;
  }

  Future<List<EmployeeLocationAssignmentModel>> getAllLocations() async {
    late final http.Response response;
    try {
      response = await _client
          .get(
            Uri.parse(AttendanceEndpoints.allLocations),
            headers: const {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const AttendanceFailure(
        'Unable to reach server. Check your internet connection.',
      );
    }

    final body = _decodeBody(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AttendanceFailure(_message(body, 'Failed to load locations.'));
    }

    return AllLocationsResponseModel.fromJson(body).locations;
  }

  Future<CheckInResult> checkIn(CheckInParams params) async {
    final id = params.employeeId.trim();
    final email = params.employeeEmail.trim();
    if (id.isEmpty) {
      throw const AttendanceFailure('Employee ID missing. Please login again.');
    }
    if (email.isEmpty) {
      throw const AttendanceFailure(
        'Employee email missing. Please login again.',
      );
    }

    late final http.Response response;
    try {
      if (params.hasImage) {
        response = await _postMultipart(
          url: AttendanceEndpoints.checkIn,
          fields: {
            'employeeId': id,
            'employeeEmail': email,
            'latitude': params.latitude.toString(),
            'longitude': params.longitude.toString(),
            if (params.reason != null && params.reason!.trim().isNotEmpty)
              'reason': params.reason!.trim(),
          },
          imagePath: params.imagePath!.trim(),
        );
      } else {
        response = await _client
            .post(
              Uri.parse(AttendanceEndpoints.checkIn),
              headers: const {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              body: jsonEncode({
                'employeeId': id,
                'employeeEmail': email,
                'latitude': params.latitude,
                'longitude': params.longitude,
                if (params.reason != null && params.reason!.trim().isNotEmpty)
                  'reason': params.reason!.trim(),
              }),
            )
            .timeout(const Duration(seconds: 30));
      }
    } on AttendanceFailure {
      rethrow;
    } catch (e) {
      throw AttendanceFailure('Check-in network error: $e');
    }

    final body = _decodeBody(response.body);
    _ensureOk(response, body, fallback: 'Check-in failed.');

    final attendance = body['attendance'];
    final attendanceMap = attendance is Map
        ? Map<String, dynamic>.from(attendance)
        : const <String, dynamic>{};

    return CheckInResult(
      message: body['message']?.toString() ?? 'Check-in successful',
      employeeName:
          body['employeeName']?.toString() ??
          attendanceMap['name']?.toString() ??
          '',
      checkInTime: DateTime.tryParse(
        attendanceMap['checkInTime']?.toString() ?? '',
      ),
      distanceMeters: (attendanceMap['distance'] as num?)?.round(),
      onsite: attendanceMap['onsite'] as bool? ?? true,
      officeName: attendanceMap['officeName']?.toString(),
      reason: attendanceMap['reason']?.toString(),
    );
  }

  Future<CheckOutResult> checkOut(CheckOutParams params) async {
    final id = params.employeeId.trim();
    final email = params.employeeEmail.trim();
    if (id.isEmpty) {
      throw const AttendanceFailure('Employee ID missing. Please login again.');
    }

    late final http.Response response;
    try {
      if (params.hasImage) {
        response = await _postMultipart(
          url: AttendanceEndpoints.checkOut,
          fields: {
            'employeeId': id,
            if (email.isNotEmpty) 'employeeEmail': email,
            'latitude': params.latitude.toString(),
            'longitude': params.longitude.toString(),
            if (params.reason != null && params.reason!.trim().isNotEmpty)
              'reason': params.reason!.trim(),
          },
          imagePath: params.imagePath!.trim(),
        );
      } else {
        response = await _client
            .post(
              Uri.parse(AttendanceEndpoints.checkOut),
              headers: const {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              body: jsonEncode({
                'employeeId': id,
                if (email.isNotEmpty) 'employeeEmail': email,
                'latitude': params.latitude,
                'longitude': params.longitude,
                if (params.reason != null && params.reason!.trim().isNotEmpty)
                  'reason': params.reason!.trim(),
              }),
            )
            .timeout(const Duration(seconds: 30));
      }
    } on AttendanceFailure {
      rethrow;
    } catch (e) {
      throw AttendanceFailure('Check-out network error: $e');
    }

    final body = _decodeBody(response.body);
    _ensureOk(response, body, fallback: 'Check-out failed.');

    final attendance = body['attendance'];
    final attendanceMap = attendance is Map
        ? Map<String, dynamic>.from(attendance)
        : const <String, dynamic>{};
    final summary = body['summary'];
    final summaryMap = summary is Map
        ? Map<String, dynamic>.from(summary)
        : const <String, dynamic>{};

    return CheckOutResult(
      message: body['message']?.toString() ?? 'Check-out successful',
      employeeName:
          body['employeeName']?.toString() ??
          attendanceMap['name']?.toString() ??
          '',
      checkOutTime: DateTime.tryParse(
        attendanceMap['checkOutTime']?.toString() ?? '',
      ),
      totalHours:
          summaryMap['totalHours']?.toString() ??
          attendanceMap['totalHours']?.toString(),
    );
  }

  Future<String> claimOt(OtClaimParams params) async {
    final id = params.employeeId.trim();
    if (id.isEmpty) {
      throw const AttendanceFailure('Employee ID missing. Please login again.');
    }
    if (params.items.isEmpty) {
      throw const AttendanceFailure('Select at least one record to claim.');
    }

    final reason = params.reason.trim();
    final payload = {
      'claims': [
        for (final item in params.items)
          {
            'employeeId': id,
            'employeeName': params.employeeName.trim(),
            'attendanceId': item.attendanceId,
            'date': item.date?.toUtc().toIso8601String(),
            'otHours': item.otHours,
            'reason': reason,
          },
      ],
      'totalOTHours': double.parse(params.totalOtHours.toStringAsFixed(2)),
    };

    late final http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse(AttendanceEndpoints.claimOt),
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const AttendanceFailure(
        'Unable to reach server. Check your internet connection.',
      );
    }

    final body = _decodeBody(response.body);
    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        body['success'] == false) {
      throw AttendanceFailure(_message(body, 'Failed to claim OT.'));
    }
    return _message(body, 'OT claimed successfully.');
  }

  Future<http.Response> _postMultipart({
    required String url,
    required Map<String, String> fields,
    required String imagePath,
  }) async {
    final file = File(imagePath);
    if (!await file.exists()) {
      throw const AttendanceFailure(
        'Captured photo not found. Please retake photo.',
      );
    }

    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw const AttendanceFailure(
        'Captured photo is empty. Please retake photo.',
      );
    }

    final media = _detectImageMedia(bytes);
    final filename =
        'attendance-${DateTime.now().millisecondsSinceEpoch}.${media.extension}';

    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers['Accept'] = 'application/json';
    request.fields.addAll(fields);
    request.files.add(
      http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: filename,
        contentType: media.type,
      ),
    );

    debugPrint(
      '[multipart] $url file=$filename '
      'mime=${media.type.mimeType} bytes=${bytes.length}',
    );

    final streamed = await _client
        .send(request)
        .timeout(const Duration(seconds: 90));
    return http.Response.fromStream(streamed);
  }

  ({MediaType type, String extension}) _detectImageMedia(List<int> bytes) {
    if (bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF) {
      return (type: MediaType('image', 'jpeg'), extension: 'jpg');
    }
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return (type: MediaType('image', 'png'), extension: 'png');
    }
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return (type: MediaType('image', 'webp'), extension: 'webp');
    }
    return (type: MediaType('image', 'jpeg'), extension: 'jpg');
  }

  void _ensureOk(
    http.Response response,
    Map<String, dynamic> body, {
    required String fallback,
  }) {
    final code = response.statusCode;
    if (code < 200 || code >= 300) {
      throw AttendanceFailure(_message(body, fallback));
    }
    if (body['success'] == false) {
      throw AttendanceFailure(_message(body, fallback));
    }
    final message = body['message']?.toString().toLowerCase() ?? '';
    final hasAttendance = body['attendance'] is Map;
    final looksSuccessful = message.contains('success') || hasAttendance;
    if (!looksSuccessful && body.containsKey('success') == false) {
      if (message.contains('fail') ||
          message.contains('error') ||
          message.contains('already')) {
        throw AttendanceFailure(_message(body, fallback));
      }
    }
  }

  Map<String, dynamic> _decodeBody(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      return const {};
    } catch (_) {
      throw const AttendanceFailure(
        'Unexpected server response. Please try again.',
      );
    }
  }

  String _message(Map<String, dynamic> body, String fallback) {
    final error = body['error']?.toString().trim();
    if (error != null && error.isNotEmpty) return error;
    final msg = body['message']?.toString().trim();
    if (msg != null && msg.isNotEmpty) return msg;
    return fallback;
  }
}
