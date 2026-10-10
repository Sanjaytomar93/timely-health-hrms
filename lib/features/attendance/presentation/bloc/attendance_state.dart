import 'package:equatable/equatable.dart';
import 'package:timelay_health/features/attendance/presentation/models/attendance_record_ui_model.dart';

sealed class AttendanceState extends Equatable {
  const AttendanceState({
    this.records = const [],
    this.allRecords = const [],
    this.stats = AttendanceStatsUiModel.empty,
    this.filter = AttendanceFilter.empty,
    this.shiftLabel = '—',
    this.selectedOtIds = const {},
  });

  final List<AttendanceRecordUiModel> records;
  final List<AttendanceRecordUiModel> allRecords;
  final AttendanceStatsUiModel stats;
  final AttendanceFilter filter;
  final String shiftLabel;
  final Set<String> selectedOtIds;

  List<AttendanceRecordUiModel> get otRecords => stats.hasOt
      ? allRecords.where((r) => r.hasClaimableOt).toList()
      : const [];

  List<AttendanceRecordUiModel> get selectedOtRecords =>
      otRecords.where((r) => selectedOtIds.contains(r.id)).toList();

  @override
  List<Object?> get props => [
    records,
    allRecords,
    stats,
    filter,
    shiftLabel,
    selectedOtIds,
  ];
}

class AttendanceInitial extends AttendanceState {
  const AttendanceInitial();
}

class AttendanceLoading extends AttendanceState {
  const AttendanceLoading({
    super.records,
    super.allRecords,
    super.stats,
    super.filter,
    super.shiftLabel,
    super.selectedOtIds,
  });
}

class AttendanceLoaded extends AttendanceState {
  const AttendanceLoaded({
    required super.records,
    required super.allRecords,
    required super.stats,
    super.filter,
    super.shiftLabel,
    super.selectedOtIds,
  });
}

class AttendanceFailureState extends AttendanceState {
  const AttendanceFailureState(
    this.message, {
    super.records,
    super.allRecords,
    super.stats,
    super.filter,
    super.shiftLabel,
    super.selectedOtIds,
  });

  final String message;

  @override
  List<Object?> get props => [message, ...super.props];
}
