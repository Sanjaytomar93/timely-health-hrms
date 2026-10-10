import 'package:timelay_health/features/leaves/domain/entities/leave_record.dart';
import 'package:timelay_health/features/leaves/domain/repositories/leave_repository.dart';

class AddLeaveUseCase {
  const AddLeaveUseCase(this._repository);
  final LeaveRepository _repository;

  Future<LeaveRecord> call(AddLeaveParams params) {
    return _repository.addLeave(params);
  }
}
