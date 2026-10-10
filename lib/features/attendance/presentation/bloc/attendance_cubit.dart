import 'dart:convert';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timelay_health/core/utils/time_format.dart';
import 'package:timelay_health/features/attendance/data/repositories_impl/attendance_repository_impl.dart';
import 'package:timelay_health/features/attendance/domain/entities/ot_claim_params.dart';
import 'package:timelay_health/features/attendance/domain/failures/attendance_failure.dart';
import 'package:timelay_health/features/attendance/domain/usecases/claim_ot_usecase.dart';
import 'package:timelay_health/features/attendance/domain/usecases/get_my_attendance_usecase.dart';
import 'package:timelay_health/features/attendance/domain/usecases/get_my_shift_usecase.dart';
import 'package:timelay_health/features/attendance/presentation/bloc/attendance_state.dart';
import 'package:timelay_health/features/attendance/presentation/mappers/attendance_ui_mapper.dart';
import 'package:timelay_health/features/attendance/presentation/models/attendance_record_ui_model.dart';
import 'package:timelay_health/features/auth/data/auth_session.dart';

class AttendanceCubit extends Cubit<AttendanceState> {
  AttendanceCubit({
    GetMyAttendanceUseCase? getMyAttendanceUseCase,
    GetMyShiftUseCase? getMyShiftUseCase,
    ClaimOtUseCase? claimOtUseCase,
  }) : _getMyAttendance =
           getMyAttendanceUseCase ??
           GetMyAttendanceUseCase(AttendanceRepositoryImpl()),
       _getMyShift =
           getMyShiftUseCase ?? GetMyShiftUseCase(AttendanceRepositoryImpl()),
       _claimOt = claimOtUseCase ?? ClaimOtUseCase(AttendanceRepositoryImpl()),
       super(const AttendanceInitial());

  final GetMyAttendanceUseCase _getMyAttendance;
  final GetMyShiftUseCase _getMyShift;
  final ClaimOtUseCase _claimOt;

  List<AttendanceRecordUiModel> _allRecords = const [];
  AttendanceStatsUiModel _stats = AttendanceStatsUiModel.empty;
  AttendanceFilter _filter = AttendanceFilter.empty;
  String _shiftLabel = '—';
  Set<String> _selectedOtIds = const {};

  Future<void> load({bool keepExisting = false}) async {
    emit(
      AttendanceLoading(
        records: keepExisting ? state.records : const [],
        allRecords: keepExisting ? _allRecords : const [],
        stats: keepExisting ? _stats : AttendanceStatsUiModel.empty,
        filter: _filter,
        shiftLabel: keepExisting ? _shiftLabel : '—',
        selectedOtIds: keepExisting ? _selectedOtIds : const {},
      ),
    );

    final employeeId =
        AuthSession.currentEmployee?.employeeId ??
        (await AuthSession.load())?.employeeId ??
        '';

    if (isClosed) return;

    if (employeeId.isEmpty) {
      emit(
        AttendanceFailureState(
          'Employee ID missing. Please login again.',
          records: keepExisting ? state.records : const [],
          allRecords: keepExisting ? _allRecords : const [],
          stats: keepExisting ? _stats : AttendanceStatsUiModel.empty,
          filter: _filter,
          shiftLabel: keepExisting ? _shiftLabel : '—',
          selectedOtIds: keepExisting ? _selectedOtIds : const {},
        ),
      );
      return;
    }

    try {
      final result = await _getMyAttendance(employeeId);
      if (isClosed) return;
      _allRecords = AttendanceUiMapper.toUiList(
        result.records,
        claimedIds: result.claimedAttendanceIds,
      );
      final claimableIds = {
        for (final r in _allRecords)
          if (r.hasClaimableOt) r.id,
      };
      _selectedOtIds = _selectedOtIds.intersection(claimableIds);
      _stats = AttendanceUiMapper.toStats(
        result.records,
        serverStats: result.stats,
      );
      if (claimableIds.isEmpty || !_stats.hasOt) {
        _filter = _filter.copyWith(otOnly: false);
      }

      try {
        final shift = await _getMyShift(employeeId);
        _shiftLabel = TimeFormat.shiftRange(shift.displayTiming);
      } catch (_) {
        if (!keepExisting || _shiftLabel.isEmpty) {
          _shiftLabel = '—';
        }
      }

      if (isClosed) return;
      _emitFiltered();
    } on AttendanceFailure catch (e) {
      if (isClosed) return;
      emit(
        AttendanceFailureState(
          e.message,
          records: keepExisting ? state.records : const [],
          allRecords: keepExisting ? _allRecords : const [],
          stats: keepExisting ? _stats : AttendanceStatsUiModel.empty,
          filter: _filter,
          shiftLabel: keepExisting ? _shiftLabel : '—',
          selectedOtIds: keepExisting ? _selectedOtIds : const {},
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        AttendanceFailureState(
          'Failed to load attendance. Please try again.',
          records: keepExisting ? state.records : const [],
          allRecords: keepExisting ? _allRecords : const [],
          stats: keepExisting ? _stats : AttendanceStatsUiModel.empty,
          filter: _filter,
          shiftLabel: keepExisting ? _shiftLabel : '—',
          selectedOtIds: keepExisting ? _selectedOtIds : const {},
        ),
      );
    }
  }

  void setExactDate(DateTime? date) {
    _filter = date == null
        ? _filter.copyWith(clearExactDate: true)
        : _filter.copyWith(
            exactDate: _dateOnly(date),
            clearFromDate: true,
            clearToDate: true,
          );
    _emitFiltered();
  }

  void setFromDate(DateTime? date) {
    if (date == null) {
      _filter = _filter.copyWith(clearFromDate: true);
    } else {
      final from = _dateOnly(date);
      final to = _filter.toDate;
      _filter = to != null && from.isAfter(to)
          ? _filter.copyWith(fromDate: to, toDate: from, clearExactDate: true)
          : _filter.copyWith(fromDate: from, clearExactDate: true);
    }
    _emitFiltered();
  }

  void setToDate(DateTime? date) {
    if (date == null) {
      _filter = _filter.copyWith(clearToDate: true);
    } else {
      final to = _dateOnly(date);
      final from = _filter.fromDate;
      _filter = from != null && to.isBefore(from)
          ? _filter.copyWith(fromDate: to, toDate: from, clearExactDate: true)
          : _filter.copyWith(toDate: to, clearExactDate: true);
    }
    _emitFiltered();
  }

  void setStatus(AttendanceStatusFilter status) {
    _filter = _filter.copyWith(status: status);
    _emitFiltered();
  }

  void setLocation(AttendanceLocationFilter location) {
    _filter = _filter.copyWith(location: location);
    _emitFiltered();
  }

  void clearFilters() {
    _filter = AttendanceFilter.empty;
    _emitFiltered();
  }

  void setOtOnly(bool value) {
    _filter = _filter.copyWith(otOnly: value);
    _emitFiltered();
  }

  void toggleOtSelection(String recordId) {
    final next = {..._selectedOtIds};
    if (!next.remove(recordId)) next.add(recordId);
    _selectedOtIds = next;
    _emitFiltered();
  }

  void selectAllOt() {
    _selectedOtIds = state.otRecords.map((r) => r.id).toSet();
    _emitFiltered();
  }

  void clearOtSelection() {
    _selectedOtIds = const {};
    _emitFiltered();
  }

  Future<String> claimOt({
    required List<AttendanceRecordUiModel> records,
    required String reason,
  }) async {
    final employee = AuthSession.currentEmployee ?? await AuthSession.load();
    final message = await _claimOt(
      OtClaimParams(
        employeeId: employee?.employeeId ?? '',
        employeeName: employee?.displayName ?? '',
        reason: reason,
        items: [
          for (final r in records)
            OtClaimItem(
              attendanceId: r.id,
              date: r.checkInDate,
              otHours: r.claimableOtHours,
            ),
        ],
      ),
    );
    _selectedOtIds = const {};
    await load(keepExisting: true);
    return message;
  }

  Future<({String fileName, String filePath})> exportCsv() async {
    final rows = state.records;
    if (rows.isEmpty) {
      throw const AttendanceFailure('No records to export.');
    }

    final buffer = StringBuffer()
      ..writeln(
        'Date,Check-In Time,Check-Out Time,Assigned Shift,Total Hours,'
        'OT Hours,Claimed OT,OT Amount,Multiplier,Distance (m),Onsite,'
        'Reason,Status',
      );

    for (final r in rows) {
      final shift = r.assignedShiftHours > 0
          ? '${r.assignedShiftHours.round()}h'
          : '9h';
      const claimedOt = '-';
      final otAmount = r.otAmount > 0 ? r.otAmount.toStringAsFixed(2) : '-';
      final multiplier = r.otMultiplier > 0
          ? r.otMultiplier.toStringAsFixed(0)
          : '-';

      buffer.writeln(
        [
          _csv(r.exportDate),
          _csv(r.exportCheckIn),
          _csv(r.exportCheckOut),
          _csv(shift),
          _csv(AttendanceUiMapper.hoursLabel(r.workingHours)),
          _csv(AttendanceUiMapper.hoursLabel(r.otHours)),
          _csv(claimedOt),
          _csv(otAmount),
          _csv(multiplier),
          _csv(r.distanceMeters.toStringAsFixed(2)),
          _csv(r.onsite ? 'Yes' : 'No'),
          _csv(r.note),
          _csv(r.exportStatus),
        ].join(','),
      );
    }

    final now = DateTime.now();
    final d = now.day.toString().padLeft(2, '0');
    final m = now.month.toString().padLeft(2, '0');
    final fileName = 'my_attendance_$d-$m-${now.year}.csv';

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(buffer.toString(), encoding: utf8);

    if (!await file.exists() || await file.length() == 0) {
      throw const AttendanceFailure('Could not create CSV file.');
    }

    return (fileName: fileName, filePath: file.path);
  }

  void _emitFiltered() {
    final filtered = _applyFilter(_allRecords, _filter);
    emit(
      AttendanceLoaded(
        records: filtered,
        allRecords: _allRecords,
        stats: _stats,
        filter: _filter,
        shiftLabel: _shiftLabel,
        selectedOtIds: _selectedOtIds,
      ),
    );
  }

  List<AttendanceRecordUiModel> _applyFilter(
    List<AttendanceRecordUiModel> records,
    AttendanceFilter filter,
  ) {
    return records.where((record) {
      final date = record.checkInDate;
      if (filter.exactDate != null) {
        if (date == null || !_isSameDay(date, filter.exactDate!)) {
          return false;
        }
      }
      if (filter.fromDate != null) {
        if (date == null || date.isBefore(filter.fromDate!)) return false;
      }
      if (filter.toDate != null) {
        if (date == null) return false;
        final end = filter.toDate!.add(const Duration(days: 1));
        if (!date.isBefore(end)) return false;
      }
      switch (filter.status) {
        case AttendanceStatusFilter.active:
          if (!record.isActive) return false;
        case AttendanceStatusFilter.loggedOut:
          if (record.isActive) return false;
        case AttendanceStatusFilter.all:
          break;
      }
      switch (filter.location) {
        case AttendanceLocationFilter.onsite:
          if (!record.onsite) return false;
        case AttendanceLocationFilter.wfh:
          if (record.onsite) return false;
        case AttendanceLocationFilter.all:
          break;
      }
      if (filter.otOnly && !record.hasClaimableOt) return false;
      return true;
    }).toList();
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _csv(String value) {
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }
}
