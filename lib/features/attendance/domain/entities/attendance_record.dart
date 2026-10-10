class AttendanceRecord {
  const AttendanceRecord({
    required this.id,
    required this.employeeId,
    required this.name,
    required this.employeeEmail,
    required this.checkInTime,
    required this.status,
    required this.totalBreakMinutes,
    required this.totalHours,
    required this.workingHours,
    required this.assignedShiftHours,
    required this.otHours,
    required this.otAmount,
    required this.otMultiplier,
    required this.latitude,
    required this.longitude,
    required this.distance,
    required this.onsite,
    required this.officeName,
    required this.reason,
    required this.comment,
    this.checkOutTime,
  });

  final String id;
  final String employeeId;
  final String name;
  final String employeeEmail;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final String status;
  final double totalBreakMinutes;
  final double totalHours;
  final double workingHours;
  final double assignedShiftHours;
  final double otHours;
  final double otAmount;
  final double otMultiplier;
  final double latitude;
  final double longitude;
  final double distance;
  final bool onsite;
  final String officeName;
  final String reason;
  final String comment;

  bool get isCheckedIn => status.toLowerCase() == 'checked-in';
}

class AttendanceStats {
  const AttendanceStats({
    required this.totalRecords,
    required this.onsiteDays,
    required this.checkedIn,
    required this.fullDays,
    required this.otHours,
    required this.otHoursFormatted,
    required this.claimedOt,
  });

  final int totalRecords;
  final int onsiteDays;
  final int checkedIn;
  final int fullDays;
  final double otHours;
  final String otHoursFormatted;
  final int claimedOt;
}

class MyAttendanceResult {
  const MyAttendanceResult({
    required this.employeeName,
    required this.records,
    this.claimedAttendanceIds = const {},
    this.stats,
  });

  final String employeeName;
  final List<AttendanceRecord> records;
  final Set<String> claimedAttendanceIds;
  final AttendanceStats? stats;
}
