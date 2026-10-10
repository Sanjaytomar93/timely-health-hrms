class CheckInParams {
  const CheckInParams({
    required this.employeeId,
    required this.employeeEmail,
    required this.latitude,
    required this.longitude,
    this.reason,
    this.imagePath,
  });

  final String employeeId;
  final String employeeEmail;
  final double latitude;
  final double longitude;
  final String? reason;
  final String? imagePath;

  bool get hasImage => imagePath != null && imagePath!.trim().isNotEmpty;
}

class CheckOutParams {
  const CheckOutParams({
    required this.employeeId,
    required this.latitude,
    required this.longitude,
    this.employeeEmail = '',
    this.reason,
    this.imagePath,
  });

  final String employeeId;
  final String employeeEmail;
  final double latitude;
  final double longitude;
  final String? reason;
  final String? imagePath;

  bool get hasImage => imagePath != null && imagePath!.trim().isNotEmpty;
}
