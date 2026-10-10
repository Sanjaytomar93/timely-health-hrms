class DashboardAttendanceItem {
  const DashboardAttendanceItem({
    required this.id,
    required this.status,
    required this.dayType,
    required this.totalHours,
    required this.workingHours,
    required this.onsite,
    required this.officeName,
    required this.reason,
    this.checkInTime,
    this.checkOutTime,
  });

  final String id;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final String status;
  final String dayType;
  final double totalHours;
  final double workingHours;
  final bool onsite;
  final String officeName;
  final String reason;

  bool get isCheckedIn => status.toLowerCase() == 'checked-in';

  bool get isLeaveDay {
    final t = dayType.toLowerCase();
    return t.contains('leave') || status.toLowerCase() == 'comp-off';
  }

  double get effectiveHours => workingHours > 0 ? workingHours : totalHours;
}

class DashboardLeaveItem {
  const DashboardLeaveItem({
    required this.id,
    required this.leaveType,
    required this.status,
    required this.days,
    required this.reason,
    this.startDate,
    this.endDate,
    this.employeeName,
  });

  final String id;
  final String leaveType;
  final String status;
  final double days;
  final String reason;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? employeeName;
}

class DashboardShiftInfo {
  const DashboardShiftInfo({
    required this.shiftTiming,
    this.upcomingShiftLabel,
  });

  final String shiftTiming;
  final String? upcomingShiftLabel;

  static const empty = DashboardShiftInfo(shiftTiming: 'Not Assigned');
}

class DashboardPersonEvent {
  const DashboardPersonEvent({required this.name, this.detail});

  final String name;
  final String? detail;
}

class DashboardStats {
  const DashboardStats({
    this.present = 0,
    this.absent = 0,
    this.late = 0,
    this.totalWorkingDays = 0,
    this.attendanceRate = 0,
  });

  final int present;
  final int absent;
  final int late;
  final int totalWorkingDays;
  final int attendanceRate;
}

class DashboardAbsentWeek {
  const DashboardAbsentWeek({
    required this.week,
    this.startDate,
    this.endDate,
    this.workingDays = 0,
    this.absentDays = 0,
  });

  final int week;
  final DateTime? startDate;
  final DateTime? endDate;
  final int workingDays;
  final int absentDays;
}

class DashboardAbsentGraph {
  const DashboardAbsentGraph({
    this.periodStart,
    this.periodEnd,
    this.totalAbsent = 0,
    this.totalWorkingDays = 0,
    this.weeks = const [],
  });

  final DateTime? periodStart;
  final DateTime? periodEnd;
  final int totalAbsent;
  final int totalWorkingDays;
  final List<DashboardAbsentWeek> weeks;
}

class EmployeeDashboard {
  const EmployeeDashboard({
    required this.employeeId,
    required this.name,
    required this.firstName,
    required this.lastName,
    required this.department,
    required this.role,
    required this.status,
    required this.location,
    required this.shift,
    required this.attendance,
    required this.leaves,
    required this.birthdaysToday,
    required this.anniversariesToday,
    required this.leavesToday,
    this.assignedWorkingDays = 26,
    this.initials = '?',
    this.stats = const DashboardStats(),
    this.lateGraph = const [],
    this.absentGraph = const DashboardAbsentGraph(),
  });

  final String employeeId;
  final String name;
  final String firstName;
  final String lastName;
  final String department;
  final String role;
  final String status;
  final String location;
  final DashboardShiftInfo shift;
  final List<DashboardAttendanceItem> attendance;
  final List<DashboardLeaveItem> leaves;
  final List<DashboardPersonEvent> birthdaysToday;
  final List<DashboardPersonEvent> anniversariesToday;
  final List<DashboardPersonEvent> leavesToday;
  final int assignedWorkingDays;
  final String initials;
  final DashboardStats stats;
  final List<double> lateGraph;
  final DashboardAbsentGraph absentGraph;

  String get displayFirstName {
    final f = firstName.trim();
    if (f.isNotEmpty) return f;
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.isNotEmpty ? parts.first : 'there';
  }

  String get displayName {
    final n = name.trim();
    if (n.isNotEmpty) return n;
    final parts = [
      firstName,
      lastName,
    ].map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    return parts.isEmpty ? employeeId : parts.join(' ');
  }
}
