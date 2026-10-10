import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelay_health/features/attendance/data/repositories_impl/attendance_repository_impl.dart';
import 'package:timelay_health/features/attendance/domain/failures/attendance_failure.dart';
import 'package:timelay_health/features/attendance/domain/usecases/get_my_shift_usecase.dart';
import 'package:timelay_health/features/attendance/presentation/bloc/shift_state.dart';
import 'package:timelay_health/features/attendance/presentation/models/shift_ui_model.dart';
import 'package:timelay_health/features/auth/data/auth_session.dart';

class ShiftCubit extends Cubit<ShiftState> {
  ShiftCubit({GetMyShiftUseCase? getMyShiftUseCase})
    : _getMyShift =
          getMyShiftUseCase ?? GetMyShiftUseCase(AttendanceRepositoryImpl()),
      super(const ShiftInitial());

  final GetMyShiftUseCase _getMyShift;

  Future<void> load({bool keepExisting = false}) async {
    emit(
      ShiftLoading(
        shift: keepExisting ? state.shift : null,
        stats: keepExisting ? state.stats : ShiftStatsUiModel.empty,
        headerDate: keepExisting ? state.headerDate : '',
      ),
    );

    final employeeId =
        AuthSession.currentEmployee?.employeeId ??
        (await AuthSession.load())?.employeeId ??
        '';

    if (isClosed) return;

    if (employeeId.isEmpty) {
      emit(
        ShiftFailureState(
          'Employee ID missing. Please login again.',
          shift: keepExisting ? state.shift : null,
          stats: keepExisting ? state.stats : ShiftStatsUiModel.empty,
          headerDate: keepExisting ? state.headerDate : '',
        ),
      );
      return;
    }

    try {
      final shift = await _getMyShift(employeeId);
      if (isClosed) return;
      emit(
        ShiftLoaded(
          shift: ShiftUiMapper.toUi(shift),
          stats: ShiftUiMapper.toStats(shift),
          headerDate: ShiftUiMapper.headerDateLabel(shift.assignedDate),
        ),
      );
    } on AttendanceFailure catch (e) {
      if (isClosed) return;
      emit(
        ShiftFailureState(
          e.message,
          shift: keepExisting ? state.shift : null,
          stats: keepExisting ? state.stats : ShiftStatsUiModel.empty,
          headerDate: keepExisting ? state.headerDate : '',
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        ShiftFailureState(
          'Failed to load shift. Please try again.',
          shift: keepExisting ? state.shift : null,
          stats: keepExisting ? state.stats : ShiftStatsUiModel.empty,
          headerDate: keepExisting ? state.headerDate : '',
        ),
      );
    }
  }
}
