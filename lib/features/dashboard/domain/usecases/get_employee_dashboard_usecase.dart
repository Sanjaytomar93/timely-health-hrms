import 'package:timelay_health/features/dashboard/domain/entities/employee_dashboard.dart';
import 'package:timelay_health/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetEmployeeDashboardUseCase {
  const GetEmployeeDashboardUseCase(this._repository);
  final DashboardRepository _repository;

  Future<EmployeeDashboard> call(
    String employeeId, {
    required int month,
    required int year,
  }) {
    return _repository.getEmployeeDashboard(
      employeeId: employeeId,
      month: month,
      year: year,
    );
  }

  Future<EmployeeDashboard> attachMyShift(
    EmployeeDashboard dashboard,
    String employeeId,
  ) {
    return _repository.attachMyShift(
      dashboard: dashboard,
      employeeId: employeeId,
    );
  }
}
