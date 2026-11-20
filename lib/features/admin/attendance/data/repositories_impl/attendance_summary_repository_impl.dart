import 'package:timelay_health/features/admin/attendance/data/datasources/attendance_summary_remote_datasource.dart';
import 'package:timelay_health/features/admin/attendance/domain/repositories/attendance_summary_repository.dart';
import 'package:timelay_health/features/admin/attendance/presentation/models/attendance_summary_ui.dart';

class AttendanceSummaryRepositoryImpl implements AttendanceSummaryRepository {
  AttendanceSummaryRepositoryImpl({
    AttendanceSummaryRemoteDataSource? remote,
  }) : _remote = remote ?? AttendanceSummaryRemoteDataSource();

  final AttendanceSummaryRemoteDataSource _remote;

  @override
  Future<AttendanceSummaryUi> getPageData({required String month}) async {
    final json = await _remote.getPageData(month: month);
    return AttendanceSummaryUi.fromApiJson(json);
  }
}
