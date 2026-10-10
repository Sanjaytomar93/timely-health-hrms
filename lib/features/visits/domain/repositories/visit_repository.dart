import 'package:timelay_health/features/visits/domain/entities/visit.dart';

abstract class VisitRepository {
  Future<List<Visit>> getMyVisits({required String employeeId});

  Future<Visit> addVisit(AddVisitParams params);

  Future<Visit> updateVisit(UpdateVisitParams params);

  Future<void> deleteVisit({required String id});
}
