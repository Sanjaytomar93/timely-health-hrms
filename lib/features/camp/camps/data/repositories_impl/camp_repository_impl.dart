import 'package:timelay_health/features/camp/camps/data/datasources/camp_remote_datasource.dart';
import 'package:timelay_health/features/camp/camps/data/mappers/camp_mapper.dart';
import 'package:timelay_health/features/camp/camps/domain/entities/camp.dart';
import 'package:timelay_health/features/camp/camps/domain/repositories/camp_repository.dart';

class CampRepositoryImpl implements CampRepository {
  CampRepositoryImpl({CampRemoteDataSource? remoteDataSource})
    : _remote = remoteDataSource ?? CampRemoteDataSource();

  final CampRemoteDataSource _remote;

  @override
  Future<List<Camp>> getAssignedCamps(String employeeName) async {
    final models = await _remote.getAssignedCamps(employeeName);
    return models.map(CampMapper.toEntity).toList();
  }

  @override
  Future<CampPatient> getPatientById(String patientId) async {
    final model = await _remote.getPatientById(patientId);
    return CampMapper.toPatientEntity(model);
  }
}
