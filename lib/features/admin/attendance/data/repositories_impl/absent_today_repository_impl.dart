import 'package:timelay_health/features/admin/attendance/data/datasources/absent_today_remote_datasource.dart';
import 'package:timelay_health/features/admin/attendance/domain/repositories/absent_today_repository.dart';
import 'package:timelay_health/features/admin/attendance/presentation/models/absent_today_ui.dart';

class AbsentTodayRepositoryImpl implements AbsentTodayRepository {
  AbsentTodayRepositoryImpl({AbsentTodayRemoteDataSource? remote})
      : _remote = remote ?? AbsentTodayRemoteDataSource();

  final AbsentTodayRemoteDataSource _remote;

  @override
  Future<AbsentTodayUi> getAbsentRecords({
    required String fromDate,
    required String toDate,
  }) async {
    final data = await _remote.getAbsentToday(
      fromDate: fromDate,
      toDate: toDate,
    );
    return AbsentTodayUi.fromJson(data, selectedDateString: fromDate);
  }
}
