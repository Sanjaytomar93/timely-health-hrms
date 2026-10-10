import 'package:timelay_health/features/attendance/data/repositories_impl/attendance_repository_impl.dart';
import 'package:timelay_health/features/attendance/domain/entities/employee_shift.dart';
import 'package:timelay_health/features/attendance/domain/usecases/get_my_shift_usecase.dart';
import 'package:timelay_health/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:timelay_health/features/dashboard/data/mappers/dashboard_mapper.dart';
import 'package:timelay_health/features/dashboard/domain/entities/employee_dashboard.dart';
import 'package:timelay_health/features/dashboard/domain/entities/employee_performance.dart';
import 'package:timelay_health/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl({
    DashboardRemoteDataSource? remoteDataSource,
    GetMyShiftUseCase? getMyShiftUseCase,
  }) : _remote = remoteDataSource ?? DashboardRemoteDataSource(),
       _getMyShift =
           getMyShiftUseCase ?? GetMyShiftUseCase(AttendanceRepositoryImpl());

  final DashboardRemoteDataSource _remote;
  final GetMyShiftUseCase _getMyShift;

  @override
  Future<EmployeeDashboard> getEmployeeDashboard({
    required String employeeId,
    required int month,
    required int year,
  }) async {
    final model = await _remote.getEmployeeDashboard(
      employeeId: employeeId,
      month: month,
      year: year,
    );
    return DashboardMapper.toEntity(model);
  }

  @override
  Future<EmployeeDashboard> attachMyShift({
    required EmployeeDashboard dashboard,
    required String employeeId,
  }) async {
    final myShift = await _safeMyShift(employeeId);
    if (myShift == null) return dashboard;

    final timing = myShift.displayTiming;
    final upcoming = _upcomingLabel(myShift);

    final hasBetterTiming =
        timing.isNotEmpty &&
        (dashboard.shift.shiftTiming.trim().isEmpty ||
            dashboard.shift.shiftTiming == 'Not Assigned');

    if (!hasBetterTiming && upcoming == null) return dashboard;

    return EmployeeDashboard(
      employeeId: dashboard.employeeId,
      name: dashboard.name,
      firstName: dashboard.firstName,
      lastName: dashboard.lastName,
      department: dashboard.department,
      role: dashboard.role,
      status: dashboard.status,
      location: dashboard.location,
      shift: DashboardShiftInfo(
        shiftTiming: hasBetterTiming ? timing : dashboard.shift.shiftTiming,
        upcomingShiftLabel: upcoming ?? dashboard.shift.upcomingShiftLabel,
      ),
      attendance: dashboard.attendance,
      leaves: dashboard.leaves,
      birthdaysToday: dashboard.birthdaysToday,
      anniversariesToday: dashboard.anniversariesToday,
      leavesToday: dashboard.leavesToday,
      assignedWorkingDays: dashboard.assignedWorkingDays,
      initials: dashboard.initials,
      stats: dashboard.stats,
      lateGraph: dashboard.lateGraph,
      absentGraph: dashboard.absentGraph,
    );
  }

  @override
  Future<EmployeePerformance> getEmployeePerformance({
    required String employeeCode,
    required int month,
    required int year,
  }) async {
    final model = await _remote.getEmployeePerformance(
      employeeCode: employeeCode,
      month: month,
      year: year,
    );
    return model.toEntity();
  }

  Future<EmployeeShift?> _safeMyShift(String employeeId) async {
    try {
      return await _getMyShift(employeeId);
    } catch (_) {
      return null;
    }
  }

  String? _upcomingLabel(EmployeeShift shift) {
    final change = shift.scheduledChange;
    if (change == null) return null;

    final type = change.shiftType.trim();
    final name = change.shiftName.trim();
    final label = type.isNotEmpty
        ? 'Shift $type'
        : (name.isNotEmpty ? name : 'New shift');
    final date = change.effectiveFrom ?? shift.effectiveFrom;
    if (date == null) return 'Changing to $label';

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final local = date.toLocal();
    final pretty = '${local.day} ${months[local.month - 1]} ${local.year}';
    return 'Changing to $label · $pretty';
  }
}
