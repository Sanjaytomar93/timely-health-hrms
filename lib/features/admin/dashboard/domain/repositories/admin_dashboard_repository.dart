import 'package:timelay_health/features/admin/dashboard/presentation/models/admin_dashboard_ui.dart';

abstract class AdminDashboardRepository {
  Future<AdminDashboardUi> getSummary({
    required int month,
    required int year,
  });
}
