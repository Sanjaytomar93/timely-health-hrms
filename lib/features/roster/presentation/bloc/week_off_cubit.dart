import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelay_health/features/auth/data/auth_session.dart';
import 'package:timelay_health/features/roster/data/repositories_impl/roster_repository_impl.dart';
import 'package:timelay_health/features/roster/domain/failures/roster_failure.dart';
import 'package:timelay_health/features/roster/domain/usecases/get_my_week_off_usecase.dart';
import 'package:timelay_health/features/roster/presentation/bloc/week_off_state.dart';
import 'package:timelay_health/features/roster/presentation/models/week_off_ui_model.dart';

class WeekOffCubit extends Cubit<WeekOffState> {
  WeekOffCubit({GetMyWeekOffUseCase? getMyWeekOffUseCase})
    : _getMyWeekOff =
          getMyWeekOffUseCase ?? GetMyWeekOffUseCase(RosterRepositoryImpl()),
      super(WeekOffInitial(month: _monthOf(DateTime.now())));

  final GetMyWeekOffUseCase _getMyWeekOff;

  static DateTime _monthOf(DateTime d) => DateTime(d.year, d.month);

  Future<void> load({DateTime? month}) async {
    final target = _monthOf(month ?? state.month);
    final sameMonth = state.month == target;
    emit(
      WeekOffLoading(month: target, weekOff: sameMonth ? state.weekOff : null),
    );

    final employee = AuthSession.currentEmployee ?? await AuthSession.load();
    if (isClosed || state.month != target) return;

    try {
      final schedule = await _getMyWeekOff(
        employeeId: employee?.employeeId ?? '',
        month: target,
      );
      if (isClosed || state.month != target) return;
      emit(
        WeekOffLoaded(month: target, weekOff: WeekOffUiMapper.toUi(schedule)),
      );
    } on RosterFailure catch (e) {
      if (isClosed || state.month != target) return;
      _emitFailure(e.message, target, employee?.info.weekOffDay ?? '');
    } catch (_) {
      if (isClosed || state.month != target) return;
      _emitFailure(
        'Failed to load week-offs. Please try again.',
        target,
        employee?.info.weekOffDay ?? '',
      );
    }
  }

  void shiftMonth(int delta) =>
      load(month: DateTime(state.month.year, state.month.month + delta));

  void _emitFailure(String message, DateTime month, String profileWeekOff) {
    emit(
      WeekOffFailureState(
        message,
        month: month,
        weekOff: WeekOffUiMapper.fromProfile(profileWeekOff, month),
      ),
    );
  }
}
