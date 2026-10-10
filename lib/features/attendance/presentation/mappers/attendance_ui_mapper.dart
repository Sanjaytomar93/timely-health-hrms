import 'package:timelay_health/core/utils/time_format.dart';
import 'package:timelay_health/features/attendance/domain/entities/attendance_record.dart';
import 'package:timelay_health/features/attendance/presentation/models/attendance_record_ui_model.dart';
import 'package:timelay_health/features/dashboard/presentation/models/dashboard_home_ui.dart';

class AttendanceUiMapper {
  const AttendanceUiMapper._();

  static List<AttendanceRecordUiModel> toUiList(
    List<AttendanceRecord> records, {
    Set<String> claimedIds = const {},
  }) {
    return records
        .map((r) => toUi(r, otClaimed: claimedIds.contains(r.id)))
        .toList();
  }

  static AttendanceRecordUiModel toUi(
    AttendanceRecord record, {
    bool otClaimed = false,
  }) {
    final hours = record.workingHours > 0
        ? record.workingHours
        : record.totalHours;
    final shift = record.assignedShiftHours > 0
        ? record.assignedShiftHours.round()
        : 9;
    final isActive = record.isCheckedIn && record.checkOutTime == null;
    final onsite = _isOnsite(record);

    return AttendanceRecordUiModel(
      id: record.id,
      date: _cardDateLabel(record.checkInTime),
      checkInDate: record.checkInTime?.toLocal(),
      statusLabel: isActive ? 'Active' : 'Logged Out',
      isActive: isActive,
      checkIn: _timeLabel(record.checkInTime),
      checkOut: record.checkOutTime == null
          ? '--:--'
          : _timeLabel(record.checkOutTime),
      shiftTag: '${shift}h shift',
      durationTag: _hoursLabel(hours),
      locationTag: onsite
          ? (record.officeName.isNotEmpty
                ? '🏢 ${record.officeName}'
                : '🏢 Onsite')
          : '🏠 WFH',
      distanceTag: '${record.distance.round()}m',
      note: _note(record),
      onsite: onsite,
      workingHours: hours,
      otHours: record.otHours,
      otClaimed: otClaimed,
      claimableOtHours: _claimableOt(record),
      otAmount: record.otAmount,
      otMultiplier: record.otMultiplier,
      assignedShiftHours: record.assignedShiftHours,
      distanceMeters: record.distance,
      exportDate: _exportDateLabel(record.checkInTime),
      exportCheckIn: _exportDateTime(record.checkInTime),
      exportCheckOut: record.checkOutTime == null
          ? '-'
          : _exportDateTime(record.checkOutTime),
      exportStatus: 'Pending',
    );
  }

  static AttendanceStatsUiModel toStats(
    List<AttendanceRecord> records, {
    AttendanceStats? serverStats,
  }) {
    if (serverStats != null) {
      final otLabel = serverStats.otHours > 0
          ? (serverStats.otHoursFormatted.isNotEmpty
                ? serverStats.otHoursFormatted
                : _hoursLabel(serverStats.otHours))
          : '0';
      return AttendanceStatsUiModel(
        totalRecords: serverStats.totalRecords,
        onsiteDays: serverStats.onsiteDays,
        checkedIn: serverStats.checkedIn,
        fullDays: serverStats.fullDays,
        otHours: serverStats.otHours,
        otHoursLabel: otLabel,
        claimedOt: serverStats.claimedOt,
      );
    }

    var onsiteDays = 0;
    var checkedIn = 0;
    var fullDays = 0;

    for (final record in records) {
      if (record.onsite) onsiteDays++;
      if (record.isCheckedIn) checkedIn++;
      final hours = record.workingHours > 0
          ? record.workingHours
          : record.totalHours;
      if (hours >= 8) fullDays++;
    }

    return AttendanceStatsUiModel(
      totalRecords: records.length,
      onsiteDays: onsiteDays,
      checkedIn: checkedIn,
      fullDays: fullDays,
      otHours: 0,
      otHoursLabel: '0',
      claimedOt: 0,
    );
  }

  static DashboardAttendanceBannerUi toBanner({
    required List<AttendanceRecordUiModel> records,
    required String shiftLabel,
  }) {
    final today = DateTime.now();
    AttendanceRecordUiModel? todayRecord;
    for (final r in records) {
      final d = r.checkInDate;
      if (d == null) continue;
      if (d.year == today.year &&
          d.month == today.month &&
          d.day == today.day) {
        if (todayRecord == null ||
            (r.checkInDate != null &&
                todayRecord.checkInDate != null &&
                r.checkInDate!.isAfter(todayRecord.checkInDate!))) {
          todayRecord = r;
        }
      }
    }

    final checkIn = todayRecord?.checkIn;
    final checkOut = todayRecord?.checkOut;
    final shift = TimeFormat.shiftRange(shiftLabel);

    return DashboardAttendanceBannerUi(
      statusLabel: todayRecord == null
          ? 'Not checked in yet'
          : todayRecord.isActive
          ? 'Checked in'
          : 'Checked out',
      isCheckedIn: todayRecord?.isActive == true,
      checkIn: (checkIn == null || checkIn == '--:--') ? '—' : checkIn,
      checkOut: (checkOut == null || checkOut == '--:--') ? '—' : checkOut,
      shift: shift,
    );
  }

  /// OT counts only when worked hours exceed the assigned shift by more than
  /// 30 minutes.
  static double _claimableOt(AttendanceRecord record) {
    if (record.checkOutTime == null) return 0;
    var ot = record.otHours;
    if (ot <= 0) {
      final worked = record.totalHours > record.workingHours
          ? record.totalHours
          : record.workingHours;
      final shift = record.assignedShiftHours > 0
          ? record.assignedShiftHours
          : 9.0;
      ot = worked - shift;
    }
    if (ot <= 0.5) return 0;
    return double.parse(ot.toStringAsFixed(2));
  }

  /// The API sends `onsite: true` for some work-from-home days, so the
  /// check-in reason takes priority.
  static bool _isOnsite(AttendanceRecord record) {
    final reason = record.reason.toLowerCase();
    if (reason.contains('work from home') || reason.contains('wfh')) {
      return false;
    }
    return record.onsite;
  }

  static String _note(AttendanceRecord record) {
    final reason = record.reason.trim();
    if (reason.isNotEmpty) return reason;
    final comment = record.comment.trim();
    if (comment.isNotEmpty) return comment;
    if (record.onsite) return 'Onsite';
    return 'No reason provided';
  }

  static String _cardDateLabel(DateTime? date) {
    if (date == null) return '—';
    final local = date.toLocal();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final day = local.day.toString().padLeft(2, '0');
    return '$day ${months[local.month - 1]} ${local.year}';
  }

  static String _exportDateLabel(DateTime? date) {
    if (date == null) return '-';
    final local = date.toLocal();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sept',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${local.day} ${months[local.month - 1]} ${local.year}';
  }

  static String _exportDateTime(DateTime? date) {
    if (date == null) return '-';
    final local = date.toLocal();
    final d = local.day.toString().padLeft(2, '0');
    final m = local.month.toString().padLeft(2, '0');
    final h = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    final s = local.second.toString().padLeft(2, '0');
    return '$d/$m/${local.year}, $h:$min:$s';
  }

  static String _timeLabel(DateTime? date) =>
      TimeFormat.clock(date, fallback: '--:--');

  static String hoursLabel(double hours) => _hoursLabel(hours);

  static String _hoursLabel(double hours) {
    if (hours <= 0) return '0h 0m';
    final h = hours.floor();
    final m = ((hours - h) * 60).round();
    return '${h}h ${m}m';
  }
}
