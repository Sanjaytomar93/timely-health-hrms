import 'package:timelay_health/features/camp/camps/domain/entities/camp.dart';
import 'package:timelay_health/features/camp/patients/domain/entities/create_patient_params.dart';
import 'package:timelay_health/features/camp/patients/domain/repositories/patient_repository.dart';

export 'package:timelay_health/features/camp/patients/domain/entities/create_patient_params.dart';

class CreatePatientUseCase {
  const CreatePatientUseCase(this._repository);

  final PatientRepository _repository;

  Future<CampPatient> call(CreatePatientParams params) =>
      _repository.createPatient(params);
}
