import 'package:timelay_health/features/holidays/data/datasources/holiday_remote_datasource.dart';
import 'package:timelay_health/features/holidays/data/mappers/holiday_mapper.dart';
import 'package:timelay_health/features/holidays/domain/entities/holiday.dart';
import 'package:timelay_health/features/holidays/domain/repositories/holiday_repository.dart';

class HolidayRepositoryImpl implements HolidayRepository {
  HolidayRepositoryImpl({HolidayRemoteDataSource? remoteDataSource})
    : _remote = remoteDataSource ?? HolidayRemoteDataSource();

  final HolidayRemoteDataSource _remote;

  @override
  Future<List<Holiday>> getAllHolidays() async {
    final models = await _remote.getAllHolidays();
    return models.map(HolidayMapper.toEntity).toList();
  }
}
