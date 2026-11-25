import 'package:timelay_health/features/admin/dashboard/domain/repositories/admin_dashboard_repository.dart';
import 'package:timelay_health/features/admin/dashboard/presentation/models/admin_dashboard_ui.dart';

class GetAdminDashboardUseCase {
  const GetAdminDashboardUseCase(this._repository);

  final AdminDashboardRepository _repository;

  Future<AdminDashboardUi> call({
    required int month,
    required int year,
  }) =>
      _repository.getSummary(month: month, year: year);
}
