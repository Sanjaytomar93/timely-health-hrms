import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelay_health/features/admin/attendance/data/repositories_impl/attendance_records_repository_impl.dart';
import 'package:timelay_health/features/admin/attendance/domain/failures/attendance_records_failure.dart';
import 'package:timelay_health/features/admin/attendance/domain/repositories/attendance_records_repository.dart';
import 'package:timelay_health/features/admin/attendance/presentation/bloc/attendance_records_state.dart';
import 'package:timelay_health/features/admin/attendance/presentation/models/attendance_records_ui.dart';

class AttendanceRecordsCubit extends Cubit<AttendanceRecordsState> {
  AttendanceRecordsCubit({AttendanceRecordsRepository? repository})
      : _repository = repository ?? AttendanceRecordsRepositoryImpl(),
        super(AttendanceRecordsInitial(month: _currentMonthString()));

  final AttendanceRecordsRepository _repository;

  static String _currentMonthString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  String? _normalizeFilter(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed == 'All') return null;
    return trimmed;
  }

  Future<void> load({
    String? month,
    int? page,
    String? department,
    String? designation,
    String? date,
    String? dateEnd,
    String? searchQuery,
    bool isRefresh = false,
  }) async {
    final targetMonth = month ?? state.selectedMonth;
    final targetDept = department != null
        ? _normalizeFilter(department)
        : state.selectedDepartment;
    final targetDesig = designation != null
        ? _normalizeFilter(designation)
        : state.selectedDesignation;
    final String? targetDate;
    if (date != null) {
      targetDate = date.trim().isEmpty ? null : date.trim();
    } else {
      targetDate = state.selectedDate;
    }
    final targetDateEnd =
        dateEnd != null && dateEnd.trim().isNotEmpty ? dateEnd.trim() : null;
    final targetQuery = searchQuery ?? state.searchQuery;

    emit(AttendanceRecordsLoading(
      ui: isRefresh ? state.ui : AttendanceRecordsUi.empty,
      selectedMonth: targetMonth,
      selectedDepartment: targetDept,
      selectedDesignation: targetDesig,
      selectedDate: targetDate,
      searchQuery: targetQuery,
      page: 1,
      isFetchingMore: false,
      hasReachedMax: false,
    ));

    try {
      final AttendanceRecordsUi ui;
      if (targetDate != null) {
        ui = await _fetchAllAndFilterByDate(
          month: targetMonth,
          date: targetDate,
          dateEnd: targetDateEnd,
          department: targetDept,
          designation: targetDesig,
        );
      } else {
        ui = await _repository.getPageData(
          month: targetMonth,
          page: 1,
          limit: 15,
          department: targetDept,
          designation: targetDesig,
        );
      }

      if (isClosed) return;
      final reachedMax = targetDate != null ||
          1 >= ui.totalPages ||
          ui.records.length < 15 ||
          ui.records.length >= ui.totalRecords;
      emit(AttendanceRecordsLoaded(
        ui: ui,
        selectedMonth: targetMonth,
        selectedDepartment: targetDept,
        selectedDesignation: targetDesig,
        selectedDate: targetDate,
        searchQuery: targetQuery,
        page: 1,
        isFetchingMore: false,
        hasReachedMax: reachedMax,
      ));
    } on AttendanceRecordsFailure catch (e) {
      if (isClosed) return;
      emit(AttendanceRecordsFailureState(
        message: e.message,
        ui: state.ui,
        selectedMonth: targetMonth,
        selectedDepartment: targetDept,
        selectedDesignation: targetDesig,
        selectedDate: targetDate,
        searchQuery: targetQuery,
        page: 1,
      ));
    } catch (_) {
      if (isClosed) return;
      emit(AttendanceRecordsFailureState(
        message: 'Failed to load attendance records. Please try again.',
        ui: state.ui,
        selectedMonth: targetMonth,
        selectedDepartment: targetDept,
        selectedDesignation: targetDesig,
        selectedDate: targetDate,
        searchQuery: targetQuery,
        page: 1,
      ));
    }
  }

  Future<AttendanceRecordsUi> _fetchAllAndFilterByDate({
    required String month,
    required String date,
    String? dateEnd,
    String? department,
    String? designation,
  }) async {
    final first = await _repository.getPageData(
      month: month,
      page: 1,
      limit: 100,
      department: department,
      designation: designation,
    );

    final all = <PunchRecordItem>[...first.records];
    final totalPages = first.totalPages < 1 ? 1 : first.totalPages;

    if (totalPages > 1) {
      final maxPage = totalPages > 50 ? 50 : totalPages;
      final rest = await Future.wait([
        for (var p = 2; p <= maxPage; p++)
          _repository.getPageData(
            month: month,
            page: p,
            limit: 100,
            department: department,
            designation: designation,
          ),
      ]);
      for (final pageUi in rest) {
        all.addAll(pageUi.records);
      }
    }

    final end = dateEnd ?? date;
    final filtered = all.where((r) {
      final d = r.dateString;
      if (d.isEmpty) return false;
      return d.compareTo(date) >= 0 && d.compareTo(end) <= 0;
    }).toList(growable: false);

    final onsite = filtered.where((r) => !r.isRemote).length;
    final active = filtered.where((r) => r.isActive).length;

    return first.copyWith(
      records: filtered,
      totalRecords: filtered.length,
      onsiteEntries: onsite,
      activeEntries: active,
      remoteEntries: (filtered.length - onsite).clamp(0, filtered.length),
      loggedOutEntries: (filtered.length - active).clamp(0, filtered.length),
      totalPages: 1,
      currentPage: 1,
      limit: filtered.length,
    );
  }

  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is! AttendanceRecordsLoaded) return;
    if (currentState.isFetchingMore || currentState.hasReachedMax) return;
    if (currentState.selectedDate != null) {
      emit(currentState.copyWith(hasReachedMax: true));
      return;
    }

    final nextPage = currentState.page + 1;
    if (nextPage > currentState.ui.totalPages) {
      emit(currentState.copyWith(hasReachedMax: true));
      return;
    }

    emit(currentState.copyWith(isFetchingMore: true));

    try {
      final newUi = await _repository.getPageData(
        month: currentState.selectedMonth,
        page: nextPage,
        limit: 15,
        department: currentState.selectedDepartment,
        designation: currentState.selectedDesignation,
      );

      if (isClosed) return;

      final mergedRecords = [...currentState.ui.records, ...newUi.records];
      final updatedUi = currentState.ui.copyWith(
        records: mergedRecords,
        currentPage: nextPage,
        totalPages: newUi.totalPages,
        totalRecords: newUi.totalRecords,
        onsiteEntries: newUi.onsiteEntries,
        activeEntries: newUi.activeEntries,
        limit: 15,
      );

      final reachedMax = nextPage >= newUi.totalPages ||
          newUi.records.isEmpty ||
          mergedRecords.length >= newUi.totalRecords;

      emit(AttendanceRecordsLoaded(
        ui: updatedUi,
        selectedMonth: currentState.selectedMonth,
        selectedDepartment: currentState.selectedDepartment,
        selectedDesignation: currentState.selectedDesignation,
        selectedDate: currentState.selectedDate,
        searchQuery: currentState.searchQuery,
        page: nextPage,
        isFetchingMore: false,
        hasReachedMax: reachedMax,
      ));
    } catch (_) {
      if (isClosed) return;
      emit(currentState.copyWith(isFetchingMore: false));
    }
  }

  void updateSearch(String query) {
    if (state is AttendanceRecordsLoaded) {
      final loaded = state as AttendanceRecordsLoaded;
      emit(loaded.copyWith(searchQuery: query));
    }
  }
}
