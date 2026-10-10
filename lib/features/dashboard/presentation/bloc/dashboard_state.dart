import 'package:equatable/equatable.dart';
import 'package:timelay_health/features/dashboard/presentation/models/dashboard_home_ui.dart';

sealed class DashboardState extends Equatable {
  const DashboardState({this.ui});

  final DashboardHomeUi? ui;

  @override
  List<Object?> get props => [ui];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial() : super(ui: null);
}

class DashboardLoading extends DashboardState {
  const DashboardLoading({super.ui});
}

class DashboardLoaded extends DashboardState {
  const DashboardLoaded(DashboardHomeUi ui) : super(ui: ui);
}

class DashboardFailureState extends DashboardState {
  const DashboardFailureState(this.message, {super.ui});

  final String message;

  @override
  List<Object?> get props => [message, ui];
}
