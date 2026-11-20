import 'package:timelay_health/features/admin/leaves/presentation/models/admin_leave_requests_ui.dart';

abstract class AdminLeaveRepository {
  Future<AdminLeaveRequestsUi> getLeaveRequests();

  Future<void> updateLeaveStatus({
    required String id,
    required String status,
    required String adminName,
    required String adminEmail,
    required String adminRole,
    required String actionAt,
  });
}
