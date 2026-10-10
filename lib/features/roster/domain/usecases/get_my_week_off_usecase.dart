import 'package:timelay_health/features/roster/domain/entities/week_off_schedule.dart';
import 'package:timelay_health/features/roster/domain/repositories/roster_repository.dart';

class GetMyWeekOffUseCase {
  const GetMyWeekOffUseCase(this._repository);
  final RosterRepository _repository;

  Future<WeekOffSchedule> call({
    required String employeeId,
    required DateTime month,
  }) => _repository.getMyWeekOff(employeeId: employeeId, month: month);
}
