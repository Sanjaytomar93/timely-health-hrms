import 'package:timelay_health/features/camp/camps/domain/entities/camp.dart';
import 'package:timelay_health/features/camp/camps/domain/repositories/camp_repository.dart';

class GetPatientByIdUseCase {
  const GetPatientByIdUseCase(this._repository);

  final CampRepository _repository;

  Future<CampPatient> call(String patientId) =>
      _repository.getPatientById(patientId);
}
