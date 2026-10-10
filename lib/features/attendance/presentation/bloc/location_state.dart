import 'package:equatable/equatable.dart';
import 'package:timelay_health/features/attendance/presentation/models/location_ui_model.dart';

sealed class LocationState extends Equatable {
  const LocationState({this.location, this.headerDate = ''});

  final LocationUiModel? location;
  final String headerDate;

  @override
  List<Object?> get props => [location, headerDate];
}

class LocationInitial extends LocationState {
  const LocationInitial();
}

class LocationLoading extends LocationState {
  const LocationLoading({super.location, super.headerDate});
}

class LocationLoaded extends LocationState {
  const LocationLoaded({
    required LocationUiModel location,
    required super.headerDate,
  }) : super(location: location);
}

class LocationFailureState extends LocationState {
  const LocationFailureState(this.message, {super.location, super.headerDate});

  final String message;

  @override
  List<Object?> get props => [message, ...super.props];
}
