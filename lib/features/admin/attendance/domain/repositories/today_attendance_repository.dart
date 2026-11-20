import 'package:timelay_health/features/admin/attendance/presentation/models/today_attendance_ui.dart';

abstract class TodayAttendanceRepository {
  Future<TodayAttendanceUi> getTodayAttendance();

  Future<TodayAttendanceUi> getByMonth({
    required String month,
    String? date,
    int page = 1,
    int limit = 15,
  });
}
