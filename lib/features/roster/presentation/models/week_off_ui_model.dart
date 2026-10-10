import 'package:equatable/equatable.dart';
import 'package:timelay_health/features/roster/domain/entities/week_off_schedule.dart';
import 'package:timelay_health/features/roster/presentation/models/week_off_rule.dart';

class WeekOffUiModel extends Equatable {
  const WeekOffUiModel({
    required this.label,
    required this.pattern,
    required this.offDays,
  });

  final String label;
  final String pattern;
  final List<DateTime> offDays;

  static const loading = WeekOffUiModel(
    label: 'Loading…',
    pattern: 'Fetching',
    offDays: [],
  );

  int get count => offDays.length;

  String get countLabel => '$count ${count == 1 ? 'Day' : 'Days'}';

  bool isOff(DateTime date) => offDays.any(
    (d) => d.year == date.year && d.month == date.month && d.day == date.day,
  );

  @override
  List<Object?> get props => [label, pattern, offDays];
}

class WeekOffUiMapper {
  const WeekOffUiMapper._();

  static WeekOffUiModel toUi(WeekOffSchedule schedule) {
    final days = schedule.weekOffDays;
    final String label;
    if (days.isNotEmpty) {
      label = schedule.isWeekly ? 'Every ${days.join(', ')}' : days.join(', ');
    } else if (schedule.dates.isNotEmpty) {
      label = '${schedule.dates.length} selected dates';
    } else {
      label = 'Not configured';
    }

    final mode = schedule.selectionMode.trim();
    return WeekOffUiModel(
      label: label,
      pattern: schedule.isWeekly
          ? 'Weekly Pattern'
          : mode.isEmpty
          ? 'Assigned Rule'
          : '${mode[0].toUpperCase()}${mode.substring(1)} Pattern',
      offDays: schedule.dates,
    );
  }

  /// Used when the week-off API is unavailable, from the profile's
  /// `weekOffDay` setting.
  static WeekOffUiModel fromProfile(String weekOffDay, DateTime month) {
    final rule = WeekOffRule.parse(weekOffDay);
    return WeekOffUiModel(
      label: rule.label,
      pattern: rule.isEmpty
          ? 'Not Assigned'
          : rule.isWeeklyPattern
          ? 'Weekly Pattern'
          : 'Custom Pattern',
      offDays: rule.offDaysIn(month.year, month.month),
    );
  }
}
