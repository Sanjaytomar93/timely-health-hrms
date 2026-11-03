import 'package:timelay_health/features/camp/camps/domain/entities/camp.dart';
import 'package:timelay_health/features/camp/patients/domain/entities/add_patient_test_params.dart';
import 'package:timelay_health/features/camp/patients/domain/entities/create_patient_params.dart';
import 'package:timelay_health/features/camp/patients/domain/entities/update_patient_vitals_params.dart';

abstract class PatientRepository {
  Future<List<CampPatient>> getAssignedPatients(String employeeName);

  Future<CampPatient> createPatient(CreatePatientParams params);

  Future<void> addPatientTest(AddPatientTestParams params);

  Future<void> updatePatientVitals(UpdatePatientVitalsParams params);

  Future<void> deletePatient(String patientId);
}
