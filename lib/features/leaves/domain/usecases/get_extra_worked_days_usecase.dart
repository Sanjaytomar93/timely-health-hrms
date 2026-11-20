import 'package:timelay_health/features/leaves/domain/entities/comp_off_request.dart';
import 'package:timelay_health/features/leaves/domain/repositories/leave_repository.dart';

class GetExtraWorkedDaysUseCase {
  const GetExtraWorkedDaysUseCase(this._repository);

  final LeaveRepository _repository;

  Future<List<ExtraWorkedDay>> call(String employeeId) =>
      _repository.getExtraWorkedDays(employeeId: employeeId);
}
