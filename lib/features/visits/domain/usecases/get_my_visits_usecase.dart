import 'package:timelay_health/features/visits/domain/entities/visit.dart';
import 'package:timelay_health/features/visits/domain/repositories/visit_repository.dart';

class GetMyVisitsUseCase {
  const GetMyVisitsUseCase(this._repository);
  final VisitRepository _repository;

  Future<List<Visit>> call(String employeeId) {
    return _repository.getMyVisits(employeeId: employeeId);
  }
}
