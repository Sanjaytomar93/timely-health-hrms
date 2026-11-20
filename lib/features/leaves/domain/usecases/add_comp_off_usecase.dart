import 'package:timelay_health/features/leaves/domain/entities/comp_off_request.dart';
import 'package:timelay_health/features/leaves/domain/repositories/leave_repository.dart';

class AddCompOffUseCase {
  const AddCompOffUseCase(this._repository);

  final LeaveRepository _repository;

  Future<void> call(AddCompOffParams params) => _repository.addCompOff(params);
}
