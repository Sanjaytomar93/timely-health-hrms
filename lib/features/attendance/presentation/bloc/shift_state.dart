import 'package:equatable/equatable.dart';
import 'package:timelay_health/features/attendance/presentation/models/shift_ui_model.dart';

sealed class ShiftState extends Equatable {
  const ShiftState({
    this.shift,
    this.stats = ShiftStatsUiModel.empty,
    this.headerDate = '',
  });

  final ShiftUiModel? shift;
  final ShiftStatsUiModel stats;
  final String headerDate;

  @override
  List<Object?> get props => [shift, stats, headerDate];
}

class ShiftInitial extends ShiftState {
  const ShiftInitial();
}

class ShiftLoading extends ShiftState {
  const ShiftLoading({super.shift, super.stats, super.headerDate});
}

class ShiftLoaded extends ShiftState {
  const ShiftLoaded({
    required ShiftUiModel shift,
    required super.stats,
    required super.headerDate,
  }) : super(shift: shift);
}

class ShiftFailureState extends ShiftState {
  const ShiftFailureState(
    this.message, {
    super.shift,
    super.stats,
    super.headerDate,
  });

  final String message;

  @override
  List<Object?> get props => [message, ...super.props];
}
