import 'package:timelay_health/features/visits/domain/entities/visit.dart';
import 'package:timelay_health/features/visits/domain/repositories/visit_repository.dart';

class UpdateVisitUseCase {
  const UpdateVisitUseCase(this._repository);
  final VisitRepository _repository;

  Future<Visit> call(UpdateVisitParams params) {
    return _repository.updateVisit(params);
  }
}
