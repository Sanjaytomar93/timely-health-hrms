import 'package:timelay_health/features/holidays/domain/entities/holiday.dart';

abstract class HolidayRepository {
  Future<List<Holiday>> getAllHolidays();
}
