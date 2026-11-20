import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelay_health/features/admin/attendance/data/repositories_impl/absent_today_repository_impl.dart';
import 'package:timelay_health/features/admin/attendance/domain/failures/attendance_records_failure.dart';
import 'package:timelay_health/features/admin/attendance/domain/repositories/absent_today_repository.dart';
import 'package:timelay_health/features/admin/attendance/presentation/bloc/absent_today_state.dart';

class AbsentTodayCubit extends Cubit<AbsentTodayState> {
  AbsentTodayCubit({AbsentTodayRepository? repository})
      : _repository = repository ?? AbsentTodayRepositoryImpl(),
        super(const AbsentTodayInitial());

  final AbsentTodayRepository _repository;

  static String _todayFormatted() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> load({
    String? fromDate,
    String? toDate,
    bool isRefresh = false,
  }) async {
    final effectiveFrom = fromDate ?? state.selectedFromDate ?? _todayFormatted();
    final effectiveTo = toDate ?? state.selectedToDate ?? effectiveFrom;

    if (!isRefresh && state is AbsentTodayLoading) return;

    emit(AbsentTodayLoading(
      ui: isRefresh ? state.ui : state.ui,
      searchQuery: state.searchQuery,
      selectedFromDate: effectiveFrom,
      selectedToDate: effectiveTo,
    ));

    try {
      final ui = await _repository.getAbsentRecords(
        fromDate: effectiveFrom,
        toDate: effectiveTo,
      );

      emit(AbsentTodayLoaded(
        ui: ui,
        searchQuery: state.searchQuery,
        selectedFromDate: effectiveFrom,
        selectedToDate: effectiveTo,
      ));
    } catch (e) {
      final msg = e is AttendanceRecordsFailure
          ? e.message
          : 'Failed to load absent records. Please try again.';
      emit(AbsentTodayFailureState(
        ui: state.ui,
        message: msg,
        searchQuery: state.searchQuery,
        selectedFromDate: effectiveFrom,
        selectedToDate: effectiveTo,
      ));
    }
  }

  void updateSearch(String query) {
    if (state is AbsentTodayLoaded) {
      emit((state as AbsentTodayLoaded).copyWith(searchQuery: query));
    }
  }
}
