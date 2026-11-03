import 'package:equatable/equatable.dart';
import 'package:timelay_health/features/camp/camps/domain/entities/camp.dart';

sealed class PatientDetailState extends Equatable {
  const PatientDetailState();

  @override
  List<Object?> get props => [];
}

class PatientDetailInitial extends PatientDetailState {
  const PatientDetailInitial();
}

class PatientDetailLoading extends PatientDetailState {
  const PatientDetailLoading();
}

class PatientDetailLoaded extends PatientDetailState {
  const PatientDetailLoaded(this.patient);

  final CampPatient patient;

  @override
  List<Object?> get props => [patient.id, patient.testCount, patient.name];
}

class PatientDetailFailure extends PatientDetailState {
  const PatientDetailFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
