class OtClaimItem {
  const OtClaimItem({
    required this.attendanceId,
    required this.date,
    required this.otHours,
  });

  final String attendanceId;
  final DateTime? date;
  final double otHours;
}

class OtClaimParams {
  const OtClaimParams({
    required this.employeeId,
    required this.employeeName,
    required this.items,
    required this.reason,
  });

  final String employeeId;
  final String employeeName;
  final List<OtClaimItem> items;
  final String reason;

  double get totalOtHours =>
      items.fold<double>(0, (sum, item) => sum + item.otHours);
}
