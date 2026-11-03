import 'package:timelay_health/features/camp/camps/domain/entities/camp.dart';
import 'package:timelay_health/features/camp/patients/domain/repositories/patient_repository.dart';

class GetAssignedPatientsUseCase {
  const GetAssignedPatientsUseCase(this._repository);

  final PatientRepository _repository;

  Future<List<CampPatient>> call(String employeeName) =>
      _repository.getAssignedPatients(employeeName);
}
