import 'package:timelay_health/features/admin/dashboard/data/datasources/admin_dashboard_remote_datasource.dart';
import 'package:timelay_health/features/admin/dashboard/domain/repositories/admin_dashboard_repository.dart';
import 'package:timelay_health/features/admin/dashboard/presentation/models/admin_dashboard_ui.dart';

class AdminDashboardRepositoryImpl implements AdminDashboardRepository {
  AdminDashboardRepositoryImpl({AdminDashboardRemoteDataSource? remote})
      : _remote = remote ?? AdminDashboardRemoteDataSource();

  final AdminDashboardRemoteDataSource _remote;

  @override
  Future<AdminDashboardUi> getSummary({
    required int month,
    required int year,
  }) async {
    final data = await _remote.getSummary(month: month, year: year);
    return AdminDashboardUi.fromApiJson(data, month: month, year: year);
  }
}
