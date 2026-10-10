import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelay_health/features/auth/data/auth_session.dart';
import 'package:timelay_health/features/dashboard/data/repositories_impl/dashboard_repository_impl.dart';
import 'package:timelay_health/features/dashboard/domain/entities/employee_dashboard.dart';
import 'package:timelay_health/features/dashboard/domain/failures/dashboard_failure.dart';
import 'package:timelay_health/features/dashboard/domain/usecases/get_employee_dashboard_usecase.dart';
import 'package:timelay_health/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:timelay_health/features/dashboard/presentation/mappers/dashboard_ui_mapper.dart';
import 'package:timelay_health/features/dashboard/presentation/models/dashboard_home_ui.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({GetEmployeeDashboardUseCase? getEmployeeDashboardUseCase})
    : _getDashboard =
          getEmployeeDashboardUseCase ??
          GetEmployeeDashboardUseCase(DashboardRepositoryImpl()),
      super(const DashboardInitial());

  final GetEmployeeDashboardUseCase _getDashboard;

  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime get month => _month;

  Future<void> setMonth(DateTime value) {
    _month = DateTime(value.year, value.month);
    return load(keepExisting: true);
  }

  Future<void> load({bool keepExisting = false}) async {
    emit(DashboardLoading(ui: keepExisting ? state.ui : DashboardHomeUi.empty));

    final employeeId =
        AuthSession.currentEmployee?.employeeId ??
        (await AuthSession.load())?.employeeId ??
        '';

    if (isClosed) return;
    if (employeeId.isEmpty) {
      emit(
        DashboardFailureState(
          'Employee ID missing. Please login again.',
          ui: keepExisting ? state.ui : DashboardHomeUi.empty,
        ),
      );
      return;
    }

    DashboardHomeUi toUi(EmployeeDashboard d) => DashboardUiMapper.toHomeUi(d);

    try {
      final dashboard = await _getDashboard(
        employeeId,
        month: _month.month,
        year: _month.year,
      );
      if (isClosed) return;
      emit(DashboardLoaded(toUi(dashboard)));

      final timing = dashboard.shift.shiftTiming.trim();
      final hasShift = timing.isNotEmpty && timing != 'Not Assigned';
      if (hasShift) return;

      final withShift = await _getDashboard.attachMyShift(
        dashboard,
        employeeId,
      );
      if (isClosed) return;
      final shiftChanged =
          withShift.shift.shiftTiming != dashboard.shift.shiftTiming ||
          withShift.shift.upcomingShiftLabel !=
              dashboard.shift.upcomingShiftLabel;
      if (shiftChanged) {
        emit(DashboardLoaded(toUi(withShift)));
      }
    } on DashboardFailure catch (e) {
      if (isClosed) return;
      emit(
        DashboardFailureState(
          e.message,
          ui: keepExisting ? state.ui : DashboardHomeUi.empty,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        DashboardFailureState(
          'Failed to load dashboard. Please try again.',
          ui: keepExisting ? state.ui : DashboardHomeUi.empty,
        ),
      );
    }
  }
}
