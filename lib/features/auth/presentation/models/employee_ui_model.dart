class EmployeeUiModel {
  const EmployeeUiModel({
    required this.id,
    required this.employeeId,
    required this.displayName,
    required this.email,
    required this.role,
    required this.department,
    required this.initials,
    this.phone,
    this.status,
    this.joinDateLabel,
  });

  final String id;
  final String employeeId;
  final String displayName;
  final String email;
  final String role;
  final String department;
  final String initials;
  final String? phone;
  final String? status;
  final String? joinDateLabel;
}
