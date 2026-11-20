import 'package:timelay_health/features/admin/attendance/data/datasources/late_today_remote_datasource.dart';
import 'package:timelay_health/features/admin/attendance/domain/repositories/late_today_repository.dart';
import 'package:timelay_health/features/admin/attendance/presentation/models/late_today_ui.dart';
import 'package:timelay_health/features/admin/employees/data/datasources/employee_list_remote_datasource.dart';

class LateTodayRepositoryImpl implements LateTodayRepository {
  LateTodayRepositoryImpl({
    LateTodayRemoteDataSource? remote,
    EmployeeListRemoteDataSource? employeeRemote,
  })  : _remote = remote ?? LateTodayRemoteDataSource(),
        _employeeRemote = employeeRemote ?? EmployeeListRemoteDataSource();

  final LateTodayRemoteDataSource _remote;
  final EmployeeListRemoteDataSource _employeeRemote;

  Future<Map<String, Map<String, dynamic>>> _getEmployeeMap() async {
    try {
      final list = await _employeeRemote.getEmployees();
      final map = <String, Map<String, dynamic>>{};
      for (final e in list) {
        final id = (e['employeeId'] ?? e['id'] ?? '').toString().trim().toLowerCase();
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
  Future<LateTodayUi> getLateRecords({
    String? date,
    String? month,
  }) async {
    final data = await _remote.getLateToday(date: date, month: month);
    final empMap = await _getEmployeeMap();

    return LateTodayUi.fromJson(
      data,
      employeeMap: empMap,
      selectedDateString: date,
    );
  }
}
