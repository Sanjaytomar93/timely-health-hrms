import 'package:timelay_health/features/attendance/domain/entities/attendance_record.dart';
import 'package:timelay_health/features/attendance/domain/repositories/attendance_repository.dart';

class GetMyAttendanceUseCase {
  const GetMyAttendanceUseCase(this._repository);

  final AttendanceRepository _repository;

  Future<MyAttendanceResult> call(String employeeId) {
    return _repository.getMyAttendance(employeeId: employeeId);
  }
}
