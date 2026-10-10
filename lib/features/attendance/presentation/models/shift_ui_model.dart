import 'package:equatable/equatable.dart';
import 'package:timelay_health/features/attendance/domain/entities/employee_shift.dart';

class ShiftUiModel extends Equatable {
  const ShiftUiModel({
    required this.id,
    required this.title,
    required this.type,
    required this.effectiveFrom,
    required this.startTime,
    required this.endTime,
    required this.leftBadge,
    required this.rightBadge,
    required this.isActive,
    required this.timeRange,
    required this.description,
    required this.category,
  });

  final String id;
  final String title;
  final String type;
  final String effectiveFrom;
  final String startTime;
  final String endTime;
  final String leftBadge;
  final String rightBadge;
  final bool isActive;
  final String timeRange;
  final String description;
  final String category;

  @override
  List<Object?> get props => [
    id,
    title,
    type,
    effectiveFrom,
    startTime,
    endTime,
    leftBadge,
    rightBadge,
    isActive,
    timeRange,
    description,
    category,
  ];
}

class ShiftStatsUiModel extends Equatable {
  const ShiftStatsUiModel({
    required this.totalShifts,
    required this.ongoing,
    required this.upcoming,
    required this.scheduled,
  });

  final int totalShifts;
  final int ongoing;
  final int upcoming;
  final int scheduled;

  static const empty = ShiftStatsUiModel(
    totalShifts: 0,
    ongoing: 0,
    upcoming: 0,
    scheduled: 0,
  );

  @override
  List<Object?> get props => [totalShifts, ongoing, upcoming, scheduled];
}

class ShiftUiMapper {
  const ShiftUiMapper._();

  static ShiftUiModel toUi(EmployeeShift shift) {
    final active = shift.isAssigned;
    return ShiftUiModel(
      id: shift.id,
      title: shift.shiftName.isEmpty ? 'Shift' : shift.shiftName,
      type: shift.shiftType.isEmpty ? '—' : shift.shiftType,
      effectiveFrom: _dateLabel(shift.assignedDate),
      startTime: shift.startTime.isEmpty ? '—' : shift.startTime,
      endTime: shift.endTime.isEmpty ? '—' : shift.endTime,
      leftBadge: active ? 'Current' : 'Upcoming',
      rightBadge: active ? 'On-Going' : 'Scheduled',
      isActive: active,
      timeRange: shift.timeRange,
      description: shift.description,
      category: shift.shiftCategory,
    );
  }

  static ShiftStatsUiModel toStats(EmployeeShift? shift) {
    if (shift == null) return ShiftStatsUiModel.empty;
    final ongoing = shift.isAssigned ? 1 : 0;
    final upcoming = shift.isAssigned ? 0 : 1;
    return ShiftStatsUiModel(
      totalShifts: 1,
      ongoing: ongoing,
      upcoming: upcoming,
      scheduled: upcoming,
    );
  }

  static String headerDateLabel(DateTime? date) {
    final d = (date ?? DateTime.now()).toLocal();
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${weekdays[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  static String _dateLabel(DateTime? date) {
    if (date == null) return '—';
    final local = date.toLocal();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final day = local.day.toString().padLeft(2, '0');
    return '$day ${months[local.month - 1]} ${local.year}';
  }
}
