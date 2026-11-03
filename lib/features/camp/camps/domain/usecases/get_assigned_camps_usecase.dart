import 'package:timelay_health/features/camp/camps/domain/entities/camp.dart';
import 'package:timelay_health/features/camp/camps/domain/repositories/camp_repository.dart';

class GetAssignedCampsUseCase {
  const GetAssignedCampsUseCase(this._repository);

  final CampRepository _repository;

  Future<List<Camp>> call(String employeeName) =>
      _repository.getAssignedCamps(employeeName);
}
