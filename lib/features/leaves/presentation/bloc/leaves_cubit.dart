import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelay_health/features/auth/data/auth_session.dart';
import 'package:timelay_health/features/leaves/data/repositories_impl/leave_repository_impl.dart';
import 'package:timelay_health/features/leaves/domain/entities/employee_leaves.dart';
import 'package:timelay_health/features/leaves/domain/entities/leave_record.dart';
import 'package:timelay_health/features/leaves/domain/entities/comp_off_request.dart';
import 'package:timelay_health/features/leaves/domain/failures/leave_failure.dart';
import 'package:timelay_health/features/leaves/domain/usecases/add_comp_off_usecase.dart';
import 'package:timelay_health/features/leaves/domain/usecases/add_leave_usecase.dart';
import 'package:timelay_health/features/leaves/domain/usecases/get_employee_leaves_usecase.dart';
import 'package:timelay_health/features/leaves/domain/usecases/get_comp_off_requests_usecase.dart';
import 'package:timelay_health/features/leaves/domain/usecases/get_extra_worked_days_usecase.dart';
import 'package:timelay_health/features/leaves/presentation/bloc/leaves_state.dart';
import 'package:timelay_health/features/leaves/presentation/models/leave_ui_model.dart';

class LeavesCubit extends Cubit<LeavesState> {
  LeavesCubit({
    GetEmployeeLeavesUseCase? getEmployeeLeavesUseCase,
    GetCompOffRequestsUseCase? getCompOffRequestsUseCase,
    GetExtraWorkedDaysUseCase? getExtraWorkedDaysUseCase,
    AddLeaveUseCase? addLeaveUseCase,
    AddCompOffUseCase? addCompOffUseCase,
  }) : _getLeaves =
           getEmployeeLeavesUseCase ??
           GetEmployeeLeavesUseCase(LeaveRepositoryImpl()),
       _getCompOffRequests =
           getCompOffRequestsUseCase ??
           GetCompOffRequestsUseCase(LeaveRepositoryImpl()),
       _getExtraWorkedDays =
           getExtraWorkedDaysUseCase ??
           GetExtraWorkedDaysUseCase(LeaveRepositoryImpl()),
       _addLeave = addLeaveUseCase ?? AddLeaveUseCase(LeaveRepositoryImpl()),
       _addCompOff =
           addCompOffUseCase ?? AddCompOffUseCase(LeaveRepositoryImpl()),
       super(const LeavesInitial());

  final GetEmployeeLeavesUseCase _getLeaves;
  final GetCompOffRequestsUseCase _getCompOffRequests;
  final GetExtraWorkedDaysUseCase _getExtraWorkedDays;
  final AddLeaveUseCase _addLeave;
  final AddCompOffUseCase _addCompOff;

  List<LeaveHistoryUiModel> _all = const [];
  LeaveStatsUiModel _stats = LeaveStatsUiModel.empty;
  CompOffRequests _compOffRequests = CompOffRequests.empty;
  String _search = '';
  DateTime? _selectedDate;
  DateTime? _selectedMonth;

  Future<void> load({bool keepExisting = false}) async {
    emit(
      LeavesLoading(
        leaves: keepExisting ? state.leaves : const [],
        allLeaves: keepExisting ? _all : const [],
        stats: keepExisting ? _stats : LeaveStatsUiModel.empty,
        compOffRequests: keepExisting
            ? _compOffRequests
            : CompOffRequests.empty,
        search: _search,
        selectedDate: _selectedDate,
        selectedMonth: _selectedMonth,
      ),
    );

    final employeeId =
        AuthSession.currentEmployee?.employeeId ??
        (await AuthSession.load())?.employeeId ??
        '';

    if (isClosed) return;
    if (employeeId.isEmpty) {
      emit(
        LeavesFailureState(
          'Employee ID missing. Please login again.',
          leaves: keepExisting ? state.leaves : const [],
          allLeaves: keepExisting ? _all : const [],
          stats: keepExisting ? _stats : LeaveStatsUiModel.empty,
          compOffRequests: keepExisting
              ? _compOffRequests
              : CompOffRequests.empty,
          search: _search,
          selectedDate: _selectedDate,
          selectedMonth: _selectedMonth,
        ),
      );
      return;
    }

    final month = _selectedMonth ?? DateTime.now();
    try {
      final results = await Future.wait([
        _getLeaves(employeeId, month: month.month, year: month.year),
        _getCompOffRequests(employeeId),
      ]);
      if (isClosed) return;
      final leaves = results[0] as EmployeeLeaves;
      _all = LeaveUiMapper.toUiList(leaves.records);
      _stats = LeaveUiMapper.toStats(leaves.stats);
      _compOffRequests = results[1] as CompOffRequests;
      _emitFiltered();
    } on LeaveFailure catch (e) {
      if (isClosed) return;
      emit(
        LeavesFailureState(
          e.message,
          leaves: keepExisting ? state.leaves : const [],
          allLeaves: keepExisting ? _all : const [],
          stats: keepExisting ? _stats : LeaveStatsUiModel.empty,
          compOffRequests: keepExisting
              ? _compOffRequests
              : CompOffRequests.empty,
          search: _search,
          selectedDate: _selectedDate,
          selectedMonth: _selectedMonth,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        LeavesFailureState(
          'Failed to load leaves. Please try again.',
          leaves: keepExisting ? state.leaves : const [],
          allLeaves: keepExisting ? _all : const [],
          stats: keepExisting ? _stats : LeaveStatsUiModel.empty,
          compOffRequests: keepExisting
              ? _compOffRequests
              : CompOffRequests.empty,
          search: _search,
          selectedDate: _selectedDate,
          selectedMonth: _selectedMonth,
        ),
      );
    }
  }

  void setSearch(String value) {
    _search = value;
    _emitFiltered();
  }

  void setSelectedDate(DateTime? value) {
    _selectedDate = value == null
        ? null
        : DateTime(value.year, value.month, value.day);
    _emitFiltered();
  }

  void setSelectedMonth(DateTime? value) {
    _selectedMonth = value == null ? null : DateTime(value.year, value.month);
    _emitFiltered();
    load(keepExisting: true);
  }

  Future<List<ExtraWorkedDay>> loadExtraWorkedDays() async {
    final employeeId =
        AuthSession.currentEmployee?.employeeId ??
        (await AuthSession.load())?.employeeId ??
        '';
    if (employeeId.isEmpty) {
      throw const LeaveFailure('Employee ID missing. Please login again.');
    }
    return _getExtraWorkedDays(employeeId);
  }

  Future<void> applyLeave({
    required String leaveType,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) async {
    final employee = AuthSession.currentEmployee ?? await AuthSession.load();
    final employeeId = employee?.employeeId ?? '';
    if (employeeId.isEmpty) {
      throw const LeaveFailure('Employee ID missing. Please login again.');
    }

    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    if (end.isBefore(start)) {
      throw const LeaveFailure('End date cannot be before start date.');
    }

    final days = end.difference(start).inDays + 1;
    final type = leaveType.trim().toLowerCase();

    await _addLeave(
      AddLeaveParams(
        employeeId: employeeId,
        employeeName: employee?.displayName ?? employeeId,
        leaveType: type,
        startDate: start,
        endDate: end,
        days: days,
        reason: reason.trim(),
      ),
    );

    await load(keepExisting: true);
  }

  Future<void> applyCompOff({
    required DateTime workDate,
    required DateTime leaveDate,
    required int days,
    required String reason,
    String? workType,
    double? totalHours,
  }) async {
    final employee = AuthSession.currentEmployee ?? await AuthSession.load();
    final employeeId = employee?.employeeId ?? '';
    if (employeeId.isEmpty) {
      throw const LeaveFailure('Employee ID missing. Please login again.');
    }
    if (days <= 0) {
      throw const LeaveFailure('Please enter valid total days.');
    }

    await _addCompOff(
      AddCompOffParams(
        employeeId: employeeId,
        employeeName: employee?.displayName ?? employeeId,
        workDate: DateTime(workDate.year, workDate.month, workDate.day),
        leaveDate: DateTime(leaveDate.year, leaveDate.month, leaveDate.day),
        days: days,
        reason: reason.trim(),
        workType: workType,
        totalHours: totalHours,
      ),
    );

    try {
      await load(keepExisting: true);
    } catch (_) {}
  }

  void _emitFiltered() {
    emit(
      LeavesLoaded(
        leaves: _applyFilters(_all),
        allLeaves: _all,
        stats: _stats,
        compOffRequests: _compOffRequests,
        search: _search,
        selectedDate: _selectedDate,
        selectedMonth: _selectedMonth,
      ),
    );
  }

  List<LeaveHistoryUiModel> _applyFilters(List<LeaveHistoryUiModel> source) {
    final q = _search.trim().toLowerCase();
    return source.where((l) {
      final hay = '${l.type} ${l.status} ${l.note} ${l.footer} ${l.range}'
          .toLowerCase();
      final matchesSearch = q.isEmpty || hay.contains(q);
      final matchesDate =
          _selectedDate == null || _includesDate(l, _selectedDate!);
      final matchesMonth =
          _selectedMonth == null || _overlapsMonth(l, _selectedMonth!);
      return matchesSearch && matchesDate && matchesMonth;
    }).toList();
  }

  bool _includesDate(LeaveHistoryUiModel leave, DateTime date) {
    final start = leave.startDate;
    final end = leave.endDate ?? start;
    if (start == null || end == null) return false;
    final day = DateTime(date.year, date.month, date.day);
    final first = DateTime(start.year, start.month, start.day);
    final last = DateTime(end.year, end.month, end.day);
    return !day.isBefore(first) && !day.isAfter(last);
  }

  bool _overlapsMonth(LeaveHistoryUiModel leave, DateTime month) {
    final start = leave.startDate;
    final end = leave.endDate ?? start;
    if (start == null || end == null) return false;
    final firstDay = DateTime(month.year, month.month);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final leaveStart = DateTime(start.year, start.month, start.day);
    final leaveEnd = DateTime(end.year, end.month, end.day);
    return !leaveEnd.isBefore(firstDay) && !leaveStart.isAfter(lastDay);
  }
}
