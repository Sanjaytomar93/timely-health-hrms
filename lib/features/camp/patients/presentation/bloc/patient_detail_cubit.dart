import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelay_health/features/camp/camps/data/repositories_impl/camp_repository_impl.dart';
import 'package:timelay_health/features/camp/camps/domain/failures/camp_failure.dart';
import 'package:timelay_health/features/camp/camps/domain/usecases/get_patient_by_id_usecase.dart';
import 'package:timelay_health/features/camp/patients/presentation/bloc/patient_detail_state.dart';

class PatientDetailCubit extends Cubit<PatientDetailState> {
  PatientDetailCubit({GetPatientByIdUseCase? getPatientByIdUseCase})
    : _getPatient =
          getPatientByIdUseCase ?? GetPatientByIdUseCase(CampRepositoryImpl()),
      super(const PatientDetailInitial());

  final GetPatientByIdUseCase _getPatient;

  Future<void> load(String patientId) async {
    emit(const PatientDetailLoading());
    try {
      final patient = await _getPatient(patientId);
      if (isClosed) return;
      emit(PatientDetailLoaded(patient));
    } on CampFailure catch (e) {
      if (isClosed) return;
      emit(PatientDetailFailure(e.message));
    } catch (_) {
      if (isClosed) return;
      emit(const PatientDetailFailure('Failed to load patient details.'));
    }
  }
}
