import 'package:equatable/equatable.dart';
import 'package:timelay_health/features/admin/leaves/presentation/models/admin_leave_requests_ui.dart';

abstract class AdminLeaveState extends Equatable {
  const AdminLeaveState({required this.ui});

  final AdminLeaveRequestsUi ui;

  @override
  List<Object?> get props => [ui];
}

class AdminLeaveInitial extends AdminLeaveState {
  AdminLeaveInitial()
      : super(
          ui: const AdminLeaveRequestsUi(
            totalLeaves: 0,
            pendingLeaves: 0,
            approvedLeaves: 0,
            rejectedLeaves: 0,
            records: [],
          ),
        );
}

class AdminLeaveLoading extends AdminLeaveState {
  const AdminLeaveLoading({required AdminLeaveRequestsUi currentUi})
      : super(ui: currentUi);
}

class AdminLeaveLoaded extends AdminLeaveState {
  const AdminLeaveLoaded(AdminLeaveRequestsUi ui) : super(ui: ui);
}

class AdminLeaveFailureState extends AdminLeaveState {
  const AdminLeaveFailureState(
    this.message, {
    required AdminLeaveRequestsUi currentUi,
  }) : super(ui: currentUi);

  final String message;

  @override
  List<Object?> get props => [message, ui];
}
