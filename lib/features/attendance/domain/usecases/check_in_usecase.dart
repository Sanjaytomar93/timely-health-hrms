import 'package:timelay_health/features/attendance/domain/entities/check_in_params.dart';
import 'package:timelay_health/features/attendance/domain/entities/check_in_result.dart';
import 'package:timelay_health/features/attendance/domain/repositories/attendance_repository.dart';

class CheckInUseCase {
  const CheckInUseCase(this._repository);
  final AttendanceRepository _repository;

  Future<CheckInResult> call(CheckInParams params) =>
      _repository.checkIn(params);
}

class CheckOutUseCase {
  const CheckOutUseCase(this._repository);
  final AttendanceRepository _repository;

  Future<CheckOutResult> call(CheckOutParams params) =>
      _repository.checkOut(params);
}
