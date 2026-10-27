import 'package:timelay_health/features/attendance/domain/entities/employee_location_assignment.dart';
import 'package:timelay_health/features/attendance/domain/repositories/attendance_repository.dart';

class GetAllLocationsUseCase {
  const GetAllLocationsUseCase(this._repository);

  final AttendanceRepository _repository;

  Future<List<EmployeeLocationAssignment>> call() {
    return _repository.getAllLocations();
  }
}
