import 'package:timelay_health/features/attendance/domain/entities/attendance_record.dart';
import 'package:timelay_health/features/attendance/domain/entities/check_in_params.dart';
import 'package:timelay_health/features/attendance/domain/entities/check_in_result.dart';
import 'package:timelay_health/features/attendance/domain/entities/employee_location_assignment.dart';
import 'package:timelay_health/features/attendance/domain/entities/employee_shift.dart';
import 'package:timelay_health/features/attendance/domain/entities/ot_claim_params.dart';

abstract class AttendanceRepository {
  Future<MyAttendanceResult> getMyAttendance({required String employeeId});

  Future<EmployeeShift> getMyShift({required String employeeId});

  Future<EmployeeLocationAssignment> getMyLocation({
    required String employeeId,
  });

  Future<List<EmployeeLocationAssignment>> getAllLocations();

  Future<CheckInResult> checkIn(CheckInParams params);

  Future<CheckOutResult> checkOut(CheckOutParams params);

  Future<String> claimOt(OtClaimParams params);
}
