import 'package:timelay_health/features/camp/dashboard/domain/entities/volunteer_dashboard.dart';
import 'package:timelay_health/features/camp/dashboard/domain/repositories/dashboard_repository.dart';

class GetVolunteerDashboardUseCase {
  const GetVolunteerDashboardUseCase(this._repository);

  final DashboardRepository _repository;

  Future<VolunteerDashboard> call(String employeeName) =>
      _repository.getVolunteerDashboard(employeeName);
}
