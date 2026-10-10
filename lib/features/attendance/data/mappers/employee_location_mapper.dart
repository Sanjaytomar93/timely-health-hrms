import 'package:timelay_health/features/attendance/data/models/employee_location_model.dart';
import 'package:timelay_health/features/attendance/domain/entities/employee_location_assignment.dart';

class EmployeeLocationMapper {
  const EmployeeLocationMapper._();

  static EmployeeLocationAssignment toEntity(
    EmployeeLocationAssignmentModel model,
  ) {
    return EmployeeLocationAssignment(
      id: model.id,
      name: model.name,
      latitude: model.latitude,
      longitude: model.longitude,
      isActive: model.isActive,
      fullAddress: model.fullAddress,
      assignedEmployeesCount: model.assignedEmployeesCount,
    );
  }
}
