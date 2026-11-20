import 'package:timelay_health/features/admin/attendance/domain/repositories/attendance_summary_repository.dart';
import 'package:timelay_health/features/admin/attendance/presentation/models/attendance_summary_ui.dart';

class GetAttendanceSummaryUseCase {
  const GetAttendanceSummaryUseCase(this._repository);

  final AttendanceSummaryRepository _repository;

  Future<AttendanceSummaryUi> call({required String month}) =>
      _repository.getPageData(month: month);
}
