import 'package:timelay_health/features/attendance/domain/entities/employee_shift.dart';
import 'package:timelay_health/features/attendance/domain/repositories/attendance_repository.dart';

class GetMyShiftUseCase {
  const GetMyShiftUseCase(this._repository);

  final AttendanceRepository _repository;

  Future<EmployeeShift> call(String employeeId) {
    return _repository.getMyShift(employeeId: employeeId);
  }
}
