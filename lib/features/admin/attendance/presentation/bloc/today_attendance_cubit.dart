import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelay_health/features/admin/attendance/data/repositories_impl/today_attendance_repository_impl.dart';
import 'package:timelay_health/features/admin/attendance/domain/failures/attendance_records_failure.dart';
import 'package:timelay_health/features/admin/attendance/domain/repositories/today_attendance_repository.dart';
import 'package:timelay_health/features/admin/attendance/presentation/bloc/today_attendance_state.dart';
import 'package:timelay_health/features/admin/attendance/presentation/models/today_attendance_ui.dart';

class TodayAttendanceCubit extends Cubit<TodayAttendanceState> {
  TodayAttendanceCubit({TodayAttendanceRepository? repository})
      : _repository = repository ?? TodayAttendanceRepositoryImpl(),
        super(const TodayAttendanceInitial());

  final TodayAttendanceRepository _repository;

  Future<void> load({
    bool isRefresh = false,
    String? month,
    String? date,
  }) async {
    final String? targetDate = date != null
        ? (date.trim().isEmpty ? null : date.trim())
        : state.selectedDate;

    String? targetMonth = month != null
        ? (month.trim().isEmpty ? null : month.trim())
        : state.selectedMonth;

    if (targetDate != null) {
      targetMonth = targetDate.substring(0, 7);
    }

    final usePagedMonth = targetMonth != null && targetDate == null;

    emit(TodayAttendanceLoading(
      ui: isRefresh ? state.ui : TodayAttendanceUi.empty,
      searchQuery: state.searchQuery,
      selectedMonth: targetMonth,
      selectedDate: targetDate,
      page: 1,
      isFetchingMore: false,
      hasReachedMax: false,
      usePagedMonth: usePagedMonth,
    ));

    try {
      final TodayAttendanceUi ui;
      if (targetDate != null) {
        ui = await _repository.getByMonth(
          month: targetMonth!,
          date: targetDate,
        );
      } else if (targetMonth != null) {
        ui = await _repository.getByMonth(
          month: targetMonth,
          page: 1,
          limit: 15,
        );
      } else {
        ui = await _repository.getTodayAttendance();
      }

      if (isClosed) return;
      final reachedMax = !usePagedMonth ||
          1 >= ui.totalPages ||
          ui.records.length < 15 ||
          ui.records.length >= ui.totalRecords;

      emit(TodayAttendanceLoaded(
        ui: ui,
        searchQuery: state.searchQuery,
        selectedMonth: targetMonth,
        selectedDate: targetDate,
        page: 1,
        isFetchingMore: false,
        hasReachedMax: reachedMax,
        usePagedMonth: usePagedMonth,
      ));
    } on AttendanceRecordsFailure catch (e) {
      if (isClosed) return;
      emit(TodayAttendanceFailureState(
        message: e.message,
        ui: state.ui,
        searchQuery: state.searchQuery,
        selectedMonth: targetMonth,
        selectedDate: targetDate,
        usePagedMonth: usePagedMonth,
      ));
    } catch (_) {
      if (isClosed) return;
      emit(TodayAttendanceFailureState(
        message: 'Failed to load today attendance records. Please try again.',
        ui: state.ui,
        searchQuery: state.searchQuery,
        selectedMonth: targetMonth,
        selectedDate: targetDate,
        usePagedMonth: usePagedMonth,
      ));
    }
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! TodayAttendanceLoaded) return;
    if (!current.usePagedMonth) return;
    if (current.isFetchingMore || current.hasReachedMax) return;
    if (current.selectedMonth == null) return;

    final nextPage = current.page + 1;
    if (nextPage > current.ui.totalPages) {
      emit(current.copyWith(hasReachedMax: true));
      return;
    }

    emit(current.copyWith(isFetchingMore: true));

    try {
      final newUi = await _repository.getByMonth(
        month: current.selectedMonth!,
        page: nextPage,
        limit: 15,
      );

      if (isClosed) return;

      final merged = [...current.ui.records, ...newUi.records];
      final updated = current.ui.copyWith(
        records: merged,
        currentPage: nextPage,
        totalPages: newUi.totalPages,
        totalRecords: newUi.totalRecords,
        totalCheckIn:
            newUi.totalRecords > 0 ? newUi.totalRecords : merged.length,
      );

      final reachedMax = nextPage >= newUi.totalPages ||
          newUi.records.isEmpty ||
          merged.length >= newUi.totalRecords;

      emit(TodayAttendanceLoaded(
        ui: updated,
        searchQuery: current.searchQuery,
        selectedMonth: current.selectedMonth,
        selectedDate: current.selectedDate,
        page: nextPage,
        isFetchingMore: false,
        hasReachedMax: reachedMax,
        usePagedMonth: true,
      ));
    } catch (_) {
      if (isClosed) return;
      emit(current.copyWith(isFetchingMore: false));
    }
  }

  void updateSearch(String query) {
    if (state is TodayAttendanceLoaded) {
      final loaded = state as TodayAttendanceLoaded;
      emit(loaded.copyWith(searchQuery: query));
    }
  }
}
