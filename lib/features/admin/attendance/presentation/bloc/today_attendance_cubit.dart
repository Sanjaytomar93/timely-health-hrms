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

  String? _fromDate;
  String? _toDate;

  static String _ymd(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static String _todayYmd() => _ymd(DateTime.now());

  static String _monthRangeEnd(String month) {
    final parts = month.split('-');
    final year = int.tryParse(parts[0]) ?? DateTime.now().year;
    final m =
        int.tryParse(parts.length > 1 ? parts[1] : '') ?? DateTime.now().month;
    final last = DateTime(year, m + 1, 0);
    final now = DateTime.now();
    if (year == now.year && m == now.month && last.isAfter(now)) {
      return _ymd(now);
    }
    return _ymd(last);
  }

  Future<void> load({
    bool isRefresh = false,
    String? month,
    String? date,
    String? dateEnd,
  }) async {
    String? targetMonth = state.selectedMonth;
    String? targetDate = state.selectedDate;

    if (date != null || month != null) {
      if (date != null && date.trim().isNotEmpty) {
        final from = date.trim();
        final to = (dateEnd != null && dateEnd.trim().isNotEmpty)
            ? dateEnd.trim()
            : from;
        _fromDate = from;
        _toDate = to;
        targetDate = from;
        targetMonth = from.substring(0, 7);
      } else if (month != null && month.trim().isNotEmpty) {
        final m = month.trim();
        _fromDate = '$m-01';
        _toDate = _monthRangeEnd(m);
        targetMonth = m;
        targetDate = null;
      } else {
        _fromDate = _todayYmd();
        _toDate = _fromDate;
        targetMonth = null;
        targetDate = null;
      }
    } else {
      _fromDate ??= _todayYmd();
      _toDate ??= _fromDate;
    }

    emit(TodayAttendanceLoading(
      ui: isRefresh ? state.ui : TodayAttendanceUi.empty,
      searchQuery: state.searchQuery,
      selectedMonth: targetMonth,
      selectedDate: targetDate,
      page: 1,
      isFetchingMore: false,
      hasReachedMax: false,
      usePagedMonth: true,
    ));

    try {
      final ui = await _repository.getTodayAttendance(
        fromDate: _fromDate,
        toDate: _toDate,
        page: 1,
        limit: 100,
      );

      if (isClosed) return;
      emit(TodayAttendanceLoaded(
        ui: ui,
        searchQuery: state.searchQuery,
        selectedMonth: targetMonth,
        selectedDate: targetDate,
        page: 1,
        isFetchingMore: false,
        hasReachedMax: !ui.hasMore,
        usePagedMonth: true,
      ));
    } on AttendanceRecordsFailure catch (e) {
      if (isClosed) return;
      emit(TodayAttendanceFailureState(
        message: e.message,
        ui: state.ui,
        searchQuery: state.searchQuery,
        selectedMonth: targetMonth,
        selectedDate: targetDate,
        usePagedMonth: true,
      ));
    } catch (_) {
      if (isClosed) return;
      emit(TodayAttendanceFailureState(
        message: 'Failed to load today attendance records. Please try again.',
        ui: state.ui,
        searchQuery: state.searchQuery,
        selectedMonth: targetMonth,
        selectedDate: targetDate,
        usePagedMonth: true,
      ));
    }
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! TodayAttendanceLoaded) return;
    if (current.isFetchingMore || current.hasReachedMax) return;
    if (_fromDate == null || _toDate == null) return;

    final nextPage = current.page + 1;
    emit(current.copyWith(isFetchingMore: true));

    try {
      final newUi = await _repository.getTodayAttendance(
        fromDate: _fromDate,
        toDate: _toDate,
        page: nextPage,
        limit: 100,
      );

      if (isClosed) return;

      final merged = [...current.ui.records, ...newUi.records];
      final updated = current.ui.copyWith(
        records: merged,
        currentPage: nextPage,
        totalPages: newUi.totalPages,
        totalRecords: newUi.totalRecords,
        totalCheckIn: newUi.totalCheckIn,
        activeWorking: newUi.activeWorking,
        onsiteCount: newUi.onsiteCount,
        remoteCount: newUi.remoteCount,
        hasMore: newUi.hasMore,
      );

      emit(TodayAttendanceLoaded(
        ui: updated,
        searchQuery: current.searchQuery,
        selectedMonth: current.selectedMonth,
        selectedDate: current.selectedDate,
        page: nextPage,
        isFetchingMore: false,
        hasReachedMax: !newUi.hasMore,
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
