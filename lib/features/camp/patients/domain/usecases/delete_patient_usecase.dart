import 'package:timelay_health/features/camp/patients/domain/repositories/patient_repository.dart';

class DeletePatientUseCase {
  const DeletePatientUseCase(this._repository);

  final PatientRepository _repository;

  Future<void> call(String patientId) => _repository.deletePatient(patientId);
}
