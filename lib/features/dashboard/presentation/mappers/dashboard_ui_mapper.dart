import 'package:timelay_health/core/utils/time_format.dart';
import 'package:timelay_health/features/dashboard/domain/entities/employee_dashboard.dart';
import 'package:timelay_health/features/dashboard/presentation/models/dashboard_home_ui.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/stat_cards_row.dart';

class DashboardUiMapper {
  const DashboardUiMapper._();

  static DashboardHomeUi toHomeUi(EmployeeDashboard data) {
    final now = DateTime.now();
    final stats = data.stats;
    final workingDays = stats.totalWorkingDays > 0
        ? stats.totalWorkingDays
        : data.assignedWorkingDays;

    final today = DateTime(now.year, now.month, now.day);
    DashboardAttendanceItem? todayRecord;
    for (final r in data.attendance) {
      final t = r.checkInTime?.toLocal();
      if (t == null) continue;
      final d = DateTime(t.year, t.month, t.day);
      if (d == today) {
        if (todayRecord == null ||
            (r.checkInTime != null &&
                todayRecord.checkInTime != null &&
                r.checkInTime!.isAfter(todayRecord.checkInTime!))) {
          todayRecord = r;
        }
      }
    }
    final shiftTiming = data.shift.shiftTiming.trim().isEmpty
        ? 'Not Assigned'
        : data.shift.shiftTiming.trim();
    final location = data.location.trim().isEmpty
        ? '—'
        : data.location.replaceAll(',', ', ');

    final status = data.status.trim().isEmpty ? 'active' : data.status.trim();
    final statusLabel =
        status[0].toUpperCase() + status.substring(1).toLowerCase();

    return DashboardHomeUi(
      greeting: DashboardGreetingUi(
        greeting: _greetingForHour(now.hour),
        firstName: data.displayFirstName,
        dateLabel: _fullDate(now),
      ),
      profile: DashboardProfileUi(
        initials: data.initials,
        name: data.displayName,
        department: data.department.isEmpty ? '—' : data.department,
        employeeId: data.employeeId.isEmpty ? '—' : data.employeeId,
        statusLabel: statusLabel,
        locationLabel: '📍 $location',
        shiftLabel: '🕒 $shiftTiming',
      ),
      attendanceBanner: DashboardAttendanceBannerUi(
        statusLabel: todayRecord == null
            ? 'Not checked in yet'
            : todayRecord.isCheckedIn
            ? 'Checked in'
            : 'Checked out',
        isCheckedIn: todayRecord?.isCheckedIn == true,
        checkIn: _timeLabel(todayRecord?.checkInTime),
        checkOut: todayRecord?.checkOutTime == null
            ? '—'
            : _timeLabel(todayRecord?.checkOutTime),
        shift: TimeFormat.shiftRange(shiftTiming),
      ),
      statCards: [
        StatCardData(
          title: 'Present',
          value: '${stats.present}',
          subtitle: 'days this month',
          iconAsset: 'assets/icons/stat_cards/ic_stat_present.svg',
        ),
        StatCardData(
          title: 'Absent',
          value: '${stats.absent}',
          subtitle: 'days this month',
          iconAsset: 'assets/icons/stat_cards/ic_stat_absent.svg',
        ),
        StatCardData(
          title: 'Late',
          value: '${stats.late}',
          subtitle: 'instances',
          iconAsset: 'assets/icons/stat_cards/ic_stat_late.svg',
        ),
        StatCardData(
          title: 'Attendance',
          value: '${stats.attendanceRate}%',
          subtitle: 'of $workingDays days',
          iconAsset: 'assets/icons/stat_cards/ic_stat_attendance.svg',
        ),
      ],
      lateMinutes: _fiveWeeks(data.lateGraph),
      absentDays: _absentUi(data),
      recentActivity: _recentActivity(data.attendance),
      updates: _updates(data),
      updatesMonthLabel: _monthYear(now),
    );
  }

  static List<DashboardActivityUi> _recentActivity(
    List<DashboardAttendanceItem> records,
  ) {
    final sorted = [...records]
      ..sort((a, b) {
        final at = a.checkInTime ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bt = b.checkInTime ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bt.compareTo(at);
      });

    return sorted.take(5).map((r) {
      final inLabel = _timeLabel(r.checkInTime);
      final outLabel = r.checkOutTime == null
          ? null
          : _timeLabel(r.checkOutTime);
      final time = outLabel == null ? '$inLabel →' : '$inLabel → $outLabel';
      return DashboardActivityUi(
        date: _shortDate(r.checkInTime),
        time: time,
        isIn: r.isCheckedIn,
      );
    }).toList();
  }

  static List<DashboardUpdateItemUi> _updates(EmployeeDashboard data) {
    final items = <DashboardUpdateItemUi>[];
    final upcoming = data.shift.upcomingShiftLabel?.trim();
    if (upcoming != null && upcoming.isNotEmpty) {
      items.add(
        DashboardUpdateItemUi(
          title: 'Upcoming Shift',
          subtitle: upcoming,
          kind: 'shift',
        ),
      );
    } else if (data.shift.shiftTiming.trim().isNotEmpty &&
        data.shift.shiftTiming != 'Not Assigned') {
      items.add(
        DashboardUpdateItemUi(
          title: 'Current Shift',
          subtitle: data.shift.shiftTiming,
          kind: 'shift',
        ),
      );
    }

    for (final b in data.birthdaysToday) {
      if (b.name.trim().isEmpty) continue;
      items.add(
        DashboardUpdateItemUi(
          title: 'Birthday Today',
          subtitle: b.detail?.isNotEmpty == true
              ? '${b.name} · ${b.detail}'
              : b.name,
          kind: 'birthday',
        ),
      );
    }
    for (final a in data.anniversariesToday) {
      if (a.name.trim().isEmpty) continue;
      items.add(
        DashboardUpdateItemUi(
          title: 'Work Anniversary',
          subtitle: a.detail?.isNotEmpty == true
              ? '${a.name} · ${a.detail}'
              : a.name,
          kind: 'anniversary',
        ),
      );
    }
    for (final l in data.leavesToday) {
      if (l.name.trim().isEmpty) continue;
      items.add(
        DashboardUpdateItemUi(
          title: 'On Leave Today',
          subtitle: l.detail?.isNotEmpty == true
              ? '${l.name} · ${l.detail}'
              : l.name,
          kind: 'leave',
        ),
      );
    }
    return items;
  }

  static List<double> _fiveWeeks(List<double> values) {
    return List<double>.generate(5, (i) => i < values.length ? values[i] : 0);
  }

  static DashboardAbsentUi _absentUi(EmployeeDashboard data) {
    final graph = data.absentGraph;
    final weeks = graph.weeks;
    final weekAbsent = weeks.fold<int>(0, (a, w) => a + w.absentDays);
    final weekWorking = weeks.fold<int>(0, (a, w) => a + w.workingDays);

    final start = graph.periodStart;
    final end = graph.periodEnd;
    final period = start != null && end != null
        ? '${_dayMonth(start)} – ${_dayMonth(end)} ${end.year}'
        : '';

    return DashboardAbsentUi(
      periodLabel: period,
      totalAbsent: graph.totalAbsent > 0
          ? graph.totalAbsent
          : (weeks.isEmpty ? data.stats.absent : weekAbsent),
      totalWorkingDays: graph.totalWorkingDays > 0
          ? graph.totalWorkingDays
          : (weekWorking > 0 ? weekWorking : data.stats.totalWorkingDays),
      weeks: weeks
          .map(
            (w) => DashboardAbsentWeekUi(
              label: 'Week ${w.week}',
              dateRange: w.startDate != null && w.endDate != null
                  ? '${_dayMonth(w.startDate!)} – ${_dayMonth(w.endDate!)}'
                  : '',
              workingDays: w.workingDays,
              absentDays: w.absentDays,
            ),
          )
          .toList(),
    );
  }

  static String _dayMonth(DateTime date) {
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
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]}';
  }

  static String _greetingForHour(int hour) {
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  static String _fullDate(DateTime date) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
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
    final local = date.toLocal();
    return '${weekdays[local.weekday - 1]}, ${months[local.month - 1]} ${local.day}, ${local.year}';
  }

  static String _monthYear(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final local = date.toLocal();
    return '${months[local.month - 1]} ${local.year}';
  }

  static String _timeLabel(DateTime? date) => TimeFormat.clock(date);

  static String _shortDate(DateTime? date) {
    if (date == null) return '—';
    final local = date.toLocal();
    final d = local.day.toString().padLeft(2, '0');
    final m = local.month.toString().padLeft(2, '0');
    return '$d/$m/${local.year}';
  }
}
