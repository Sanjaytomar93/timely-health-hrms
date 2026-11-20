import 'package:timelay_health/features/admin/attendance/presentation/models/attendance_records_ui.dart';

abstract class AttendanceRecordsRepository {
  Future<AttendanceRecordsUi> getPageData({
    required String month,
    int page = 1,
    int limit = 15,
    String? employeeId,
    String? department,
    String? designation,
    String? date,
  });
}
