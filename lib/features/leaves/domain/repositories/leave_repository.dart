import 'package:timelay_health/features/leaves/domain/entities/employee_leaves.dart';
import 'package:timelay_health/features/leaves/domain/entities/leave_record.dart';
import 'package:timelay_health/features/leaves/domain/entities/comp_off_request.dart';

abstract class LeaveRepository {
  Future<EmployeeLeaves> getEmployeeLeaves({
    required String employeeId,
    required int month,
    required int year,
  });

  Future<CompOffRequests> getCompOffRequests({required String employeeId});

  Future<LeaveRecord> addLeave(AddLeaveParams params);
}
