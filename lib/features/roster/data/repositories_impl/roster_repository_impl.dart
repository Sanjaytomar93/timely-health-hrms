import 'package:timelay_health/features/roster/data/datasources/roster_remote_datasource.dart';
import 'package:timelay_health/features/roster/data/mappers/week_off_mapper.dart';
import 'package:timelay_health/features/roster/domain/entities/week_off_schedule.dart';
import 'package:timelay_health/features/roster/domain/repositories/roster_repository.dart';

class RosterRepositoryImpl implements RosterRepository {
  RosterRepositoryImpl({RosterRemoteDataSource? remoteDataSource})
    : _remote = remoteDataSource ?? RosterRemoteDataSource();

  final RosterRemoteDataSource _remote;

  @override
  Future<WeekOffSchedule> getMyWeekOff({
    required String employeeId,
    required DateTime month,
  }) async {
    final monthParam =
        '${month.year.toString().padLeft(4, '0')}-'
        '${month.month.toString().padLeft(2, '0')}';
    final model = await _remote.getMyWeekOff(
      employeeId: employeeId,
      month: monthParam,
    );
    return WeekOffMapper.toEntity(model, month);
  }
}
