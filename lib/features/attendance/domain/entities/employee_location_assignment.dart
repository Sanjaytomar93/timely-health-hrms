class EmployeeLocationAssignment {
  const EmployeeLocationAssignment({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.isActive,
    required this.fullAddress,
    required this.assignedEmployeesCount,
  });

  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final bool isActive;
  final String fullAddress;
  final int assignedEmployeesCount;
}
