class LeaveRecord {
  const LeaveRecord({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.leaveType,
    required this.days,
    required this.reason,
    required this.status,
    required this.isConvertedToCompOff,
    this.startDate,
    this.endDate,
    this.appliedDate,
    this.approvedBy,
    this.approvedByRole,
    this.approvedDate,
  });

  final String id;
  final String employeeId;
  final String employeeName;
  final String leaveType;
  final DateTime? startDate;
  final DateTime? endDate;
  final double days;
  final String reason;
  final String status;
  final bool isConvertedToCompOff;
  final DateTime? appliedDate;
  final String? approvedBy;
  final String? approvedByRole;
  final DateTime? approvedDate;
}

class AddLeaveParams {
  const AddLeaveParams({
    required this.employeeId,
    required this.employeeName,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.days,
    required this.reason,
  });

  final String employeeId;
  final String employeeName;
  final String leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final int days;
  final String reason;
}
