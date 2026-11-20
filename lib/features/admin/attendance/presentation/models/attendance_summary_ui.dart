import 'package:flutter/material.dart';

enum AttendanceBadge {
  fullDay,
  noAttendance,
  singlePunch,
  earlyLeave,
}

class AttendanceSummaryMeta {
  const AttendanceSummaryMeta({
    required this.totalEmployees,
    required this.totalRecords,
    required this.holidays,
    required this.departments,
    required this.designations,
  });

  final int totalEmployees;
  final int totalRecords;
  final int holidays;
  final List<String> departments;
  final List<String> designations;

  static const empty = AttendanceSummaryMeta(
    totalEmployees: 0,
    totalRecords: 0,
    holidays: 0,
    departments: [],
    designations: [],
  );

  factory AttendanceSummaryMeta.fromJson(Map<String, dynamic>? json) {
    if (json == null) return empty;
    return AttendanceSummaryMeta(
      totalEmployees: (json['totalEmployees'] as num?)?.toInt() ?? 0,
      totalRecords: (json['totalRecords'] as num?)?.toInt() ?? 0,
      holidays: (json['holidays'] as num?)?.toInt() ?? 0,
      departments: (json['departments'] as List<dynamic>?)
              ?.map((e) => e.toString().trim())
              .where((e) => e.isNotEmpty)
              .toList() ??
          const [],
      designations: (json['designations'] as List<dynamic>?)
              ?.map((e) => e.toString().trim())
              .where((e) => e.isNotEmpty)
              .toList() ??
          const [],
    );
  }
}

class AttendanceSummaryStats {
  const AttendanceSummaryStats({
    required this.totalEmployees,
    required this.avgWorkDays,
    required this.totalOnsite,
    required this.totalLateDays,
    required this.totalOvertime,
  });

  final int totalEmployees;
  final double avgWorkDays;
  final int totalOnsite;
  final int totalLateDays;
  final String totalOvertime;

  static const empty = AttendanceSummaryStats(
    totalEmployees: 0,
    avgWorkDays: 0,
    totalOnsite: 0,
    totalLateDays: 0,
    totalOvertime: '0h 0m',
  );
}

class AttendanceRosterItem {
  const AttendanceRosterItem({
    required this.name,
    required this.employeeId,
    required this.role,
    required this.department,
    required this.badge,
    required this.present,
    required this.late,
    required this.onSite,
    required this.remote,
    required this.halfDay,
    required this.fullDay,
    required this.otHours,
    required this.workDays,
    required this.avatarColor,
  });

  final String name;
  final String employeeId;
  final String role;
  final String department;
  final AttendanceBadge badge;
  final int present;
  final int late;
  final int onSite;
  final int remote;
  final int halfDay;
  final int fullDay;
  final double otHours;
  final double workDays;
  final Color avatarColor;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final s = parts.first;
      return (s.length >= 2 ? s.substring(0, 2) : s).toUpperCase();
    }
    return ('${parts.first[0]}${parts.last[0]}').toUpperCase();
  }

  String get badgeLabel => switch (badge) {
        AttendanceBadge.fullDay => 'Full Day',
        AttendanceBadge.noAttendance => 'No Attendance',
        AttendanceBadge.singlePunch => 'Single Punch',
        AttendanceBadge.earlyLeave => 'Early Leave',
      };

  static AttendanceBadge parseBadge(String? status) {
    final s =
        status?.toLowerCase().replaceAll('_', '').replaceAll(' ', '') ?? '';
    if (s == 'fullday') return AttendanceBadge.fullDay;
    if (s == 'singlepunch') return AttendanceBadge.singlePunch;
    if (s == 'earlylogout' || s == 'earlyleave') {
      return AttendanceBadge.earlyLeave;
    }
    return AttendanceBadge.noAttendance;
  }

  static Color colorFor(String seed) {
    const palette = <Color>[
      Color(0xFF7C6FD6),
      Color(0xFFE07A9A),
      Color(0xFF4DB6A0),
      Color(0xFF5B8DEF),
      Color(0xFFD4A017),
      Color(0xFF9B6B9E),
      Color(0xFF3D8B8B),
      Color(0xFF6C7AE0),
      Color(0xFFE67E22),
      Color(0xFF2E7D32),
      Color(0xFF8E44AD),
      Color(0xFF16A085),
    ];
    if (seed.isEmpty) return palette.first;
    return palette[seed.hashCode.abs() % palette.length];
  }

  factory AttendanceRosterItem.fromJson(Map<String, dynamic> json) {
    final name = (json['name'] ?? '').toString().trim();
    final employeeId = (json['employeeId'] ?? '').toString().trim();
    final role = (json['designation'] ?? json['role'] ?? 'Staff')
        .toString()
        .trim();
    final department = (json['department'] ?? 'General').toString().trim();

    final badge = parseBadge(
      json['latestStatus']?.toString() ??
          json['latestStatusMessage']?.toString() ??
          json['status']?.toString(),
    );

    final present = (json['presentDays'] as num?)?.toInt() ?? 0;
    final late = (json['lateDays'] as num?)?.toInt() ?? 0;
    final onSite = (json['onsiteDays'] as num?)?.toInt() ?? 0;
    final remote = (json['remoteDays'] as num?)?.toInt() ?? 0;
    final halfDay = (json['halfDays'] as num?)?.toInt() ?? 0;
    final fullDay = (json['fullDays'] as num?)?.toInt() ?? 0;
    final otHours = (json['overTimeHours'] as num?)?.toDouble() ?? 0.0;
    final workDays = (json['workingDays'] as num?)?.toDouble() ?? 0.0;

    final avatarColor = colorFor(employeeId.isNotEmpty ? employeeId : name);

    return AttendanceRosterItem(
      name: name.isEmpty ? 'Unnamed Employee' : name,
      employeeId: employeeId.isEmpty ? 'N/A' : employeeId,
      role: role.isEmpty ? 'Staff' : role,
      department: department.isEmpty ? 'General' : department,
      badge: badge,
      present: present,
      late: late,
      onSite: onSite,
      remote: remote,
      halfDay: halfDay,
      fullDay: fullDay,
      otHours: otHours,
      workDays: workDays,
      avatarColor: avatarColor,
    );
  }
}

class AttendanceSummaryUi {
  const AttendanceSummaryUi({
    required this.stats,
    required this.roster,
    this.meta = AttendanceSummaryMeta.empty,
    this.month = '',
  });

  final AttendanceSummaryStats stats;
  final List<AttendanceRosterItem> roster;
  final AttendanceSummaryMeta meta;
  final String month;

  static const empty = AttendanceSummaryUi(
    stats: AttendanceSummaryStats.empty,
    roster: [],
  );

  factory AttendanceSummaryUi.fromApiJson(Map<String, dynamic> json) {
    final meta = AttendanceSummaryMeta.fromJson(
      json['meta'] as Map<String, dynamic>?,
    );

    final rawEmps = json['employees'];
    final roster = <AttendanceRosterItem>[];
    if (rawEmps is List) {
      for (final item in rawEmps) {
        if (item is Map) {
          roster.add(
            AttendanceRosterItem.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    final totalEmployees =
        meta.totalEmployees > 0 ? meta.totalEmployees : roster.length;
    final totalWorkDays =
        roster.fold<double>(0.0, (sum, e) => sum + e.workDays);
    final avgWorkDays =
        roster.isNotEmpty ? (totalWorkDays / roster.length) : 0.0;
    final totalOnsite = roster.fold<int>(0, (sum, e) => sum + e.onSite);
    final totalLateDays = roster.fold<int>(0, (sum, e) => sum + e.late);
    final totalOtHours =
        roster.fold<double>(0.0, (sum, e) => sum + e.otHours);

    final otH = totalOtHours.toInt();
    final otM = ((totalOtHours - otH) * 60).round();
    final totalOvertime = '${otH}h ${otM}m';

    final stats = AttendanceSummaryStats(
      totalEmployees: totalEmployees,
      avgWorkDays: double.parse(avgWorkDays.toStringAsFixed(1)),
      totalOnsite: totalOnsite,
      totalLateDays: totalLateDays,
      totalOvertime: totalOvertime,
    );

    return AttendanceSummaryUi(
      stats: stats,
      roster: roster,
      meta: meta,
      month: json['month']?.toString() ?? '',
    );
  }

  static AttendanceSummaryUi sample() {
    return const AttendanceSummaryUi(
      stats: AttendanceSummaryStats(
        totalEmployees: 25,
        avgWorkDays: 8.3,
        totalOnsite: 203,
        totalLateDays: 3,
        totalOvertime: '57h 1m',
      ),
      roster: [
        AttendanceRosterItem(
          name: 'G NARESH KUMAR',
          employeeId: 'TR001',
          role: 'Phlebotomist',
          department: 'Consultant',
          badge: AttendanceBadge.fullDay,
          present: 9,
          late: 0,
          onSite: 9,
          remote: 0,
          halfDay: 0,
          fullDay: 9,
          otHours: 2.0,
          workDays: 9.0,
          avatarColor: Color(0xFF4DB6A0),
        ),
        AttendanceRosterItem(
          name: 'Aarif',
          employeeId: 'T1158',
          role: 'Pharmacist',
          department: 'Medical',
          badge: AttendanceBadge.noAttendance,
          present: 0,
          late: 0,
          onSite: 0,
          remote: 0,
          halfDay: 0,
          fullDay: 0,
          otHours: 0,
          workDays: 0,
          avatarColor: Color(0xFF7C6FD6),
        ),
        AttendanceRosterItem(
          name: 'Chitikela Swathi',
          employeeId: 'T1189',
          role: 'Pharmacist',
          department: 'Medical',
          badge: AttendanceBadge.singlePunch,
          present: 6,
          late: 2,
          onSite: 4,
          remote: 2,
          halfDay: 1,
          fullDay: 5,
          otHours: 1.5,
          workDays: 6.5,
          avatarColor: Color(0xFFE07A9A),
        ),
        AttendanceRosterItem(
          name: 'Farheen Khan',
          employeeId: 'T1201',
          role: 'Staff Nurse',
          department: 'Nursing',
          badge: AttendanceBadge.earlyLeave,
          present: 8,
          late: 1,
          onSite: 8,
          remote: 0,
          halfDay: 2,
          fullDay: 6,
          otHours: 0.5,
          workDays: 7.0,
          avatarColor: Color(0xFF5B8DEF),
        ),
        AttendanceRosterItem(
          name: 'Rahul Mehta',
          employeeId: 'T1140',
          role: 'Doctor',
          department: 'Medical',
          badge: AttendanceBadge.fullDay,
          present: 10,
          late: 0,
          onSite: 7,
          remote: 3,
          halfDay: 0,
          fullDay: 10,
          otHours: 4.0,
          workDays: 10.0,
          avatarColor: Color(0xFF3D8B8B),
        ),
        AttendanceRosterItem(
          name: 'Sana Parveen',
          employeeId: 'T1177',
          role: 'Marketing',
          department: 'Marketing',
          badge: AttendanceBadge.singlePunch,
          present: 5,
          late: 3,
          onSite: 5,
          remote: 0,
          halfDay: 1,
          fullDay: 4,
          otHours: 0,
          workDays: 4.5,
          avatarColor: Color(0xFF6C7AE0),
        ),
        AttendanceRosterItem(
          name: 'Imran Sheikh',
          employeeId: 'T1098',
          role: 'HR Manager',
          department: 'Management',
          badge: AttendanceBadge.fullDay,
          present: 9,
          late: 1,
          onSite: 9,
          remote: 0,
          halfDay: 0,
          fullDay: 9,
          otHours: 3.0,
          workDays: 9.0,
          avatarColor: Color(0xFFD4A017),
        ),
        AttendanceRosterItem(
          name: 'Neha Verma',
          employeeId: 'T1215',
          role: 'Sales Executive',
          department: 'Sales',
          badge: AttendanceBadge.noAttendance,
          present: 0,
          late: 0,
          onSite: 0,
          remote: 0,
          halfDay: 0,
          fullDay: 0,
          otHours: 0,
          workDays: 0,
          avatarColor: Color(0xFF9B6B9E),
        ),
      ],
    );
  }
}
