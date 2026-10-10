import 'package:timelay_health/features/visits/domain/repositories/visit_repository.dart';

class DeleteVisitUseCase {
  const DeleteVisitUseCase(this._repository);
  final VisitRepository _repository;

  Future<void> call(String id) {
    return _repository.deleteVisit(id: id);
  }
}
