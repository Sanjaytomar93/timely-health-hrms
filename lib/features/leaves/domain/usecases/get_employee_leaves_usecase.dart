import 'package:timelay_health/features/leaves/domain/entities/employee_leaves.dart';
import 'package:timelay_health/features/leaves/domain/repositories/leave_repository.dart';

class GetEmployeeLeavesUseCase {
  const GetEmployeeLeavesUseCase(this._repository);
  final LeaveRepository _repository;

  Future<EmployeeLeaves> call(
    String employeeId, {
    required int month,
    required int year,
  }) {
    return _repository.getEmployeeLeaves(
      employeeId: employeeId,
      month: month,
      year: year,
    );
  }
}
