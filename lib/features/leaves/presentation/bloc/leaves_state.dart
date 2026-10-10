import 'package:equatable/equatable.dart';
import 'package:timelay_health/features/leaves/presentation/models/leave_ui_model.dart';
import 'package:timelay_health/features/leaves/domain/entities/comp_off_request.dart';

sealed class LeavesState extends Equatable {
  const LeavesState({
    this.leaves = const [],
    this.allLeaves = const [],
    this.stats = LeaveStatsUiModel.empty,
    this.compOffRequests = CompOffRequests.empty,
    this.search = '',
    this.selectedDate,
    this.selectedMonth,
  });

  final List<LeaveHistoryUiModel> leaves;
  final List<LeaveHistoryUiModel> allLeaves;
  final LeaveStatsUiModel stats;
  final CompOffRequests compOffRequests;
  final String search;
  final DateTime? selectedDate;
  final DateTime? selectedMonth;

  @override
  List<Object?> get props => [
    leaves,
    allLeaves,
    stats,
    compOffRequests,
    search,
    selectedDate,
    selectedMonth,
  ];
}

class LeavesInitial extends LeavesState {
  const LeavesInitial();
}

class LeavesLoading extends LeavesState {
  const LeavesLoading({
    super.leaves,
    super.allLeaves,
    super.stats,
    super.compOffRequests,
    super.search,
    super.selectedDate,
    super.selectedMonth,
  });
}

class LeavesLoaded extends LeavesState {
  const LeavesLoaded({
    required super.leaves,
    required super.allLeaves,
    required super.stats,
    required super.compOffRequests,
    super.search,
    super.selectedDate,
    super.selectedMonth,
  });
}

class LeavesFailureState extends LeavesState {
  const LeavesFailureState(
    this.message, {
    super.leaves,
    super.allLeaves,
    super.stats,
    super.compOffRequests,
    super.search,
    super.selectedDate,
    super.selectedMonth,
  });

  final String message;

  @override
  List<Object?> get props => [message, ...super.props];
}
