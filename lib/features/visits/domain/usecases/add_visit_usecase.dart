import 'package:timelay_health/features/visits/domain/entities/visit.dart';
import 'package:timelay_health/features/visits/domain/repositories/visit_repository.dart';

class AddVisitUseCase {
  const AddVisitUseCase(this._repository);
  final VisitRepository _repository;

  Future<Visit> call(AddVisitParams params) {
    return _repository.addVisit(params);
  }
}
