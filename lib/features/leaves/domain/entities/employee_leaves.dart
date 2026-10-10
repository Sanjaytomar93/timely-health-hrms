import 'package:timelay_health/features/leaves/domain/entities/leave_record.dart';

class LeaveStats {
  const LeaveStats({
    required this.totalLeaves,
    required this.approvedLeaves,
    required this.pendingLeaves,
    required this.rejectedLeaves,
    required this.casualLeaves,
    required this.sickLeaves,
    required this.earnedLeaves,
    required this.compOffLeaves,
    required this.weekOffPerMonth,
    required this.totalAssignedDays,
    required this.presentDays,
    required this.absentDays,
    required this.extraDaysWorked,
  });

  final int totalLeaves;
  final int approvedLeaves;
  final int pendingLeaves;
  final int rejectedLeaves;
  final int casualLeaves;
  final int sickLeaves;
  final int earnedLeaves;
  final int compOffLeaves;
  final int weekOffPerMonth;
  final int totalAssignedDays;
  final int presentDays;
  final int absentDays;
  final int extraDaysWorked;
}

class EmployeeLeaves {
  const EmployeeLeaves({required this.stats, required this.records});

  final LeaveStats stats;
  final List<LeaveRecord> records;
}
