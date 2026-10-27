import 'package:timelay_health/features/attendance/data/datasources/attendance_remote_datasource.dart';
import 'package:timelay_health/features/attendance/data/mappers/attendance_mapper.dart';
import 'package:timelay_health/features/attendance/data/mappers/employee_location_mapper.dart';
import 'package:timelay_health/features/attendance/data/mappers/employee_shift_mapper.dart';
import 'package:timelay_health/features/attendance/domain/entities/attendance_record.dart';
import 'package:timelay_health/features/attendance/domain/entities/check_in_params.dart';
import 'package:timelay_health/features/attendance/domain/entities/check_in_result.dart';
import 'package:timelay_health/features/attendance/domain/entities/employee_location_assignment.dart';
import 'package:timelay_health/features/attendance/domain/entities/employee_shift.dart';
import 'package:timelay_health/features/attendance/domain/entities/ot_claim_params.dart';
import 'package:timelay_health/features/attendance/domain/repositories/attendance_repository.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  AttendanceRepositoryImpl({AttendanceRemoteDataSource? remoteDataSource})
    : _remote = remoteDataSource ?? AttendanceRemoteDataSource();

  final AttendanceRemoteDataSource _remote;

  @override
  Future<MyAttendanceResult> getMyAttendance({
    required String employeeId,
  }) async {
    final response = await _remote.getMyAttendance(employeeId: employeeId);
    return AttendanceMapper.toResult(response);
  }

  @override
  Future<EmployeeShift> getMyShift({required String employeeId}) async {
    final model = await _remote.getMyShift(employeeId: employeeId);
    return EmployeeShiftMapper.toEntity(model);
  }

  @override
  Future<EmployeeLocationAssignment> getMyLocation({
    required String employeeId,
  }) async {
    final model = await _remote.getMyLocation(employeeId: employeeId);
    return EmployeeLocationMapper.toEntity(model);
  }

  @override
  Future<List<EmployeeLocationAssignment>> getAllLocations() async {
    final models = await _remote.getAllLocations();
    return models.map(EmployeeLocationMapper.toEntity).toList();
  }

  @override
  Future<CheckInResult> checkIn(CheckInParams params) {
    return _remote.checkIn(params);
  }

  @override
  Future<CheckOutResult> checkOut(CheckOutParams params) {
    return _remote.checkOut(params);
  }

  @override
  Future<String> claimOt(OtClaimParams params) {
    return _remote.claimOt(params);
  }
}
