import 'package:timelay_health/features/dashboard/domain/entities/employee_performance.dart';
import 'package:timelay_health/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetEmployeePerformanceUseCase {
  const GetEmployeePerformanceUseCase(this._repository);

  final DashboardRepository _repository;

  Future<EmployeePerformance> call({
    required String employeeCode,
    required int month,
    required int year,
  }) {
    return _repository.getEmployeePerformance(
      employeeCode: employeeCode,
      month: month,
      year: year,
    );
  }
}
