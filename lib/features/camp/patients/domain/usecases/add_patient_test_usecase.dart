import 'package:timelay_health/features/camp/patients/domain/entities/add_patient_test_params.dart';
import 'package:timelay_health/features/camp/patients/domain/repositories/patient_repository.dart';

export 'package:timelay_health/features/camp/patients/domain/entities/add_patient_test_params.dart';

class AddPatientTestUseCase {
  const AddPatientTestUseCase(this._repository);

  final PatientRepository _repository;

  Future<void> call(AddPatientTestParams params) =>
      _repository.addPatientTest(params);
}
