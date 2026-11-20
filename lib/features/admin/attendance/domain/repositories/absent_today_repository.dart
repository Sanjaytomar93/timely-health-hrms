import 'package:timelay_health/features/admin/attendance/presentation/models/absent_today_ui.dart';

abstract class AbsentTodayRepository {
  Future<AbsentTodayUi> getAbsentRecords({
    required String fromDate,
    required String toDate,
  });
}
