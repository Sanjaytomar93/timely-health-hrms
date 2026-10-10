class EmployeePerformance {
  const EmployeePerformance({
    required this.employeeName,
    required this.employeeCode,
    required this.month,
    required this.year,
    required this.presentDays,
    required this.absentDays,
    required this.lateComingDays,
    required this.expectedWorkingHours,
    required this.actualWorkingHours,
    required this.performancePercentage,
  });

  final String employeeName;
  final String employeeCode;
  final int month;
  final int year;
  final int presentDays;
  final int absentDays;
  final int lateComingDays;
  final double expectedWorkingHours;
  final double actualWorkingHours;
  final double performancePercentage;

  String get firstName {
    final name = employeeName.trim();
    if (name.isEmpty) return 'there';
    return name.split(RegExp(r'\s+')).first;
  }

  String get monthLabel {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    if (month < 1 || month > 12) return '';
    return months[month - 1];
  }
}
