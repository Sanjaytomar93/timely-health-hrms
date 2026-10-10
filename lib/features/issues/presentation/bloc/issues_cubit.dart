import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelay_health/features/auth/data/auth_session.dart';
import 'package:timelay_health/features/issues/data/repositories_impl/issue_repository_impl.dart';
import 'package:timelay_health/features/issues/domain/entities/issue.dart';
import 'package:timelay_health/features/issues/domain/failures/issue_failure.dart';
import 'package:timelay_health/features/issues/domain/usecases/delete_issue_usecase.dart';
import 'package:timelay_health/features/issues/domain/usecases/get_my_issues_usecase.dart';
import 'package:timelay_health/features/issues/domain/usecases/raise_issue_usecase.dart';
import 'package:timelay_health/features/issues/domain/usecases/update_issue_usecase.dart';
import 'package:timelay_health/features/issues/presentation/bloc/issues_state.dart';
import 'package:timelay_health/features/issues/presentation/models/issue_ui_model.dart';

class IssuesCubit extends Cubit<IssuesState> {
  IssuesCubit({
    GetMyIssuesUseCase? getMyIssuesUseCase,
    RaiseIssueUseCase? raiseIssueUseCase,
    UpdateIssueUseCase? updateIssueUseCase,
    DeleteIssueUseCase? deleteIssueUseCase,
  }) : _getMyIssues =
           getMyIssuesUseCase ?? GetMyIssuesUseCase(IssueRepositoryImpl()),
       _raiseIssue =
           raiseIssueUseCase ?? RaiseIssueUseCase(IssueRepositoryImpl()),
       _updateIssue =
           updateIssueUseCase ?? UpdateIssueUseCase(IssueRepositoryImpl()),
       _deleteIssue =
           deleteIssueUseCase ?? DeleteIssueUseCase(IssueRepositoryImpl()),
       super(const IssuesInitial());

  final GetMyIssuesUseCase _getMyIssues;
  final RaiseIssueUseCase _raiseIssue;
  final UpdateIssueUseCase _updateIssue;
  final DeleteIssueUseCase _deleteIssue;

  List<IssueUiModel> _all = const [];
  String _search = '';
  String _priority = 'All';
  String _status = 'All Status';
  String _type = 'All';

  Future<void> load({bool keepExisting = false}) async {
    emit(
      IssuesLoading(
        issues: keepExisting ? state.issues : const [],
        allIssues: keepExisting ? _all : const [],
        search: _search,
        priority: _priority,
        status: _status,
        type: _type,
      ),
    );

    final employeeId =
        AuthSession.currentEmployee?.employeeId ??
        (await AuthSession.load())?.employeeId ??
        '';

    if (isClosed) return;

    if (employeeId.isEmpty) {
      emit(
        IssuesFailureState(
          'Employee ID missing. Please login again.',
          issues: keepExisting ? state.issues : const [],
          allIssues: keepExisting ? _all : const [],
          search: _search,
          priority: _priority,
          status: _status,
          type: _type,
        ),
      );
      return;
    }

    try {
      final issues = await _getMyIssues(employeeId);
      if (isClosed) return;
      _all = IssueUiMapper.toUiList(issues);
      _emitFiltered();
    } on IssueFailure catch (e) {
      if (isClosed) return;
      emit(
        IssuesFailureState(
          e.message,
          issues: keepExisting ? state.issues : const [],
          allIssues: keepExisting ? _all : const [],
          search: _search,
          priority: _priority,
          status: _status,
          type: _type,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        IssuesFailureState(
          'Failed to load issues. Please try again.',
          issues: keepExisting ? state.issues : const [],
          allIssues: keepExisting ? _all : const [],
          search: _search,
          priority: _priority,
          status: _status,
          type: _type,
        ),
      );
    }
  }

  void setSearch(String value) {
    _search = value;
    _emitFiltered();
  }

  void setPriority(String value) {
    _priority = value;
    _emitFiltered();
  }

  void setStatus(String value) {
    _status = value;
    _emitFiltered();
  }

  void setType(String value) {
    _type = value;
    _emitFiltered();
  }

  void resetFilters() {
    _search = '';
    _priority = 'All';
    _status = 'All Status';
    _type = 'All';
    _emitFiltered();
  }

  Future<void> raiseIssue({
    required String employeeName,
    required String department,
    required String issueTitle,
    required String issueDescription,
    required String issueType,
    required String priority,
  }) async {
    final employeeId =
        AuthSession.currentEmployee?.employeeId ??
        (await AuthSession.load())?.employeeId ??
        '';

    if (isClosed) return;
    if (employeeId.isEmpty) {
      throw const IssueFailure('Employee ID missing. Please login again.');
    }

    emit(
      IssuesActionBusy(
        issues: state.issues,
        allIssues: _all,
        search: _search,
        priority: _priority,
        status: _status,
        type: _type,
      ),
    );

    try {
      await _raiseIssue(
        RaiseIssueParams(
          employeeId: employeeId,
          employeeName: employeeName.trim(),
          department: department.trim(),
          issueTitle: issueTitle.trim(),
          issueDescription: issueDescription.trim(),
          issueType: issueType.trim(),
          priority: priority.trim(),
        ),
      );
      if (isClosed) return;
      await load(keepExisting: true);
    } catch (e) {
      if (isClosed) return;
      _emitFiltered();
      rethrow;
    }
  }

  Future<void> updateIssue({
    required String issueId,
    required String employeeName,
    required String department,
    required String issueTitle,
    required String issueDescription,
    required String issueType,
    required String priority,
  }) async {
    final employeeId =
        AuthSession.currentEmployee?.employeeId ??
        (await AuthSession.load())?.employeeId ??
        '';
    if (isClosed) return;
    if (employeeId.isEmpty) {
      throw const IssueFailure('Employee ID missing. Please login again.');
    }

    emit(
      IssuesActionBusy(
        issues: state.issues,
        allIssues: _all,
        search: _search,
        priority: _priority,
        status: _status,
        type: _type,
      ),
    );

    try {
      await _updateIssue(
        issueId: issueId,
        params: RaiseIssueParams(
          employeeId: employeeId,
          employeeName: employeeName.trim(),
          department: department.trim(),
          issueTitle: issueTitle.trim(),
          issueDescription: issueDescription.trim(),
          issueType: issueType.trim(),
          priority: priority.trim(),
        ),
      );
      if (isClosed) return;
      await load(keepExisting: true);
    } catch (e) {
      if (isClosed) return;
      _emitFiltered();
      rethrow;
    }
  }

  Future<void> deleteIssue(String issueId) async {
    emit(
      IssuesActionBusy(
        issues: state.issues,
        allIssues: _all,
        search: _search,
        priority: _priority,
        status: _status,
        type: _type,
      ),
    );

    try {
      await _deleteIssue(issueId);
      if (isClosed) return;
      _all = _all.where((e) => e.id != issueId).toList();
      _emitFiltered();
    } catch (e) {
      if (isClosed) return;
      _emitFiltered();
      rethrow;
    }
  }

  void _emitFiltered() {
    emit(
      IssuesLoaded(
        issues: _applyFilters(_all),
        allIssues: _all,
        search: _search,
        priority: _priority,
        status: _status,
        type: _type,
      ),
    );
  }

  List<IssueUiModel> _applyFilters(List<IssueUiModel> source) {
    final q = _search.trim().toLowerCase();
    return source.where((issue) {
      if (q.isNotEmpty) {
        final hay =
            '${issue.title} ${issue.description} ${issue.issueType} ${issue.status}'
                .toLowerCase();
        if (!hay.contains(q)) return false;
      }
      if (_priority != 'All' &&
          issue.priority.toLowerCase() != _priority.toLowerCase()) {
        return false;
      }
      if (_status != 'All Status' &&
          issue.status.toLowerCase() != _status.toLowerCase()) {
        return false;
      }
      if (_type != 'All' &&
          issue.issueType.toLowerCase() != _type.toLowerCase()) {
        return false;
      }
      return true;
    }).toList();
  }
}
