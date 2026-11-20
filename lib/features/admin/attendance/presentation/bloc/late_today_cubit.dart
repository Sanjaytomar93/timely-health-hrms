import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelay_health/features/admin/attendance/data/repositories_impl/late_today_repository_impl.dart';
import 'package:timelay_health/features/admin/attendance/domain/failures/attendance_records_failure.dart';
import 'package:timelay_health/features/admin/attendance/domain/repositories/late_today_repository.dart';
import 'package:timelay_health/features/admin/attendance/presentation/bloc/late_today_state.dart';

class LateTodayCubit extends Cubit<LateTodayState> {
  LateTodayCubit({LateTodayRepository? repository})
      : _repository = repository ?? LateTodayRepositoryImpl(),
        super(const LateTodayInitial());

  final LateTodayRepository _repository;

  Future<void> load({
    String? date,
    String? month,
    bool isRefresh = false,
    bool clearDate = false,
  }) async {
    final effectiveDate = clearDate ? null : (date ?? state.selectedDate);
    final effectiveMonth = month ?? state.selectedMonth;

    if (!isRefresh && state is LateTodayLoading) return;

    emit(LateTodayLoading(
      ui: state.ui,
      searchQuery: state.searchQuery,
      selectedDate: effectiveDate,
      selectedMonth: effectiveMonth,
    ));

    try {
      final ui = await _repository.getLateRecords(
        date: effectiveDate,
        month: effectiveMonth,
      );

      if (isClosed) return;
      emit(LateTodayLoaded(
        ui: ui,
        searchQuery: state.searchQuery,
        selectedDate: effectiveDate,
        selectedMonth: effectiveMonth,
      ));
    } catch (e) {
      if (isClosed) return;
      final msg = e is AttendanceRecordsFailure
          ? e.message
          : 'Failed to load late attendance records. Please try again.';
      emit(LateTodayFailureState(
        ui: state.ui,
        message: msg,
        searchQuery: state.searchQuery,
        selectedDate: effectiveDate,
        selectedMonth: effectiveMonth,
      ));
    }
  }

  void setSearchQuery(String query) {
    if (state is LateTodayLoaded) {
      emit((state as LateTodayLoaded).copyWith(searchQuery: query));
    }
  }
}
