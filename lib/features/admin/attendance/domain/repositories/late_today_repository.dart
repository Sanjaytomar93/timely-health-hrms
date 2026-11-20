import 'package:timelay_health/features/admin/attendance/presentation/models/late_today_ui.dart';

abstract class LateTodayRepository {
  Future<LateTodayUi> getLateRecords({
    String? date,
    String? month,
  });
}
