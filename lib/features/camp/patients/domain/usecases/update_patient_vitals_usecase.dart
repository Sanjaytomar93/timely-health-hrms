import 'package:timelay_health/features/camp/patients/domain/entities/update_patient_vitals_params.dart';
import 'package:timelay_health/features/camp/patients/domain/repositories/patient_repository.dart';

export 'package:timelay_health/features/camp/patients/domain/entities/update_patient_vitals_params.dart';

class UpdatePatientVitalsUseCase {
  const UpdatePatientVitalsUseCase(this._repository);

  final PatientRepository _repository;

  Future<void> call(UpdatePatientVitalsParams params) =>
      _repository.updatePatientVitals(params);
}
