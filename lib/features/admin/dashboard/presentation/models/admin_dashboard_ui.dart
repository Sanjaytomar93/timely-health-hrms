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
    required this.fraction,
  });

  final String label;
  final int count;
  final String percentLabel;
  final Color color;
  final double fraction;
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
    this.subtitle = '',
  });

  final String name;
  final double percent;
  final String initials;
  final String subtitle;
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
    required this.id,
    required this.name,
    required this.initials,
    required this.dates,
    required this.type,
    this.duration = '1d',
  });

  final String id;
  final String name;
  final String initials;
  final String dates;
  final String type;
  final String duration;
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
    required this.attendanceRate,
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
  final double attendanceRate;
  final List<AdminExceptionItem> exceptions;
  final List<AdminPerformerItem> topPerformers;
  final List<AdminStreakItem> streaks;
  final List<AdminDeptItem> departments;
  final List<AdminHolidayDot> holidayDots;
  final List<AdminTrendPoint> trend;
  final List<AdminLeaveRequestItem> pendingLeaves;

  static const empty = AdminDashboardUi(
    metrics: [],
    todaySlices: [],
    heatmap: [],
    presentNow: 0,
    lateNow: 0,
    onLeaveNow: 0,
    absentNow: 0,
    totalStaff: 0,
    attendanceRate: 0,
    exceptions: [],
    topPerformers: [],
    streaks: [],
    departments: [],
    holidayDots: [],
    trend: [],
    pendingLeaves: [],
  );

  factory AdminDashboardUi.fromApiJson(
    Map<String, dynamic> data, {
    required int month,
    required int year,
  }) {
    final stats = _asMap(data['stats']);
    final total = _asInt(stats['totalEmployees']);
    final present = _asInt(stats['presentToday']);
    final absent = _asInt(stats['absentToday']);
    final late = _asInt(stats['lateToday']);
    final onTime = _asInt(stats['onTimeToday']);
    final forgotCheckout = _asInt(stats['forgotCheckoutToday']);
    final rate = _asDouble(stats['attendanceRate']);
    final now = DateTime.now();
    final today = _parseDateOnly(stats['latestDate']?.toString()) ??
        DateTime(now.year, now.month, now.day);
    final onLeaveFromLeaves = _countOnLeaveToday(data['leaves'], today);
    final onLeaveStat = _asInt(stats['onLeaveToday']);
    final onLeave = onLeaveFromLeaves > 0 ? onLeaveFromLeaves : onLeaveStat;

    String pct(num value) => '${value.toStringAsFixed(1)}%';
    double ofTotal(int count) => total <= 0 ? 0 : (count / total) * 100;
    double ofPresent(int count) =>
        present <= 0 ? 0 : (count / present) * 100;

    final presentPct = ofTotal(present);
    final onTimePct = ofPresent(onTime);
    final latePct = ofPresent(late);
    final absentPct = ofTotal(absent);
    final onLeavePct = ofTotal(onLeave);

    final metrics = [
      AdminStatMetric(
        title: 'Total Staff',
        value: '$total',
        subtitle: 'active employees',
        icon: Icons.groups_rounded,
        color: const Color(0xFF6366F1),
      ),
      AdminStatMetric(
        title: 'PRESENT TODAY',
        value: '$present',
        subtitle: 'employees present',
        icon: Icons.how_to_reg_outlined,
        color: const Color(0xFF10B981),
      ),
      AdminStatMetric(
        title: 'ABSENT TODAY',
        value: '$absent',
        subtitle: 'absent employees',
        icon: Icons.person_remove_outlined,
        color: const Color(0xFFEF4444),
      ),
      AdminStatMetric(
        title: 'LATE ARRIVAL',
        value: '$late',
        subtitle: 'late arrivals',
        icon: Icons.access_time_rounded,
        color: const Color(0xFFF59E0B),
      ),
      AdminStatMetric(
        title: 'ATTENDANCE RATE',
        value: pct(rate),
        subtitle: 'overall rate',
        icon: Icons.trending_up_rounded,
        color: const Color(0xFF3B82F6),
      ),
    ];

    final todaySlices = [
      AdminAttendanceSlice(
        label: 'Present',
        count: present,
        percentLabel: pct(presentPct),
        color: const Color(0xFF10B981),
        fraction: presentPct / 100,
      ),
      AdminAttendanceSlice(
        label: 'On-Time',
        count: onTime,
        percentLabel: pct(onTimePct),
        color: const Color(0xFF06B6D4),
        fraction: onTimePct / 100,
      ),
      AdminAttendanceSlice(
        label: 'Late',
        count: late,
        percentLabel: pct(latePct),
        color: const Color(0xFFF59E0B),
        fraction: latePct / 100,
      ),
      AdminAttendanceSlice(
        label: 'Absent',
        count: absent,
        percentLabel: pct(absentPct),
        color: const Color(0xFFEF4444),
        fraction: absentPct / 100,
      ),
      AdminAttendanceSlice(
        label: 'On Leave',
        count: onLeave,
        percentLabel: pct(onLeavePct),
        color: const Color(0xFF93C5FD),
        fraction: onLeavePct / 100,
      ),
    ];

    final daysInMonth = DateTime(year, month + 1, 0).day;
    final heatmap = List<double>.filled(daysInMonth, 0);
    final grid = data['heatmapGrid'];
    if (grid is List) {
      for (final week in grid) {
        if (week is! List) continue;
        for (final cell in week) {
          if (cell is! Map) continue;
          final day = _asInt(cell['day']);
          if (day < 1 || day > daysInMonth) continue;
          heatmap[day - 1] = (_asDouble(cell['rate']) / 100).clamp(0.0, 1.0);
        }
      }
    }

    final holidayDots = <AdminHolidayDot>[];
    final holidays = data['holidays'];
    if (holidays is List) {
      for (final raw in holidays) {
        if (raw is! Map) continue;
        final from = DateTime.tryParse(raw['fromDate']?.toString() ?? '');
        final to = DateTime.tryParse(raw['toDate']?.toString() ?? '') ?? from;
        if (from == null || to == null) continue;
        var cursor = DateTime(from.year, from.month, from.day);
        final end = DateTime(to.year, to.month, to.day);
        while (!cursor.isAfter(end)) {
          if (cursor.year == year && cursor.month == month) {
            holidayDots.add(
              AdminHolidayDot(day: cursor.day, color: PortalColors.orange),
            );
          }
          cursor = cursor.add(const Duration(days: 1));
        }
      }
    }

    final topPerformers = <AdminPerformerItem>[];
    final performers = data['topPerformers'];
    if (performers is List) {
      for (final raw in performers) {
        if (raw is! Map) continue;
        final name = raw['name']?.toString().trim() ?? '';
        if (name.isEmpty) continue;
        topPerformers.add(
          AdminPerformerItem(
            name: name,
            percent: _asDouble(
              raw['performancePercentage'] ?? raw['rate'],
            ),
            initials: _initials(name),
            subtitle: raw['department']?.toString().trim() ?? '',
          ),
        );
      }
    }

    final streaks = <AdminStreakItem>[];
    final streakRaw = data['attendanceStreaks'];
    if (streakRaw is List) {
      for (final raw in streakRaw) {
        if (raw is! Map) continue;
        final name = raw['name']?.toString().trim() ?? '';
        if (name.isEmpty) continue;
        streaks.add(
          AdminStreakItem(
            name: name,
            days: _asInt(raw['streak']),
            initials: _initials(name),
          ),
        );
      }
    }

    final departments = <AdminDeptItem>[];
    final deptRaw = data['departmentPerformance'];
    if (deptRaw is List) {
      for (final raw in deptRaw) {
        if (raw is! Map) continue;
        final name = raw['name']?.toString().trim() ?? '';
        if (name.isEmpty) continue;
        departments.add(
          AdminDeptItem(
            name: name,
            percent: _asDouble(raw['rate']),
            color: _parseColor(raw['color']?.toString()) ??
                const Color(0xFFF59E0B),
          ),
        );
      }
    }

    final trend = <AdminTrendPoint>[];
    final trendRaw = data['monthlyTrend'];
    if (trendRaw is List) {
      for (final raw in trendRaw) {
        if (raw is! Map) continue;
        final label = raw['month']?.toString().trim() ?? '';
        if (label.isEmpty) continue;
        trend.add(
          AdminTrendPoint(
            label: label,
            attendance: _asDouble(raw['rate']),
            leave: _asDouble(raw['leavesDays'] ?? raw['leavesCount']),
          ),
        );
      }
    }

    final pendingLeaves = <AdminLeaveRequestItem>[];
    final pendingRaw = data['pendingLeaveRequests'];
    if (pendingRaw is List) {
      for (final raw in pendingRaw) {
        if (raw is! Map) continue;
        final name = raw['employeeName']?.toString().trim() ?? '';
        if (name.isEmpty) continue;
        final start = raw['startDate']?.toString() ?? '';
        final end = raw['endDate']?.toString() ?? start;
        final days = _asInt(raw['days']);
        pendingLeaves.add(
          AdminLeaveRequestItem(
            id: raw['_id']?.toString() ?? '',
            name: name,
            initials: _initials(name),
            dates: _formatLeaveDates(start, end),
            type: (raw['leaveType']?.toString() ?? 'LEAVE').toUpperCase(),
            duration: days > 0 ? '${days}d' : '1d',
          ),
        );
      }
    }

    return AdminDashboardUi(
      metrics: metrics,
      todaySlices: todaySlices,
      heatmap: heatmap,
      presentNow: present,
      lateNow: late,
      onLeaveNow: onLeave,
      absentNow: absent,
      totalStaff: total,
      attendanceRate: rate,
      exceptions: [
        AdminExceptionItem(
          label: 'Not checked in',
          count: absent,
          icon: Icons.person_outline_rounded,
          color: const Color(0xFFEF4444),
        ),
        AdminExceptionItem(
          label: 'Late arrivals',
          count: late,
          icon: Icons.access_time_rounded,
          color: const Color(0xFFF59E0B),
        ),
        AdminExceptionItem(
          label: 'Forgot check-out',
          count: forgotCheckout,
          icon: Icons.logout_rounded,
          color: const Color(0xFF3B82F6),
        ),
        AdminExceptionItem(
          label: 'On leave today',
          count: onLeave,
          icon: Icons.beach_access_rounded,
          color: const Color(0xFF94A3B8),
        ),
      ],
      topPerformers: topPerformers,
      streaks: streaks,
      departments: departments,
      holidayDots: holidayDots,
      trend: trend,
      pendingLeaves: pendingLeaves,
    );
  }

  static DateTime? _parseDateOnly(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final dt = DateTime.tryParse(raw.trim());
    if (dt == null) return null;
    return DateTime(dt.year, dt.month, dt.day);
  }

  static int _countOnLeaveToday(dynamic leavesRaw, DateTime today) {
    if (leavesRaw is! List) return 0;
    final ids = <String>{};
    for (final raw in leavesRaw) {
      if (raw is! Map) continue;
      final status = (raw['status']?.toString() ?? '').toLowerCase();
      if (!status.contains('approv')) continue;
      final start = _parseDateOnly(raw['startDate']?.toString());
      final end =
          _parseDateOnly(raw['endDate']?.toString()) ?? start;
      if (start == null || end == null) continue;
      if (today.isBefore(start) || today.isAfter(end)) continue;
      final empId = (raw['employeeId']?.toString() ?? '').trim();
      final key = empId.isNotEmpty
          ? empId.toLowerCase()
          : (raw['_id']?.toString() ?? raw['employeeName']?.toString() ?? '');
      if (key.isEmpty) continue;
      ids.add(key);
    }
    return ids.length;
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return const {};
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final p = parts.first;
      return (p.length >= 2 ? p.substring(0, 2) : p).toUpperCase();
    }
    return ('${parts.first[0]}${parts.last[0]}').toUpperCase();
  }

  static Color? _parseColor(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    var hex = raw.trim();
    if (hex.startsWith('#')) hex = hex.substring(1);
    if (hex.length == 6) hex = 'FF$hex';
    final value = int.tryParse(hex, radix: 16);
    if (value == null) return null;
    return Color(value);
  }

  static String _formatLeaveDates(String start, String end) {
    String fmt(String iso) {
      final d = DateTime.tryParse(iso);
      if (d == null) return iso;
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${months[d.month - 1]} ${d.day}, ${d.year}';
    }

    final s = fmt(start);
    final e = fmt(end);
    if (start == end || e.isEmpty) return s;
    return '$s - $e';
  }
}
