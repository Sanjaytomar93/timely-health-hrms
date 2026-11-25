import 'package:equatable/equatable.dart';
import 'package:timelay_health/features/admin/dashboard/presentation/models/admin_dashboard_ui.dart';

sealed class AdminDashboardState extends Equatable {
  const AdminDashboardState({
    required this.month,
    this.ui = AdminDashboardUi.empty,
  });

  final DateTime month;
  final AdminDashboardUi ui;

  @override
  List<Object?> get props => [month, ui];
}

class AdminDashboardInitial extends AdminDashboardState {
  AdminDashboardInitial({DateTime? month})
      : super(
          month: month ?? DateTime(DateTime.now().year, DateTime.now().month),
        );
}

class AdminDashboardLoading extends AdminDashboardState {
  const AdminDashboardLoading({
    required super.month,
    super.ui,
  });
}

class AdminDashboardLoaded extends AdminDashboardState {
  const AdminDashboardLoaded({
    required super.month,
    required super.ui,
  });
}

class AdminDashboardFailureState extends AdminDashboardState {
  const AdminDashboardFailureState(
    this.message, {
    required super.month,
    super.ui,
  });

  final String message;

  @override
  List<Object?> get props => [message, month, ui];
}
