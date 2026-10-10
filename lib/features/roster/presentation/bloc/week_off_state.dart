import 'package:equatable/equatable.dart';
import 'package:timelay_health/features/roster/presentation/models/week_off_ui_model.dart';

sealed class WeekOffState extends Equatable {
  const WeekOffState({required this.month, this.weekOff});

  /// First day of the selected month.
  final DateTime month;
  final WeekOffUiModel? weekOff;

  @override
  List<Object?> get props => [month, weekOff];
}

class WeekOffInitial extends WeekOffState {
  const WeekOffInitial({required super.month});
}

class WeekOffLoading extends WeekOffState {
  const WeekOffLoading({required super.month, super.weekOff});
}

class WeekOffLoaded extends WeekOffState {
  const WeekOffLoaded({required super.month, required WeekOffUiModel weekOff})
    : super(weekOff: weekOff);
}

class WeekOffFailureState extends WeekOffState {
  const WeekOffFailureState(
    this.message, {
    required super.month,
    super.weekOff,
  });

  final String message;

  @override
  List<Object?> get props => [message, ...super.props];
}
