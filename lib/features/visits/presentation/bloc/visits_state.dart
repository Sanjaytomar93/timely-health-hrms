import 'package:equatable/equatable.dart';
import 'package:timelay_health/features/visits/presentation/models/visit_ui_model.dart';

sealed class VisitsState extends Equatable {
  const VisitsState({
    this.visits = const [],
    this.allVisits = const [],
    this.stats = VisitStatsUiModel.empty,
    this.search = '',
    this.status = 'All Status',
    this.month = '',
    this.monthOptions = const ['All Months'],
  });

  final List<VisitUiModel> visits;
  final List<VisitUiModel> allVisits;
  final VisitStatsUiModel stats;
  final String search;
  final String status;
  final String month;
  final List<String> monthOptions;

  @override
  List<Object?> get props => [
    visits,
    allVisits,
    stats,
    search,
    status,
    month,
    monthOptions,
  ];
}

class VisitsInitial extends VisitsState {
  VisitsInitial()
    : super(month: _initialMonth, monthOptions: ['All Months', _initialMonth]);

  static String get _initialMonth =>
      VisitUiMapper.monthLabel(DateTime.now()) ?? 'All Months';
}

class VisitsLoading extends VisitsState {
  const VisitsLoading({
    super.visits,
    super.allVisits,
    super.stats,
    super.search,
    super.status,
    super.month,
    super.monthOptions,
  });
}

class VisitsLoaded extends VisitsState {
  const VisitsLoaded({
    required super.visits,
    required super.allVisits,
    required super.stats,
    super.search,
    super.status,
    super.month,
    super.monthOptions,
  });
}

class VisitsFailureState extends VisitsState {
  const VisitsFailureState(
    this.message, {
    super.visits,
    super.allVisits,
    super.stats,
    super.search,
    super.status,
    super.month,
    super.monthOptions,
  });

  final String message;

  @override
  List<Object?> get props => [message, ...super.props];
}
