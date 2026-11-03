import 'package:equatable/equatable.dart';
import 'package:timelay_health/features/camp/patients/presentation/models/patient_list_ui.dart';

sealed class PatientsState extends Equatable {
  const PatientsState({
    this.data = PatientListUi.empty,
    this.patients = const [],
    this.search = '',
    this.filter = 'All',
    this.hasMore = false,
    this.filteredCount = 0,
  });

  final PatientListUi data;
  final List<PatientUi> patients;
  final String search;
  final String filter;
  final bool hasMore;
  final int filteredCount;

  @override
  List<Object?> get props =>
      [data, patients, search, filter, hasMore, filteredCount];
}

class PatientsInitial extends PatientsState {
  const PatientsInitial();
}

class PatientsLoading extends PatientsState {
  const PatientsLoading({
    super.data,
    super.patients,
    super.search,
    super.filter,
    super.hasMore,
    super.filteredCount,
  });
}

class PatientsLoaded extends PatientsState {
  const PatientsLoaded({
    required super.data,
    required super.patients,
    super.search,
    super.filter,
    super.hasMore,
    super.filteredCount,
  });
}

class PatientsFailureState extends PatientsState {
  const PatientsFailureState(
    this.message, {
    super.data,
    super.patients,
    super.search,
    super.filter,
    super.hasMore,
    super.filteredCount,
  });

  final String message;

  @override
  List<Object?> get props => [message, ...super.props];
}
