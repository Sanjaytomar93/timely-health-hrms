import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:timelay_health/features/camp/camps/data/models/camp_model.dart';
import 'package:timelay_health/features/camp/patients/data/endpoints/patient_endpoints.dart';
import 'package:timelay_health/features/camp/patients/domain/failures/patient_failure.dart';
import 'package:timelay_health/features/camp/patients/domain/entities/add_patient_test_params.dart';
import 'package:timelay_health/features/camp/patients/domain/entities/create_patient_params.dart';
import 'package:timelay_health/features/camp/patients/domain/entities/update_patient_vitals_params.dart';

class PatientRemoteDataSource {
  PatientRemoteDataSource({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Future<void> deletePatient(String patientId) async {
    final id = patientId.trim();
    if (id.isEmpty) {
      throw const PatientFailure('Patient id missing.');
    }

    late final http.Response response;
    try {
      response = await _client
          .delete(
            Uri.parse(PatientEndpoints.patientById(id)),
            headers: const {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const PatientFailure(
        'Unable to reach server. Check your internet connection.',
      );
    }

    final body = _decode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw PatientFailure(_message(body, 'Failed to delete patient.'));
    }
    if (body['success'] == false) {
      throw PatientFailure(_message(body, 'Failed to delete patient.'));
    }
  }

  Future<void> updatePatientVitals(UpdatePatientVitalsParams params) async {
    final patientId = params.patientId.trim();
    if (patientId.isEmpty) {
      throw const PatientFailure('Patient id missing.');
    }

    late final http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse(PatientEndpoints.patientTests(patientId)),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'vitals': {
                'weight': params.weight,
                'height': params.height,
                'sugar': params.sugar,
                'systolic': params.systolic,
                'diastolic': params.diastolic,
                'sugarType': params.sugarType,
              },
            }),
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const PatientFailure(
        'Unable to reach server. Check your internet connection.',
      );
    }

    final body = _decode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw PatientFailure(_message(body, 'Failed to update vitals.'));
    }
    if (body['success'] == false) {
      throw PatientFailure(_message(body, 'Failed to update vitals.'));
    }
  }

  Future<void> addPatientTest(AddPatientTestParams params) async {
    final patientId = params.patientId.trim();
    if (patientId.isEmpty) {
      throw const PatientFailure('Patient id missing.');
    }

    late final http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse(PatientEndpoints.patientTests(patientId)),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'type': params.type,
              'value': params.value,
              'unit': params.unit,
              'bmi': params.bmi,
              'campType': params.campType,
              'campDate': params.campDate.toUtc().toIso8601String(),
              'campId': params.campId,
              'campLocation': params.campLocation,
              'campName': params.campName,
              'date': params.date.toUtc().toIso8601String(),
              'doctorVerification': {
                'status': params.doctorVerificationStatus,
              },
            }),
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const PatientFailure(
        'Unable to reach server. Check your internet connection.',
      );
    }

    final body = _decode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw PatientFailure(_message(body, 'Failed to save medical test.'));
    }
  }

  Future<CampPatientModel> createPatient(CreatePatientParams params) async {
    final campId = params.campId.trim();
    final name = params.name.trim();
    if (campId.isEmpty) {
      throw const PatientFailure('Please select a camp.');
    }
    if (name.isEmpty) {
      throw const PatientFailure('Patient name is required.');
    }

    late final http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse(PatientEndpoints.patients),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'salutation': params.salutation.trim(),
              'name': name,
              'age': params.age.trim(),
              'gender': params.gender.trim().toLowerCase(),
              'contact': params.contact.trim(),
              'address': params.address.trim(),
              'campId': campId,
            }),
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const PatientFailure(
        'Unable to reach server. Check your internet connection.',
      );
    }

    final body = _decode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw PatientFailure(_message(body, 'Failed to create patient.'));
    }

    try {
      final raw = body['data'] is Map<String, dynamic>
          ? body['data'] as Map<String, dynamic>
          : body;
      if (raw.isEmpty || (raw['_id'] == null && raw['id'] == null)) {
        throw const FormatException('Unexpected create patient response');
      }
      return CampPatientModel.fromJson(raw);
    } on PatientFailure {
      rethrow;
    } catch (_) {
      throw const PatientFailure(
        'Unexpected server response. Please try again.',
      );
    }
  }

  Future<List<CampPatientModel>> getAssignedPatients(String employeeName) async {
    final name = employeeName.trim();
    if (name.isEmpty) {
      throw const PatientFailure('Employee name missing. Please login again.');
    }

    late final http.Response response;
    try {
      response = await _client
          .get(
            Uri.parse(PatientEndpoints.assignedPatients(name)),
            headers: const {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const PatientFailure(
        'Unable to reach server. Check your internet connection.',
      );
    }

    final body = _decode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw PatientFailure(_message(body, 'Failed to load patients.'));
    }

    try {
      if (body['success'] == false) {
        throw PatientFailure(_message(body, 'Failed to load patients.'));
      }
      final raw = body['data'];
      if (raw is! List) return const [];
      return raw
          .whereType<Map<String, dynamic>>()
          .map(CampPatientModel.fromJson)
          .where((p) => p.id.isNotEmpty || p.name.trim().isNotEmpty)
          .toList(growable: false);
    } on PatientFailure {
      rethrow;
    } catch (_) {
      throw const PatientFailure(
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
