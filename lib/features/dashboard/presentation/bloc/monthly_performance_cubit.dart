import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelay_health/features/auth/data/auth_session.dart';
import 'package:timelay_health/features/dashboard/data/repositories_impl/dashboard_repository_impl.dart';
import 'package:timelay_health/features/dashboard/domain/usecases/get_employee_performance_usecase.dart';
import 'package:timelay_health/features/dashboard/presentation/bloc/monthly_performance_state.dart';

class MonthlyPerformanceCubit extends Cubit<MonthlyPerformanceState> {
  MonthlyPerformanceCubit({
    GetEmployeePerformanceUseCase? getEmployeePerformance,
  }) : _getPerformance =
           getEmployeePerformance ??
           GetEmployeePerformanceUseCase(DashboardRepositoryImpl()),
       super(const MonthlyPerformanceInitial());

  final GetEmployeePerformanceUseCase _getPerformance;

  Future<void> load() async {
    final employee = AuthSession.currentEmployee ?? await AuthSession.load();
    final code = employee?.performanceCode ?? '';
    if (isClosed) return;
    if (code.isEmpty) {
      emit(const MonthlyPerformanceUnavailable());
      return;
    }

    final alreadyShown = await AuthSession.wasPerformancePopupShown(code);
    if (isClosed || alreadyShown) {
      emit(const MonthlyPerformanceUnavailable());
      return;
    }

    final now = DateTime.now();
    try {
      final review = await _getPerformance(
        employeeCode: code,
        month: now.month,
        year: now.year,
      );
      if (isClosed) return;
      emit(MonthlyPerformanceReady(review));
    } catch (_) {
      if (isClosed) return;
      emit(const MonthlyPerformanceUnavailable());
    }
  }
}
