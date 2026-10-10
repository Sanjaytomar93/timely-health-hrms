class CheckInResult {
  const CheckInResult({
    required this.message,
    required this.employeeName,
    this.checkInTime,
    this.distanceMeters,
    this.onsite = true,
    this.officeName,
    this.reason,
  });

  final String message;
  final String employeeName;
  final DateTime? checkInTime;
  final int? distanceMeters;
  final bool onsite;
  final String? officeName;
  final String? reason;
}

class CheckOutResult {
  const CheckOutResult({
    required this.message,
    required this.employeeName,
    this.checkOutTime,
    this.totalHours,
  });

  final String message;
  final String employeeName;
  final DateTime? checkOutTime;
  final String? totalHours;
}
