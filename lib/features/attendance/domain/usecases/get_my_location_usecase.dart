import 'package:timelay_health/features/attendance/domain/entities/employee_location_assignment.dart';
import 'package:timelay_health/features/attendance/domain/repositories/attendance_repository.dart';

class GetMyLocationUseCase {
  const GetMyLocationUseCase(this._repository);

  final AttendanceRepository _repository;

  Future<EmployeeLocationAssignment> call(String employeeId) {
    return _repository.getMyLocation(employeeId: employeeId);
  }
}
