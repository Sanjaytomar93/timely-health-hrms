import 'package:timelay_health/features/admin/leaves/domain/repositories/admin_leave_repository.dart';
import 'package:timelay_health/features/admin/leaves/presentation/models/admin_leave_requests_ui.dart';

class GetAdminLeavesUseCase {
  const GetAdminLeavesUseCase(this._repository);

  final AdminLeaveRepository _repository;

  Future<AdminLeaveRequestsUi> call() => _repository.getLeaveRequests();
}
