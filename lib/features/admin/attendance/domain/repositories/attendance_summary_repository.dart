import 'package:timelay_health/features/admin/attendance/presentation/models/attendance_summary_ui.dart';

abstract class AttendanceSummaryRepository {
  Future<AttendanceSummaryUi> getPageData({required String month});
}
