import 'package:equatable/equatable.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/models/camp_dashboard_ui.dart';

sealed class DashboardState extends Equatable {
  const DashboardState({this.data = CampDashboardUi.empty});

  final CampDashboardUi data;

  @override
  List<Object?> get props => [data];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading({super.data});
}

class DashboardLoaded extends DashboardState {
  const DashboardLoaded({required super.data});
}

class DashboardFailureState extends DashboardState {
  const DashboardFailureState(this.message, {super.data});

  final String message;

  @override
  List<Object?> get props => [message, ...super.props];
}
