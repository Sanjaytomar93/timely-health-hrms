import 'package:timelay_health/features/holidays/data/models/holiday_model.dart';
import 'package:timelay_health/features/holidays/domain/entities/holiday.dart';

class HolidayMapper {
  const HolidayMapper._();

  static Holiday toEntity(HolidayModel model) {
    return Holiday(
      id: model.id,
      name: model.name,
      fromDate: model.fromDate,
      toDate: model.toDate,
      totalDays: model.totalDays,
      type: model.type,
      state: model.state,
      isActive: model.isActive,
    );
  }
}
