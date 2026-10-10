import 'package:timelay_health/features/roster/domain/entities/week_off_schedule.dart';

abstract class RosterRepository {
  Future<WeekOffSchedule> getMyWeekOff({
    required String employeeId,
    required DateTime month,
  });
}
