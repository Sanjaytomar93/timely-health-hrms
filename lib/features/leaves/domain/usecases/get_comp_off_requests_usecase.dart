import 'package:timelay_health/features/leaves/domain/entities/comp_off_request.dart';
import 'package:timelay_health/features/leaves/domain/repositories/leave_repository.dart';

class GetCompOffRequestsUseCase {
  const GetCompOffRequestsUseCase(this._repository);

  final LeaveRepository _repository;

  Future<CompOffRequests> call(String employeeId) =>
      _repository.getCompOffRequests(employeeId: employeeId);
}
