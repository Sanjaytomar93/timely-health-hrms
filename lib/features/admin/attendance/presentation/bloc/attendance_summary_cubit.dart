import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelay_health/features/admin/attendance/data/repositories_impl/attendance_summary_repository_impl.dart';
import 'package:timelay_health/features/admin/attendance/domain/failures/attendance_summary_failure.dart';
import 'package:timelay_health/features/admin/attendance/domain/usecases/get_attendance_summary_usecase.dart';
import 'package:timelay_health/features/admin/attendance/presentation/bloc/attendance_summary_state.dart';

class AttendanceSummaryCubit extends Cubit<AttendanceSummaryState> {
  AttendanceSummaryCubit({
    GetAttendanceSummaryUseCase? useCase,
    String? initialMonth,
  })  : _useCase = useCase ??
            GetAttendanceSummaryUseCase(AttendanceSummaryRepositoryImpl()),
        _currentMonth = initialMonth ?? _defaultMonth(),
        super(AttendanceSummaryInitial(month: initialMonth ?? _defaultMonth()));

  final GetAttendanceSummaryUseCase _useCase;
  String _currentMonth;

  static String _defaultMonth() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  String get currentMonth => _currentMonth;

  Future<void> load({String? month, bool isRefresh = false}) async {
    final targetMonth = month ?? _currentMonth;
    _currentMonth = targetMonth;

    final currentUi = state.ui;
    emit(AttendanceSummaryLoading(
      month: targetMonth,
      currentUi: isRefresh ? currentUi : null,
    ));

    try {
      final ui = await _useCase(month: targetMonth);
      if (isClosed) return;
      emit(AttendanceSummaryLoaded(ui: ui, month: targetMonth));
    } on AttendanceSummaryFailure catch (e) {
      if (isClosed) return;
      emit(AttendanceSummaryFailureState(
        e.message,
        month: targetMonth,
        currentUi: currentUi.roster.isNotEmpty ? currentUi : null,
      ));
    } catch (_) {
      if (isClosed) return;
      emit(AttendanceSummaryFailureState(
        'Failed to load attendance summary. Please try again.',
        month: targetMonth,
        currentUi: currentUi.roster.isNotEmpty ? currentUi : null,
      ));
    }
  }
}
