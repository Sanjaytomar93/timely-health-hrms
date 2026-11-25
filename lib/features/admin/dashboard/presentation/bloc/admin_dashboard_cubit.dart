import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelay_health/features/admin/dashboard/data/repositories_impl/admin_dashboard_repository_impl.dart';
import 'package:timelay_health/features/admin/dashboard/domain/failures/admin_dashboard_failure.dart';
import 'package:timelay_health/features/admin/dashboard/domain/usecases/get_admin_dashboard_usecase.dart';
import 'package:timelay_health/features/admin/dashboard/presentation/bloc/admin_dashboard_state.dart';
import 'package:timelay_health/features/admin/dashboard/presentation/models/admin_dashboard_ui.dart';
import 'package:timelay_health/features/admin/leaves/data/repositories_impl/admin_leave_repository_impl.dart';
import 'package:timelay_health/features/admin/leaves/domain/failures/admin_leave_failure.dart';
import 'package:timelay_health/features/admin/leaves/domain/repositories/admin_leave_repository.dart';
import 'package:timelay_health/features/auth/data/auth_session.dart';

class AdminDashboardCubit extends Cubit<AdminDashboardState> {
  AdminDashboardCubit({
    GetAdminDashboardUseCase? useCase,
    AdminLeaveRepository? leaveRepository,
    DateTime? initialMonth,
  })  : _useCase =
            useCase ?? GetAdminDashboardUseCase(AdminDashboardRepositoryImpl()),
        _leaveRepository = leaveRepository ?? AdminLeaveRepositoryImpl(),
        super(
          AdminDashboardInitial(
            month: initialMonth ??
                DateTime(DateTime.now().year, DateTime.now().month),
          ),
        );

  final GetAdminDashboardUseCase _useCase;
  final AdminLeaveRepository _leaveRepository;

  DateTime get month => state.month;

  Future<void> setMonth(DateTime value) {
    final next = DateTime(value.year, value.month);
    emit(AdminDashboardLoading(month: next, ui: state.ui));
    return load(month: next, keepExisting: true);
  }

  Future<void> load({DateTime? month, bool keepExisting = false}) async {
    final target = month ?? state.month;
    final previous = keepExisting ? state.ui : AdminDashboardUi.empty;
    emit(AdminDashboardLoading(month: target, ui: previous));

    try {
      final ui = await _useCase(month: target.month, year: target.year);
      if (isClosed) return;
      emit(AdminDashboardLoaded(month: target, ui: ui));
    } on AdminDashboardFailure catch (e) {
      if (isClosed) return;
      emit(
        AdminDashboardFailureState(
          e.message,
          month: target,
          ui: previous,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        AdminDashboardFailureState(
          'Failed to load dashboard. Please try again.',
          month: target,
          ui: previous,
        ),
      );
    }
  }

  Future<void> updateLeaveStatus({
    required String id,
    required String status,
  }) async {
    final leaveId = id.trim();
    if (leaveId.isEmpty) {
      throw const AdminLeaveFailure('Leave ID missing.');
    }

    final admin = AuthSession.currentEmployee ?? await AuthSession.load();
    if (admin == null) {
      throw const AdminLeaveFailure(
        'Admin session missing. Please login again.',
      );
    }

    final adminName = admin.name.trim().isNotEmpty
        ? admin.name.trim()
        : (admin.employeeId.trim().isNotEmpty
            ? admin.employeeId.trim()
            : 'Admin');
    final adminEmail = admin.email.trim();
    final adminRole =
        admin.role.trim().isNotEmpty ? admin.role.trim() : 'Admin';
    final actionAt = DateTime.now().toUtc().toIso8601String();

    await _leaveRepository.updateLeaveStatus(
      id: leaveId,
      status: status,
      adminName: adminName,
      adminEmail: adminEmail,
      adminRole: adminRole,
      actionAt: actionAt,
    );

    final current = state.ui;
    final nextLeaves =
        current.pendingLeaves.where((e) => e.id != leaveId).toList();
    emit(
      AdminDashboardLoaded(
        month: state.month,
        ui: AdminDashboardUi(
          metrics: current.metrics,
          todaySlices: current.todaySlices,
          heatmap: current.heatmap,
          presentNow: current.presentNow,
          lateNow: current.lateNow,
          onLeaveNow: current.onLeaveNow,
          absentNow: current.absentNow,
          totalStaff: current.totalStaff,
          attendanceRate: current.attendanceRate,
          exceptions: current.exceptions,
          topPerformers: current.topPerformers,
          streaks: current.streaks,
          departments: current.departments,
          holidayDots: current.holidayDots,
          trend: current.trend,
          pendingLeaves: nextLeaves,
        ),
      ),
    );
  }
}
