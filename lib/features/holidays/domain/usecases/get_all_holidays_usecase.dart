import 'package:timelay_health/features/holidays/domain/entities/holiday.dart';
import 'package:timelay_health/features/holidays/domain/repositories/holiday_repository.dart';

class GetAllHolidaysUseCase {
  const GetAllHolidaysUseCase(this._repository);
  final HolidayRepository _repository;

  Future<List<Holiday>> call() => _repository.getAllHolidays();
}
