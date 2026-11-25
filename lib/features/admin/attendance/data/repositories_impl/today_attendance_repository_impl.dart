import 'package:timelay_health/features/admin/attendance/data/datasources/today_attendance_remote_datasource.dart';
import 'package:timelay_health/features/admin/attendance/domain/repositories/today_attendance_repository.dart';
import 'package:timelay_health/features/admin/attendance/presentation/models/today_attendance_ui.dart';

class TodayAttendanceRepositoryImpl implements TodayAttendanceRepository {
  TodayAttendanceRepositoryImpl({TodayAttendanceRemoteDataSource? remote})
      : _remote = remote ?? TodayAttendanceRemoteDataSource();

  final TodayAttendanceRemoteDataSource _remote;

  @override
  Future<TodayAttendanceUi> getTodayAttendance({
    String? fromDate,
    String? toDate,
    int page = 1,
    int limit = 100,
  }) async {
    final raw = await _remote.getTodayAttendance(
      fromDate: fromDate,
      toDate: toDate,
      page: page,
      limit: limit,
    );
    return TodayAttendanceUi.fromJson(raw);
  }
}
