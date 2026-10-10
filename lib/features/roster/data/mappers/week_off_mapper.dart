import 'package:timelay_health/features/roster/data/models/week_off_model.dart';
import 'package:timelay_health/features/roster/domain/entities/week_off_schedule.dart';

class WeekOffMapper {
  const WeekOffMapper._();

  static WeekOffSchedule toEntity(WeekOffModel model, DateTime month) {
    final dates =
        model.weekOffDates.map(_parseDate).whereType<DateTime>().toList()
          ..sort();
    return WeekOffSchedule(
      employeeId: model.employeeId,
      month: DateTime(month.year, month.month),
      totalWeekOffs: model.totalWeekOffs ?? dates.length,
      dates: dates,
      selectionMode: model.selectionMode,
      weekOffDays: model.weekOffDays,
      source: model.source,
    );
  }

  static DateTime? _parseDate(String raw) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(raw);
    if (match == null) return null;
    return DateTime(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    );
  }
}
