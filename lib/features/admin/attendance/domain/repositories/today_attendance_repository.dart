import 'package:timelay_health/features/admin/attendance/presentation/models/today_attendance_ui.dart';

abstract class TodayAttendanceRepository {
  Future<TodayAttendanceUi> getTodayAttendance({
    String? fromDate,
    String? toDate,
    int page = 1,
    int limit = 100,
  });
}
