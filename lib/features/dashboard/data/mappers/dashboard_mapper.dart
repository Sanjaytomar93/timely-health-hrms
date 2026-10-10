import 'package:timelay_health/features/dashboard/data/models/employee_dashboard_model.dart';
import 'package:timelay_health/features/dashboard/domain/entities/employee_dashboard.dart';

class DashboardMapper {
  const DashboardMapper._();

  static EmployeeDashboard toEntity(EmployeeDashboardModel model) {
    return EmployeeDashboard(
      employeeId: model.employeeId,
      name: model.name,
      firstName: model.firstName,
      lastName: model.lastName,
      department: model.department,
      role: model.role,
      status: model.status,
      location: model.location,
      shift: DashboardShiftInfo(
        shiftTiming: model.shift.shiftTiming,
        upcomingShiftLabel: model.shift.upcomingShiftLabel,
      ),
      attendance: model.attendance
          .map(
            (e) => DashboardAttendanceItem(
              id: e.id,
              checkInTime: e.checkInTime,
              checkOutTime: e.checkOutTime,
              status: e.status,
              dayType: e.dayType,
              totalHours: e.totalHours,
              workingHours: e.workingHours,
              onsite: e.onsite,
              officeName: e.officeName,
              reason: e.reason,
            ),
          )
          .toList(),
      leaves: model.leaves
          .map(
            (e) => DashboardLeaveItem(
              id: e.id,
              leaveType: e.leaveType,
              status: e.status,
              days: e.days,
              reason: e.reason,
              startDate: e.startDate,
              endDate: e.endDate,
              employeeName: e.employeeName,
            ),
          )
          .toList(),
      birthdaysToday: model.birthdaysToday
          .map((e) => DashboardPersonEvent(name: e.name, detail: e.detail))
          .toList(),
      anniversariesToday: model.anniversariesToday
          .map((e) => DashboardPersonEvent(name: e.name, detail: e.detail))
          .toList(),
      leavesToday: model.leavesToday
          .map((e) => DashboardPersonEvent(name: e.name, detail: e.detail))
          .toList(),
      assignedWorkingDays: model.assignedWorkingDays,
      initials: _initials(model.name, model.firstName, model.lastName),
      stats: DashboardStats(
        present: model.stats.present,
        absent: model.stats.absent,
        late: model.stats.late,
        totalWorkingDays: model.stats.totalWorkingDays,
        attendanceRate: model.stats.attendanceRate,
      ),
      lateGraph: model.lateGraph,
      absentGraph: DashboardAbsentGraph(
        periodStart: model.absentGraph.periodStart,
        periodEnd: model.absentGraph.periodEnd,
        totalAbsent: model.absentGraph.totalAbsent,
        totalWorkingDays: model.absentGraph.totalWorkingDays,
        weeks: model.absentGraph.weeks
            .map(
              (e) => DashboardAbsentWeek(
                week: e.week,
                startDate: e.startDate,
                endDate: e.endDate,
                workingDays: e.workingDays,
                absentDays: e.absentDays,
              ),
            )
            .toList(),
      ),
    );
  }

  static String _initials(String name, String first, String last) {
    final f = first.trim();
    final l = last.trim();
    if (f.isNotEmpty && l.isNotEmpty) {
      return '${f[0]}${l[0]}'.toUpperCase();
    }
    final parts = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty);
    final list = parts.toList();
    if (list.isEmpty) return '?';
    if (list.length == 1) return list.first[0].toUpperCase();
    return '${list.first[0]}${list.last[0]}'.toUpperCase();
  }
}
