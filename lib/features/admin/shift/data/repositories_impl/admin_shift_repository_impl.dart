import 'package:timelay_health/features/admin/employees/data/datasources/employee_list_remote_datasource.dart';
import 'package:timelay_health/features/admin/shift/data/datasources/admin_shift_remote_datasource.dart';
import 'package:timelay_health/features/admin/shift/domain/repositories/admin_shift_repository.dart';
import 'package:timelay_health/features/admin/shift/presentation/models/admin_shift_model.dart';

class AdminShiftRepositoryImpl implements AdminShiftRepository {
  AdminShiftRepositoryImpl({
    AdminShiftRemoteDataSource? remote,
    EmployeeListRemoteDataSource? employeeRemote,
  })  : _remote = remote ?? AdminShiftRemoteDataSource(),
        _employeeRemote = employeeRemote ?? EmployeeListRemoteDataSource();

  final AdminShiftRemoteDataSource _remote;
  final EmployeeListRemoteDataSource _employeeRemote;

  Future<Map<String, Map<String, dynamic>>> _getEmployeeMap() async {
    try {
      final list = await _employeeRemote.getEmployees();
      final map = <String, Map<String, dynamic>>{};
      for (final e in list) {
        final id =
            (e['employeeId'] ?? e['id'] ?? '').toString().trim().toLowerCase();
        if (id.isNotEmpty) {
          map[id] = e;
        }
      }
      return map;
    } catch (_) {
      return const {};
    }
  }

  @override
  Future<AdminShiftUi> getAssignments() async {
    final raw = await _remote.getAssignments();
    final empMap = await _getEmployeeMap();
    return AdminShiftUi.fromJson(raw, employeeMap: empMap);
  }
}
