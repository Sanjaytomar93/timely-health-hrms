import 'package:timelay_health/features/camp/dashboard/domain/entities/volunteer_dashboard.dart';

abstract class DashboardRepository {
  Future<VolunteerDashboard> getVolunteerDashboard(String employeeName);
}
