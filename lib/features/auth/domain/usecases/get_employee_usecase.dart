import 'package:timelay_health/features/auth/domain/entities/employee.dart';
import 'package:timelay_health/features/auth/domain/repositories/auth_repository.dart';

class GetEmployeeUseCase {
  const GetEmployeeUseCase(this._repository);

  final AuthRepository _repository;

  Future<Employee> call(String employeeId) {
    return _repository.getEmployee(employeeId: employeeId);
  }
}
