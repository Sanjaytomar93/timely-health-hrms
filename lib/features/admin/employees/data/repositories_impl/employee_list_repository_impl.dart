import 'package:timelay_health/features/admin/employees/data/datasources/employee_list_remote_datasource.dart';
import 'package:timelay_health/features/admin/employees/domain/repositories/employee_list_repository.dart';
import 'package:timelay_health/features/admin/employees/presentation/models/employee_list_ui.dart';

class EmployeeListRepositoryImpl implements EmployeeListRepository {
  EmployeeListRepositoryImpl({EmployeeListRemoteDataSource? remote})
      : _remote = remote ?? EmployeeListRemoteDataSource();

  final EmployeeListRemoteDataSource _remote;

  @override
  Future<EmployeeListUi> getEmployees() async {
    final rawData = await _remote.getEmployeeData();

    return EmployeeListUi.fromApiList(
      rawData.employees,
      statsJson: rawData.stats,
    );
  }
}
