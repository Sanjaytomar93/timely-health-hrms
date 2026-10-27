class Letter {
  const Letter({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.letterType,
    required this.designation,
    required this.department,
    required this.joiningDate,
    required this.relievingDate,
    required this.status,
    required this.fileUrl,
    this.sentAt,
    this.details = '',
  });

  final String id;
  final String employeeId;
  final String employeeName;
  final String letterType;
  final String designation;
  final String department;
  final String joiningDate;
  final String relievingDate;
  final String status;
  final String fileUrl;
  final DateTime? sentAt;
  final String details;
}
