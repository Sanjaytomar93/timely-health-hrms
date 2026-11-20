import 'package:equatable/equatable.dart';
import 'package:timelay_health/features/admin/attendance/presentation/models/attendance_summary_ui.dart';

abstract class AttendanceSummaryState extends Equatable {
  const AttendanceSummaryState({
    required this.ui,
    required this.selectedMonth,
  });

  final AttendanceSummaryUi ui;
  final String selectedMonth;

  @override
  List<Object?> get props => [ui, selectedMonth];
}

class AttendanceSummaryInitial extends AttendanceSummaryState {
  const AttendanceSummaryInitial({required String month})
      : super(ui: AttendanceSummaryUi.empty, selectedMonth: month);
}

class AttendanceSummaryLoading extends AttendanceSummaryState {
  const AttendanceSummaryLoading({
    required String month,
    AttendanceSummaryUi? currentUi,
  }) : super(
          ui: currentUi ?? AttendanceSummaryUi.empty,
          selectedMonth: month,
        );
}

class AttendanceSummaryLoaded extends AttendanceSummaryState {
  const AttendanceSummaryLoaded({
    required super.ui,
    required String month,
  }) : super(selectedMonth: month);
}

class AttendanceSummaryFailureState extends AttendanceSummaryState {
  const AttendanceSummaryFailureState(
    this.message, {
    required String month,
    AttendanceSummaryUi? currentUi,
  }) : super(
          ui: currentUi ?? AttendanceSummaryUi.empty,
          selectedMonth: month,
        );

  final String message;

  @override
  List<Object?> get props => [message, ui, selectedMonth];
}
