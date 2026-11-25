import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelay_health/features/admin/leaves/data/repositories_impl/admin_leave_repository_impl.dart';
import 'package:timelay_health/features/admin/leaves/domain/failures/admin_leave_failure.dart';
import 'package:timelay_health/features/admin/leaves/domain/repositories/admin_leave_repository.dart';
import 'package:timelay_health/features/admin/leaves/domain/usecases/get_admin_leaves_usecase.dart';
import 'package:timelay_health/features/admin/leaves/presentation/bloc/admin_leave_state.dart';
import 'package:timelay_health/features/admin/leaves/presentation/models/admin_leave_requests_ui.dart';
import 'package:timelay_health/features/auth/data/auth_session.dart';

class AdminLeaveCubit extends Cubit<AdminLeaveState> {
  AdminLeaveCubit({
    GetAdminLeavesUseCase? useCase,
    AdminLeaveRepository? repository,
  })  : _useCase = useCase ?? GetAdminLeavesUseCase(AdminLeaveRepositoryImpl()),
        _repository = repository ?? AdminLeaveRepositoryImpl(),
        super(AdminLeaveInitial());

  final GetAdminLeavesUseCase _useCase;
  final AdminLeaveRepository _repository;

  Future<void> load({bool isRefresh = false}) async {
    final current = state.ui;
    emit(AdminLeaveLoading(currentUi: current));

    try {
      final ui = await _useCase();
      if (isClosed) return;
      emit(AdminLeaveLoaded(ui));
    } on AdminLeaveFailure catch (e) {
      if (isClosed) return;
      emit(AdminLeaveFailureState(e.message, currentUi: current));
    } catch (_) {
      if (isClosed) return;
      emit(AdminLeaveFailureState(
        'Failed to load leave requests. Please check your connection and try again.',
        currentUi: current,
      ));
    }
  }

  Future<void> approveLeave({required String id}) async {
    final admin = AuthSession.currentEmployee ?? await AuthSession.load();
    if (admin == null) {
      throw const AdminLeaveFailure('Admin session missing. Please login again.');
    }

    final adminName = admin.name.trim().isNotEmpty
        ? admin.name.trim()
        : (admin.employeeId.trim().isNotEmpty ? admin.employeeId.trim() : 'Admin');
    final adminEmail = admin.email.trim();
    final adminRole =
        admin.role.trim().isNotEmpty ? admin.role.trim() : 'Admin';
    final actionAt = DateTime.now().toUtc().toIso8601String();

    await _repository.updateLeaveStatus(
      id: id,
      status: 'approved',
      adminName: adminName,
      adminEmail: adminEmail,
      adminRole: adminRole,
      actionAt: actionAt,
    );

    _applyLocalStatus(
      id: id,
      status: 'Approved',
      approver: adminName,
    );
  }

  void _applyLocalStatus({
    required String id,
    required String status,
    required String approver,
  }) {
    final currentRecords = List<AdminLeaveItem>.from(state.ui.records);
    final index = currentRecords.indexWhere((r) => r.id == id);
    if (index == -1) return;

    final item = currentRecords[index];
    currentRecords[index] = item.copyWith(
      status: status,
      approver: approver,
      timestamp: 'Just now',
    );

    final totalCount = currentRecords.length;
    final pendingCount = currentRecords.where((r) => r.isPending).length;
    final approvedCount = currentRecords.where((r) => r.isApproved).length;
    final rejectedCount = currentRecords.where((r) => r.isRejected).length;

    emit(AdminLeaveLoaded(
      AdminLeaveRequestsUi(
        totalLeaves: totalCount,
        pendingLeaves: pendingCount,
        approvedLeaves: approvedCount,
        rejectedLeaves: rejectedCount,
        records: currentRecords,
        departments: state.ui.departments,
        designations: state.ui.designations,
      ),
    ));
  }

  Future<void> rejectLeave({required String id}) async {
    final admin = AuthSession.currentEmployee ?? await AuthSession.load();
    if (admin == null) {
      throw const AdminLeaveFailure('Admin session missing. Please login again.');
    }

    final adminName = admin.name.trim().isNotEmpty
        ? admin.name.trim()
        : (admin.employeeId.trim().isNotEmpty ? admin.employeeId.trim() : 'Admin');
    final adminEmail = admin.email.trim();
    final adminRole =
        admin.role.trim().isNotEmpty ? admin.role.trim() : 'Admin';
    final actionAt = DateTime.now().toUtc().toIso8601String();

    await _repository.updateLeaveStatus(
      id: id,
      status: 'rejected',
      adminName: adminName,
      adminEmail: adminEmail,
      adminRole: adminRole,
      actionAt: actionAt,
    );

    _applyLocalStatus(
      id: id,
      status: 'Rejected',
      approver: adminName,
    );
  }

  void updateLeaveStatus({
    required String id,
    required String status,
    String? approver,
  }) {
    _applyLocalStatus(
      id: id,
      status: status,
      approver: approver ?? 'Admin',
    );
  }
}
