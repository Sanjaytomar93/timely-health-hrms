import 'package:timelay_health/features/attendance/data/models/attendance_record_model.dart';
import 'package:timelay_health/features/attendance/domain/entities/attendance_record.dart';

class AttendanceMapper {
  const AttendanceMapper._();

  static AttendanceRecord toEntity(AttendanceRecordModel model) {
    return AttendanceRecord(
      id: model.id,
      employeeId: model.employeeId,
      name: model.name,
      employeeEmail: model.employeeEmail,
      checkInTime: model.checkInTime,
      checkOutTime: model.checkOutTime,
      status: model.status,
      totalBreakMinutes: model.totalBreakMinutes,
      totalHours: model.totalHours,
      workingHours: model.workingHours,
      assignedShiftHours: model.assignedShiftHours,
      otHours: model.otHours,
      otAmount: model.otAmount,
      otMultiplier: model.otMultiplier,
      latitude: model.latitude,
      longitude: model.longitude,
      distance: model.distance,
      onsite: model.onsite,
      officeName: model.officeName,
      reason: model.reason,
      comment: model.comment,
    );
  }

  static MyAttendanceResult toResult(MyAttendanceResponseModel model) {
    final stats = model.stats;
    return MyAttendanceResult(
      employeeName: model.employeeName,
      records: model.records.map(toEntity).toList(),
      claimedAttendanceIds: model.claimedAttendanceIds,
      stats: stats == null
          ? null
          : AttendanceStats(
              totalRecords: stats.totalRecords,
              onsiteDays: stats.onsiteDays,
              checkedIn: stats.checkedIn,
              fullDays: stats.fullDays,
              otHours: stats.otHours,
              otHoursFormatted: stats.otHoursFormatted,
              claimedOt: stats.claimedOT,
            ),
    );
  }
}
