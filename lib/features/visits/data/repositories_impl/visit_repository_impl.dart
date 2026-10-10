import 'package:timelay_health/features/visits/data/datasources/visit_remote_datasource.dart';
import 'package:timelay_health/features/visits/data/mappers/visit_mapper.dart';
import 'package:timelay_health/features/visits/domain/entities/visit.dart';
import 'package:timelay_health/features/visits/domain/repositories/visit_repository.dart';

class VisitRepositoryImpl implements VisitRepository {
  VisitRepositoryImpl({VisitRemoteDataSource? remoteDataSource})
    : _remote = remoteDataSource ?? VisitRemoteDataSource();

  final VisitRemoteDataSource _remote;

  @override
  Future<List<Visit>> getMyVisits({required String employeeId}) async {
    final models = await _remote.getMyVisits(employeeId: employeeId);
    return models.map(VisitMapper.toEntity).toList();
  }

  @override
  Future<Visit> addVisit(AddVisitParams params) async {
    final model = await _remote.addVisit(params);
    return VisitMapper.toEntity(model);
  }

  @override
  Future<Visit> updateVisit(UpdateVisitParams params) async {
    final model = await _remote.updateVisit(params);
    return VisitMapper.toEntity(model);
  }

  @override
  Future<void> deleteVisit({required String id}) {
    return _remote.deleteVisit(id: id);
  }
}
