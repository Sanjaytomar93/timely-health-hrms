class EmployeeShift {
  const EmployeeShift({
    required this.id,
    required this.shiftType,
    required this.shiftName,
    required this.shiftCategory,
    required this.isBrakeShift,
    required this.isAssigned,
    required this.startTime,
    required this.endTime,
    required this.timeRange,
    required this.description,
    required this.assignedDate,
    this.effectiveFrom,
    this.scheduledChange,
  });

  final String id;
  final String shiftType;
  final String shiftName;
  final String shiftCategory;
  final bool isBrakeShift;
  final bool isAssigned;
  final String startTime;
  final String endTime;
  final String timeRange;
  final String description;
  final DateTime? assignedDate;
  final DateTime? effectiveFrom;
  final ScheduledShiftChange? scheduledChange;

  String get displayTiming {
    final range = timeRange.trim();
    if (range.isNotEmpty) {
      return range.replaceAll(' - ', ' – ');
    }
    final start = startTime.trim();
    final end = endTime.trim();
    if (start.isNotEmpty && end.isNotEmpty) return '$start – $end';
    if (start.isNotEmpty) return start;
    return '';
  }
}

class ScheduledShiftChange {
  const ScheduledShiftChange({
    required this.shiftType,
    required this.shiftName,
    required this.timeRange,
    this.effectiveFrom,
  });

  final String shiftType;
  final String shiftName;
  final String timeRange;
  final DateTime? effectiveFrom;
}
