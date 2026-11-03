import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelay_health/features/auth/data/auth_session.dart';
import 'package:timelay_health/features/camp/patients/data/repositories_impl/patient_repository_impl.dart';
import 'package:timelay_health/features/camp/patients/domain/failures/patient_failure.dart';
import 'package:timelay_health/features/camp/patients/domain/usecases/get_assigned_patients_usecase.dart';
import 'package:timelay_health/features/camp/patients/presentation/bloc/patients_state.dart';
import 'package:timelay_health/features/camp/patients/presentation/models/patient_list_ui.dart';
import 'package:timelay_health/features/camp/shared/camp_memory_cache.dart';

class PatientsCubit extends Cubit<PatientsState> {
  PatientsCubit({GetAssignedPatientsUseCase? getAssignedPatientsUseCase})
    : _getAssigned =
          getAssignedPatientsUseCase ??
          GetAssignedPatientsUseCase(PatientRepositoryImpl()),
      super(const PatientsInitial());

  static const pageSize = 40;

  final GetAssignedPatientsUseCase _getAssigned;

  PatientListUi _data = PatientListUi.empty;
  List<PatientUi> _filtered = const [];
  int _visibleCount = pageSize;
  String _search = '';
  String _filter = 'All';
  Timer? _searchDebounce;

  Future<void> load({bool keepExisting = false}) async {
    final employee =
        AuthSession.currentEmployee ?? await AuthSession.load();
    final employeeName = employee?.displayName.trim() ?? '';

    if (isClosed) return;

    if (employeeName.isEmpty) {
      emit(
        PatientsFailureState(
          'Employee name missing. Please login again.',
          data: keepExisting ? _data : PatientListUi.empty,
          patients: keepExisting ? state.patients : const [],
          search: _search,
          filter: _filter,
          hasMore: false,
          filteredCount: 0,
        ),
      );
      return;
    }

    final cached = CampMemoryCache.patients(employeeName);
    final hasCache = cached != null && cached.patients.isNotEmpty;
    if (cached != null && hasCache) {
      _data = cached;
      _emitFiltered(resetPage: true);
    } else {
      emit(
        PatientsLoading(
          data: keepExisting ? _data : PatientListUi.empty,
          patients: keepExisting ? state.patients : const [],
          search: _search,
          filter: _filter,
          hasMore: keepExisting ? state.hasMore : false,
          filteredCount: keepExisting ? state.filteredCount : 0,
        ),
      );
    }

    try {
      final patients = await _getAssigned(employeeName);
      if (isClosed) return;
      _data = PatientListUiMapper.fromPatients(patients);
      CampMemoryCache.setPatients(employeeName, _data);
      _emitFiltered(resetPage: true);
    } on PatientFailure catch (e) {
      if (isClosed) return;
      if (hasCache) return;
      emit(
        PatientsFailureState(
          e.message,
          data: keepExisting ? _data : PatientListUi.empty,
          patients: keepExisting ? state.patients : const [],
          search: _search,
          filter: _filter,
          hasMore: false,
          filteredCount: 0,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      if (hasCache) return;
      emit(
        PatientsFailureState(
          'Failed to load patients. Please try again.',
          data: keepExisting ? _data : PatientListUi.empty,
          patients: keepExisting ? state.patients : const [],
          search: _search,
          filter: _filter,
          hasMore: false,
          filteredCount: 0,
        ),
      );
    }
  }

  void setSearch(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (isClosed) return;
      _search = value;
      _emitFiltered(resetPage: true);
    });
  }

  void setFilter(String value) {
    _filter = value;
    _emitFiltered(resetPage: true);
  }

  void loadMore() {
    if (_visibleCount >= _filtered.length) return;
    _visibleCount = math.min(_visibleCount + pageSize, _filtered.length);
    emit(
      PatientsLoaded(
        data: _data,
        patients: _filtered.sublist(0, _visibleCount),
        search: _search,
        filter: _filter,
        hasMore: _visibleCount < _filtered.length,
        filteredCount: _filtered.length,
      ),
    );
  }

  void _emitFiltered({bool resetPage = false}) {
    _filtered = _applyFilters(_data.patients);
    if (resetPage) {
      _visibleCount = math.min(pageSize, _filtered.length);
    } else {
      _visibleCount = math.min(_visibleCount, _filtered.length);
    }
    emit(
      PatientsLoaded(
        data: _data,
        patients: _filtered.sublist(0, _visibleCount),
        search: _search,
        filter: _filter,
        hasMore: _visibleCount < _filtered.length,
        filteredCount: _filtered.length,
      ),
    );
  }

  List<PatientUi> _applyFilters(List<PatientUi> source) {
    final q = _search.trim().toLowerCase();
    return source.where((p) {
      final matchesQuery = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.phone.toLowerCase().contains(q) ||
          (p.campTag?.toLowerCase().contains(q) ?? false);

      final matchesFilter = switch (_filter) {
        'Female' => p.gender == PatientGender.female,
        'Male' => p.gender == PatientGender.male,
        'Minors' => p.age < 18,
        _ => true,
      };

      return matchesQuery && matchesFilter;
    }).toList(growable: false);
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }
}
