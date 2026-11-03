import 'package:equatable/equatable.dart';
import 'package:timelay_health/features/camp/camps/presentation/models/camp_list_ui.dart';

sealed class CampsState extends Equatable {
  const CampsState({
    this.camps = const [],
    this.allCamps = const [],
    this.stats = const [],
    this.search = '',
    this.filter = 'All camps',
  });

  final List<CampItemUi> camps;
  final List<CampItemUi> allCamps;
  final List<CampListStatUi> stats;
  final String search;
  final String filter;

  @override
  List<Object?> get props => [camps, allCamps, stats, search, filter];
}

class CampsInitial extends CampsState {
  const CampsInitial();
}

class CampsLoading extends CampsState {
  const CampsLoading({
    super.camps,
    super.allCamps,
    super.stats,
    super.search,
    super.filter,
  });
}

class CampsLoaded extends CampsState {
  const CampsLoaded({
    required super.camps,
    required super.allCamps,
    required super.stats,
    super.search,
    super.filter,
  });
}

class CampsFailureState extends CampsState {
  const CampsFailureState(
    this.message, {
    super.camps,
    super.allCamps,
    super.stats,
    super.search,
    super.filter,
  });

  final String message;

  @override
  List<Object?> get props => [message, ...super.props];
}
