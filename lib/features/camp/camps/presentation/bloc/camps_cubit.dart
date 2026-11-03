import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelay_health/features/auth/data/auth_session.dart';
import 'package:timelay_health/features/camp/camps/data/repositories_impl/camp_repository_impl.dart';
import 'package:timelay_health/features/camp/camps/domain/failures/camp_failure.dart';
import 'package:timelay_health/features/camp/camps/domain/usecases/get_assigned_camps_usecase.dart';
import 'package:timelay_health/features/camp/camps/presentation/bloc/camps_state.dart';
import 'package:timelay_health/features/camp/camps/presentation/models/camp_list_ui.dart';
import 'package:timelay_health/features/camp/shared/camp_memory_cache.dart';

class CampsCubit extends Cubit<CampsState> {
  CampsCubit({GetAssignedCampsUseCase? getAssignedCampsUseCase})
    : _getAssigned =
          getAssignedCampsUseCase ??
          GetAssignedCampsUseCase(CampRepositoryImpl()),
      super(const CampsInitial());

  final GetAssignedCampsUseCase _getAssigned;

  List<CampItemUi> _all = const [];
  List<CampListStatUi> _stats = const [];
  String _search = '';
  String _filter = 'All camps';
  Timer? _searchDebounce;

  Future<void> load({bool keepExisting = false}) async {
    final employee =
        AuthSession.currentEmployee ?? await AuthSession.load();
    final employeeName = employee?.displayName.trim() ?? '';

    if (isClosed) return;

    if (employeeName.isEmpty) {
      emit(
        CampsFailureState(
          'Employee name missing. Please login again.',
          camps: keepExisting ? state.camps : const [],
          allCamps: keepExisting ? _all : const [],
          stats: keepExisting ? _stats : const [],
          search: _search,
          filter: _filter,
        ),
      );
      return;
    }

    final cached = CampMemoryCache.camps(employeeName);
    final hasCache = cached != null && cached.camps.isNotEmpty;
    if (cached != null && hasCache) {
      _all = cached.camps;
      _stats = cached.stats;
      _emitFiltered();
    } else {
      emit(
        CampsLoading(
          camps: keepExisting ? state.camps : const [],
          allCamps: keepExisting ? _all : const [],
          stats: keepExisting ? _stats : const [],
          search: _search,
          filter: _filter,
        ),
      );
    }

    try {
      final camps = await _getAssigned(employeeName);
      if (isClosed) return;
      _all = CampListUiMapper.toUiList(camps);
      _stats = CampListUiMapper.toStats(_all);
      CampMemoryCache.setCamps(
        employeeName,
        camps: _all,
        stats: _stats,
      );
      _emitFiltered();
    } on CampFailure catch (e) {
      if (isClosed) return;
      if (hasCache) return;
      emit(
        CampsFailureState(
          e.message,
          camps: keepExisting ? state.camps : const [],
          allCamps: keepExisting ? _all : const [],
          stats: keepExisting ? _stats : const [],
          search: _search,
          filter: _filter,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      if (hasCache) return;
      emit(
        CampsFailureState(
          'Failed to load camps. Please try again.',
          camps: keepExisting ? state.camps : const [],
          allCamps: keepExisting ? _all : const [],
          stats: keepExisting ? _stats : const [],
          search: _search,
          filter: _filter,
        ),
      );
    }
  }

  void setSearch(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (isClosed) return;
      _search = value;
      _emitFiltered();
    });
  }

  void setFilter(String value) {
    _filter = value;
    _emitFiltered();
  }

  void _emitFiltered() {
    emit(
      CampsLoaded(
        camps: _applyFilters(_all),
        allCamps: _all,
        stats: _stats,
        search: _search,
        filter: _filter,
      ),
    );
  }

  List<CampItemUi> _applyFilters(List<CampItemUi> source) {
    final q = _search.trim().toLowerCase();
    return source.where((c) {
      final matchesQuery = q.isEmpty ||
          c.name.toLowerCase().contains(q) ||
          c.location.toLowerCase().contains(q);
      final matchesFilter = switch (_filter) {
        'Today' => c.status == CampListStatus.today,
        'Live' => c.status == CampListStatus.live,
        'Upcoming' => c.status == CampListStatus.upcoming,
        'Completed' => c.status == CampListStatus.completed,
        _ => true,
      };
      return matchesQuery && matchesFilter;
    }).toList();
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }
}
