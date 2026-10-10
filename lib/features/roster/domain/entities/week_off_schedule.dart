class WeekOffSchedule {
  const WeekOffSchedule({
    required this.employeeId,
    required this.month,
    required this.totalWeekOffs,
    required this.dates,
    required this.selectionMode,
    required this.weekOffDays,
    required this.source,
  });

  final String employeeId;
  final DateTime month;
  final int totalWeekOffs;
  final List<DateTime> dates;
  final String selectionMode;
  final List<String> weekOffDays;
  final String source;

  bool get isWeekly => selectionMode.toLowerCase() == 'weekly';
}
