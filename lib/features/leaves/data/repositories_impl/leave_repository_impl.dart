import 'package:timelay_health/features/leaves/data/datasources/leave_remote_datasource.dart';
import 'package:timelay_health/features/leaves/data/mappers/leave_mapper.dart';
import 'package:timelay_health/features/leaves/domain/entities/employee_leaves.dart';
import 'package:timelay_health/features/leaves/domain/entities/leave_record.dart';
import 'package:timelay_health/features/leaves/domain/entities/comp_off_request.dart';
import 'package:timelay_health/features/leaves/domain/repositories/leave_repository.dart';

class LeaveRepositoryImpl implements LeaveRepository {
  LeaveRepositoryImpl({LeaveRemoteDataSource? remoteDataSource})
    : _remote = remoteDataSource ?? LeaveRemoteDataSource();

  final LeaveRemoteDataSource _remote;

  @override
  Future<EmployeeLeaves> getEmployeeLeaves({
    required String employeeId,
    required int month,
    required int year,
  }) async {
    final model = await _remote.getEmployeeLeaves(
      employeeId: employeeId,
      month: month,
      year: year,
    );
    return LeaveMapper.employeeLeavesToEntity(model);
  }

  @override
  Future<CompOffRequests> getCompOffRequests({
    required String employeeId,
  }) async {
    final model = await _remote.getCompOffRequests(employeeId: employeeId);
    return LeaveMapper.compOffRequestsToEntity(model);
  }

  @override
  Future<LeaveRecord> addLeave(AddLeaveParams params) async {
    final model = await _remote.addLeave(params);
    return LeaveMapper.toEntity(model);
  }
}
