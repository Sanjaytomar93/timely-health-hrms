import 'package:timelay_health/features/admin/attendance/data/datasources/attendance_records_remote_datasource.dart';
import 'package:timelay_health/features/admin/attendance/domain/repositories/attendance_records_repository.dart';
import 'package:timelay_health/features/admin/attendance/presentation/models/attendance_records_ui.dart';

class AttendanceRecordsRepositoryImpl implements AttendanceRecordsRepository {
  AttendanceRecordsRepositoryImpl({AttendanceRecordsRemoteDataSource? remote})
      : _remote = remote ?? AttendanceRecordsRemoteDataSource();

  final AttendanceRecordsRemoteDataSource _remote;

  @override
  Future<AttendanceRecordsUi> getPageData({
    required String month,
    int page = 1,
    int limit = 15,
    String? employeeId,
    String? department,
    String? designation,
    String? date,
  }) async {
    final raw = await _remote.getPageData(
      month: month,
      page: page,
      limit: limit,
      employeeId: employeeId,
      department: department,
      designation: designation,
      date: date,
    );
    return AttendanceRecordsUi.fromJson(raw);
  }
}
