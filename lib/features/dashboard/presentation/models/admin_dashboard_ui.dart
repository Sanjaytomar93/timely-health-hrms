import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';

class AdminStatMetric {
  const AdminStatMetric({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
}

class AdminAttendanceSlice {
  const AdminAttendanceSlice({
    required this.label,
    required this.count,
    required this.percentLabel,
    required this.color,
  });

  final String label;
  final int count;
  final String percentLabel;
  final Color color;
}

class AdminExceptionItem {
  const AdminExceptionItem({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
  });

  final String label;
  final int count;
  final IconData icon;
  final Color color;
}

class AdminPerformerItem {
  const AdminPerformerItem({
    required this.name,
    required this.percent,
    required this.initials,
  });

  final String name;
  final double percent;
  final String initials;
}

class AdminStreakItem {
  const AdminStreakItem({
    required this.name,
    required this.days,
    required this.initials,
  });

  final String name;
  final int days;
  final String initials;
}

class AdminDeptItem {
  const AdminDeptItem({
    required this.name,
    required this.percent,
    required this.color,
  });

  final String name;
  final double percent;
  final Color color;
}

class AdminHolidayDot {
  const AdminHolidayDot({required this.day, required this.color});

  final int day;
  final Color color;
}

class AdminTrendPoint {
  const AdminTrendPoint({
    required this.label,
    required this.attendance,
    required this.leave,
  });

  final String label;
  final double attendance;
  final double leave;
}

class AdminLeaveRequestItem {
  const AdminLeaveRequestItem({
    required this.name,
    required this.initials,
    required this.dates,
    required this.type,
  });

  final String name;
  final String initials;
  final String dates;
  final String type;
}

class AdminDashboardUi {
  const AdminDashboardUi({
    required this.metrics,
    required this.todaySlices,
    required this.heatmap,
    required this.presentNow,
    required this.lateNow,
    required this.onLeaveNow,
    required this.absentNow,
    required this.totalStaff,
    required this.exceptions,
    required this.topPerformers,
    required this.streaks,
    required this.departments,
    required this.holidayDots,
    required this.trend,
    required this.pendingLeaves,
  });

  final List<AdminStatMetric> metrics;
  final List<AdminAttendanceSlice> todaySlices;
  final List<double> heatmap;
  final int presentNow;
  final int lateNow;
  final int onLeaveNow;
  final int absentNow;
  final int totalStaff;
  final List<AdminExceptionItem> exceptions;
  final List<AdminPerformerItem> topPerformers;
  final List<AdminStreakItem> streaks;
  final List<AdminDeptItem> departments;
  final List<AdminHolidayDot> holidayDots;
  final List<AdminTrendPoint> trend;
  final List<AdminLeaveRequestItem> pendingLeaves;

  static AdminDashboardUi sample(DateTime month) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final heatmap = List<double>.generate(daysInMonth, (i) {
      final seed = (i * 17 + month.month * 3) % 10;
      if (seed < 2) return 0.2;
      if (seed < 5) return 0.45;
      if (seed < 8) return 0.7;
      return 0.95;
    });

    return AdminDashboardUi(
      metrics: const [
        AdminStatMetric(
          title: 'Total Staff',
          value: '27',
          subtitle: 'active employees',
          icon: Icons.groups_rounded,
          color: PortalColors.brandLight,
        ),
        AdminStatMetric(
          title: 'Present Today',
          value: '13',
          subtitle: 'checked in',
          icon: Icons.directions_walk_rounded,
          color: PortalColors.green,
        ),
        AdminStatMetric(
          title: 'Absent Today',
          value: '14',
          subtitle: 'not checked in',
          icon: Icons.person_off_outlined,
          color: PortalColors.red,
        ),
        AdminStatMetric(
          title: 'Late Arrival',
          value: '8',
          subtitle: 'late today',
          icon: Icons.schedule_rounded,
          color: PortalColors.orange,
        ),
        AdminStatMetric(
          title: 'Attendance Rate',
          value: '48.1%',
          subtitle: 'overall rate',
          icon: Icons.pie_chart_outline_rounded,
          color: PortalColors.brand,
        ),
      ],
      todaySlices: const [
        AdminAttendanceSlice(
          label: 'Present',
          count: 13,
          percentLabel: '48.1%',
          color: PortalColors.green,
        ),
        AdminAttendanceSlice(
          label: 'On Time',
          count: 5,
          percentLabel: '18.5%',
          color: PortalColors.brandLight,
        ),
        AdminAttendanceSlice(
          label: 'Late',
          count: 8,
          percentLabel: '29.6%',
          color: PortalColors.orange,
        ),
        AdminAttendanceSlice(
          label: 'Absent',
          count: 14,
          percentLabel: '51.9%',
          color: PortalColors.red,
        ),
        AdminAttendanceSlice(
          label: 'On Leave',
          count: 0,
          percentLabel: '0%',
          color: Color(0xFF7E57C2),
        ),
      ],
      heatmap: heatmap,
      presentNow: 13,
      lateNow: 8,
      onLeaveNow: 0,
      absentNow: 14,
      totalStaff: 27,
      exceptions: const [
        AdminExceptionItem(
          label: 'Not checked in',
          count: 14,
          icon: Icons.login_rounded,
          color: PortalColors.red,
        ),
        AdminExceptionItem(
          label: 'Late arrivals',
          count: 8,
          icon: Icons.schedule_rounded,
          color: PortalColors.orange,
        ),
        AdminExceptionItem(
          label: 'Forgot checkout',
          count: 11,
          icon: Icons.logout_rounded,
          color: PortalColors.brandLight,
        ),
        AdminExceptionItem(
          label: 'On leave today',
          count: 0,
          icon: Icons.beach_access_rounded,
          color: Color(0xFF7E57C2),
        ),
      ],
      topPerformers: const [
        AdminPerformerItem(
          name: 'Chittikela Swathi',
          percent: 95.20,
          initials: 'CS',
        ),
        AdminPerformerItem(
          name: 'K Akhil Kumar',
          percent: 93.11,
          initials: 'KA',
        ),
        AdminPerformerItem(
          name: 'Priya Sharma',
          percent: 91.40,
          initials: 'PS',
        ),
        AdminPerformerItem(
          name: 'Rahul Verma',
          percent: 88.60,
          initials: 'RV',
        ),
      ],
      streaks: const [
        AdminStreakItem(name: 'K Akhil Kumar', days: 6, initials: 'KA'),
        AdminStreakItem(name: 'Chittikela Swathi', days: 5, initials: 'CS'),
        AdminStreakItem(name: 'Neha Patel', days: 4, initials: 'NP'),
        AdminStreakItem(name: 'Amit Singh', days: 3, initials: 'AS'),
      ],
      departments: const [
        AdminDeptItem(
          name: 'Management',
          percent: 56.77,
          color: PortalColors.brand,
        ),
        AdminDeptItem(
          name: 'Laboratory Medicine',
          percent: 52.40,
          color: PortalColors.green,
        ),
        AdminDeptItem(
          name: 'Sales',
          percent: 48.90,
          color: PortalColors.orange,
        ),
        AdminDeptItem(
          name: 'Developer',
          percent: 45.20,
          color: PortalColors.brandLight,
        ),
        AdminDeptItem(
          name: 'Marketing',
          percent: 41.80,
          color: PortalColors.red,
        ),
      ],
      holidayDots: const [
        AdminHolidayDot(day: 2, color: PortalColors.orange),
        AdminHolidayDot(day: 14, color: PortalColors.red),
        AdminHolidayDot(day: 21, color: PortalColors.green),
        AdminHolidayDot(day: 28, color: Color(0xFF7E57C2)),
      ],
      trend: const [
        AdminTrendPoint(label: 'Jan', attendance: 0, leave: 16),
        AdminTrendPoint(label: 'Feb', attendance: 0, leave: 8),
        AdminTrendPoint(label: 'Mar', attendance: 0, leave: 6),
        AdminTrendPoint(label: 'Apr', attendance: 0, leave: 14),
        AdminTrendPoint(label: 'May', attendance: 0, leave: 12),
        AdminTrendPoint(label: 'Jun', attendance: 0, leave: 15),
        AdminTrendPoint(label: 'Jul', attendance: 0, leave: 4),
        AdminTrendPoint(label: 'Aug', attendance: 0, leave: 5),
        AdminTrendPoint(label: 'Sep', attendance: 8, leave: 7),
        AdminTrendPoint(label: 'Oct', attendance: 14, leave: 6),
        AdminTrendPoint(label: 'Nov', attendance: 20, leave: 3),
      ],
      pendingLeaves: const [
        AdminLeaveRequestItem(
          name: 'Ananya Reddy',
          initials: 'AR',
          dates: '12–14 Nov',
          type: 'Casual Leave',
        ),
        AdminLeaveRequestItem(
          name: 'Vikram Rao',
          initials: 'VR',
          dates: '18 Nov',
          type: 'Sick Leave',
        ),
        AdminLeaveRequestItem(
          name: 'Sneha Iyer',
          initials: 'SI',
          dates: '20–21 Nov',
          type: 'Comp Off',
        ),
      ],
    );
  }
}
