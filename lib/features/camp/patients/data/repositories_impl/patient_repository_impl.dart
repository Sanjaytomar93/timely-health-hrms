import 'package:timelay_health/features/camp/camps/domain/entities/camp.dart';
import 'package:timelay_health/features/camp/patients/data/datasources/patient_remote_datasource.dart';
import 'package:timelay_health/features/camp/patients/data/mappers/patient_mapper.dart';
import 'package:timelay_health/features/camp/patients/domain/entities/add_patient_test_params.dart';
import 'package:timelay_health/features/camp/patients/domain/entities/create_patient_params.dart';
import 'package:timelay_health/features/camp/patients/domain/entities/update_patient_vitals_params.dart';
import 'package:timelay_health/features/camp/patients/domain/repositories/patient_repository.dart';

class PatientRepositoryImpl implements PatientRepository {
  PatientRepositoryImpl({PatientRemoteDataSource? remoteDataSource})
    : _remote = remoteDataSource ?? PatientRemoteDataSource();

  final PatientRemoteDataSource _remote;

  @override
  Future<List<CampPatient>> getAssignedPatients(String employeeName) async {
    final models = await _remote.getAssignedPatients(employeeName);
    return models.map(PatientMapper.toEntity).toList(growable: false);
  }

  @override
  Future<CampPatient> createPatient(CreatePatientParams params) async {
    final model = await _remote.createPatient(params);
    return PatientMapper.toEntity(model);
  }

  @override
  Future<void> addPatientTest(AddPatientTestParams params) async {
    await _remote.addPatientTest(params);
  }

  @override
  Future<void> updatePatientVitals(UpdatePatientVitalsParams params) async {
    await _remote.updatePatientVitals(params);
  }

  @override
  Future<void> deletePatient(String patientId) async {
    await _remote.deletePatient(patientId);
  }
}
