import 'package:timelay_health/features/camp/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:timelay_health/features/camp/dashboard/domain/entities/volunteer_dashboard.dart';
import 'package:timelay_health/features/camp/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl({DashboardRemoteDataSource? remoteDataSource})
      : _remote = remoteDataSource ?? DashboardRemoteDataSource();

  final DashboardRemoteDataSource _remote;

  @override
  Future<VolunteerDashboard> getVolunteerDashboard(String employeeName) async {
    final model = await _remote.getVolunteerDashboard(employeeName);
    return model.toEntity();
  }
}
