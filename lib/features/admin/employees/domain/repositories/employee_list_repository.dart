import 'package:timelay_health/features/admin/employees/presentation/models/employee_list_ui.dart';

abstract class EmployeeListRepository {
  Future<EmployeeListUi> getEmployees();
}
