import 'package:timelay_health/features/admin/employees/domain/repositories/employee_list_repository.dart';
import 'package:timelay_health/features/admin/employees/presentation/models/employee_list_ui.dart';

class GetEmployeeListUseCase {
  const GetEmployeeListUseCase(this._repository);

  final EmployeeListRepository _repository;

  Future<EmployeeListUi> call() => _repository.getEmployees();
}
