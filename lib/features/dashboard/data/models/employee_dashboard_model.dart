class DashboardAttendanceItemModel {
  const DashboardAttendanceItemModel({
    required this.id,
    required this.status,
    required this.dayType,
    required this.totalHours,
    required this.workingHours,
    required this.onsite,
    required this.officeName,
    required this.reason,
    this.checkInTime,
    this.checkOutTime,
  });

  final String id;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final String status;
  final String dayType;
  final double totalHours;
  final double workingHours;
  final bool onsite;
  final String officeName;
  final String reason;

  factory DashboardAttendanceItemModel.fromJson(Map<String, dynamic> json) {
    return DashboardAttendanceItemModel(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      checkInTime: _parseDate(json['checkInTime']),
      checkOutTime: _parseDate(json['checkOutTime']),
      status: json['status']?.toString() ?? '',
      dayType: json['dayType']?.toString() ?? '',
      totalHours: _asDouble(json['totalHours']),
      workingHours: _asDouble(json['workingHours']),
      onsite: json['onsite'] as bool? ?? false,
      officeName: json['officeName']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
    );
  }
}

class DashboardLeaveItemModel {
  const DashboardLeaveItemModel({
    required this.id,
    required this.leaveType,
    required this.status,
    required this.days,
    required this.reason,
    this.startDate,
    this.endDate,
    this.employeeName,
  });

  final String id;
  final String leaveType;
  final String status;
  final double days;
  final String reason;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? employeeName;

  factory DashboardLeaveItemModel.fromJson(Map<String, dynamic> json) {
    return DashboardLeaveItemModel(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      leaveType: json['leaveType']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      days: _asDouble(json['days']),
      reason: json['reason']?.toString() ?? '',
      startDate: _parseDate(json['startDate']),
      endDate: _parseDate(json['endDate']),
      employeeName: json['employeeName']?.toString(),
    );
  }
}

class DashboardShiftModel {
  const DashboardShiftModel({
    required this.shiftTiming,
    this.upcomingShiftLabel,
  });

  final String shiftTiming;
  final String? upcomingShiftLabel;

  factory DashboardShiftModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const DashboardShiftModel(shiftTiming: 'Not Assigned');
    }

    final timing = _resolveShiftTiming(json);

    final upcoming =
        json['upcomingShift'] ?? json['upcoming_shift'] ?? json['nextShift'];
    String? upcomingLabel;
    if (upcoming is Map) {
      final map = Map<String, dynamic>.from(upcoming);
      final name =
          map['name']?.toString() ??
          map['shiftName']?.toString() ??
          map['shiftType']?.toString() ??
          map['shift']?.toString();
      final dateRaw =
          map['date']?.toString() ??
          map['effectiveFrom']?.toString() ??
          map['startDate']?.toString() ??
          map['from']?.toString();
      final dateLabel = _prettyShiftDate(dateRaw);
      if (name != null && name.trim().isNotEmpty) {
        upcomingLabel = dateLabel != null
            ? 'Changing to ${name.trim()} · $dateLabel'
            : name.trim();
      }
    } else if (upcoming is String && upcoming.trim().isNotEmpty) {
      upcomingLabel = upcoming.trim();
    }

    upcomingLabel ??= () {
      final flat =
          json['upcomingShiftLabel']?.toString() ??
          json['upcomingShiftText']?.toString();
      if (flat == null || flat.trim().isEmpty) return null;
      return flat.trim();
    }();

    return DashboardShiftModel(
      shiftTiming: timing,
      upcomingShiftLabel: upcomingLabel,
    );
  }
}

String _resolveShiftTiming(Map<String, dynamic> json) {
  Map<String, dynamic>? nested;
  for (final key in ['currentShift', 'assignedShift', 'activeShift', 'shift']) {
    final raw = json[key];
    if (raw is Map) {
      nested = Map<String, dynamic>.from(raw);
      break;
    }
  }
  final source = nested ?? json;

  for (final key in ['shiftTiming', 'timeRange', 'timing', 'shiftTime']) {
    final value = source[key]?.toString().trim() ?? '';
    if (_isShiftTimeText(value)) {
      return _normalizeShiftRange(value);
    }
  }

  final start =
      source['startTime']?.toString() ??
      source['from']?.toString() ??
      source['shiftStart']?.toString() ??
      '';
  final end =
      source['endTime']?.toString() ??
      source['to']?.toString() ??
      source['shiftEnd']?.toString() ??
      '';
  if (start.trim().isNotEmpty && end.trim().isNotEmpty) {
    return '${_formatClock(start.trim())} – ${_formatClock(end.trim())}';
  }
  if (start.trim().isNotEmpty) return _formatClock(start.trim());

  for (final key in ['shiftTiming', 'timeRange', 'timing']) {
    final value = json[key]?.toString().trim() ?? '';
    if (_isShiftTimeText(value)) {
      return _normalizeShiftRange(value);
    }
  }

  return 'Not Assigned';
}

bool _isShiftTimeText(String value) {
  final lower = value.toLowerCase();
  if (value.isEmpty || lower == 'not assigned' || lower == 'null') {
    return false;
  }
  return value.contains(':') || RegExp(r'\b(am|pm)\b').hasMatch(lower);
}

String _normalizeShiftRange(String value) {
  final normalized = value
      .replaceAll('–', '-')
      .replaceAll('—', '-')
      .replaceAll('−', '-');

  String? left;
  String? right;
  final lower = normalized.toLowerCase();
  final toIndex = lower.indexOf(' to ');
  if (toIndex > 0) {
    left = normalized.substring(0, toIndex).trim();
    right = normalized.substring(toIndex + 4).trim();
  } else {
    final dashIndex = normalized.indexOf('-');
    if (dashIndex > 0 && dashIndex < normalized.length - 1) {
      left = normalized.substring(0, dashIndex).trim();
      right = normalized.substring(dashIndex + 1).trim();
    }
  }

  if (left != null && right != null && left.isNotEmpty && right.isNotEmpty) {
    return '${_formatClock(left)} – ${_formatClock(right)}';
  }
  return value;
}

String _formatClock(String raw) {
  final value = raw.trim();
  if (value.isEmpty) return value;

  if (RegExp(r'\b(am|pm)\b', caseSensitive: false).hasMatch(value)) {
    return value
        .replaceAllMapped(
          RegExp(r'\b(am|pm)\b', caseSensitive: false),
          (m) => m.group(0)!.toUpperCase(),
        )
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  final m = RegExp(r'^(\d{1,2}):(\d{2})(?::\d{2})?$').firstMatch(value);
  if (m != null) {
    var hour = int.tryParse(m.group(1)!) ?? 0;
    final minute = m.group(2)!;
    final isPm = hour >= 12;
    final suffix = isPm ? 'PM' : 'AM';
    hour = hour % 12;
    if (hour == 0) hour = 12;
    return '${hour.toString().padLeft(2, '0')}:$minute $suffix';
  }

  return value;
}

String? _prettyShiftDate(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  final value = raw.trim();

  final iso = DateTime.tryParse(value);
  if (iso != null) return _shiftDateLabel(iso.toLocal());

  final slash = RegExp(
    r'^(\d{1,2})[/-](\d{1,2})[/-](\d{4})$',
  ).firstMatch(value);
  if (slash != null) {
    final d = int.tryParse(slash.group(1)!);
    final m = int.tryParse(slash.group(2)!);
    final y = int.tryParse(slash.group(3)!);
    if (d != null && m != null && y != null && m >= 1 && m <= 12) {
      return _shiftDateLabel(DateTime(y, m, d));
    }
  }
  return value;
}

String _shiftDateLabel(DateTime date) {
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
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

class DashboardPersonEventModel {
  const DashboardPersonEventModel({required this.name, this.detail});

  final String name;
  final String? detail;

  factory DashboardPersonEventModel.fromJson(Map<String, dynamic> json) {
    final name =
        json['name']?.toString() ??
        json['employeeName']?.toString() ??
        json['fullName']?.toString() ??
        '';
    final detail =
        json['department']?.toString() ??
        json['role']?.toString() ??
        json['leaveType']?.toString() ??
        json['message']?.toString();
    return DashboardPersonEventModel(name: name, detail: detail);
  }
}

class DashboardStatsModel {
  const DashboardStatsModel({
    required this.present,
    required this.absent,
    required this.late,
    required this.totalWorkingDays,
    required this.attendanceRate,
  });

  final int present;
  final int absent;
  final int late;
  final int totalWorkingDays;
  final int attendanceRate;

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      present: _asInt(json['presentThisMonth'] ?? json['present']),
      absent: _asInt(json['absentThisMonth'] ?? json['absent']),
      late: _asInt(json['lateThisMonth'] ?? json['late']),
      totalWorkingDays: _asInt(json['totalWorkingDays']),
      attendanceRate: _asInt(json['attendanceRate']),
    );
  }
}

class DashboardAbsentWeekModel {
  const DashboardAbsentWeekModel({
    required this.week,
    required this.workingDays,
    required this.absentDays,
    this.startDate,
    this.endDate,
  });

  final int week;
  final DateTime? startDate;
  final DateTime? endDate;
  final int workingDays;
  final int absentDays;

  factory DashboardAbsentWeekModel.fromJson(Map<String, dynamic> json, int i) {
    final rawWeek = json['week'];
    final week = rawWeek is num
        ? rawWeek.toInt()
        : int.tryParse(rawWeek?.toString().replaceAll(RegExp(r'\D'), '') ?? '');
    return DashboardAbsentWeekModel(
      week: week ?? i + 1,
      startDate: _parseDate(json['startDate']),
      endDate: _parseDate(json['endDate']),
      workingDays: _asInt(json['workingDays']),
      absentDays: _asInt(json['absentDays']),
    );
  }
}

class DashboardAbsentGraphModel {
  const DashboardAbsentGraphModel({
    this.periodStart,
    this.periodEnd,
    this.totalAbsent = 0,
    this.totalWorkingDays = 0,
    this.weeks = const [],
  });

  final DateTime? periodStart;
  final DateTime? periodEnd;
  final int totalAbsent;
  final int totalWorkingDays;
  final List<DashboardAbsentWeekModel> weeks;

  factory DashboardAbsentGraphModel.fromJson(dynamic raw) {
    List<DashboardAbsentWeekModel> parseWeeks(dynamic list) {
      if (list is! List) return const [];
      final maps = list.whereType<Map<String, dynamic>>().toList();
      return [
        for (var i = 0; i < maps.length; i++)
          DashboardAbsentWeekModel.fromJson(maps[i], i),
      ];
    }

    if (raw is Map<String, dynamic>) {
      return DashboardAbsentGraphModel(
        periodStart: _parseDate(raw['periodStart']),
        periodEnd: _parseDate(raw['periodEnd']),
        totalAbsent: _asInt(raw['totalAbsent']),
        totalWorkingDays: _asInt(raw['totalWorkingDays']),
        weeks: parseWeeks(raw['weeks']),
      );
    }
    return DashboardAbsentGraphModel(weeks: parseWeeks(raw));
  }
}

class EmployeeDashboardModel {
  const EmployeeDashboardModel({
    required this.employeeId,
    required this.name,
    required this.firstName,
    required this.lastName,
    required this.department,
    required this.role,
    required this.status,
    required this.location,
    required this.shift,
    required this.attendance,
    required this.leaves,
    required this.birthdaysToday,
    required this.anniversariesToday,
    required this.leavesToday,
    required this.assignedWorkingDays,
    required this.stats,
    required this.lateGraph,
    required this.absentGraph,
  });

  final String employeeId;
  final String name;
  final String firstName;
  final String lastName;
  final String department;
  final String role;
  final String status;
  final String location;
  final DashboardShiftModel shift;
  final List<DashboardAttendanceItemModel> attendance;
  final List<DashboardLeaveItemModel> leaves;
  final List<DashboardPersonEventModel> birthdaysToday;
  final List<DashboardPersonEventModel> anniversariesToday;
  final List<DashboardPersonEventModel> leavesToday;
  final int assignedWorkingDays;
  final DashboardStatsModel stats;
  final List<double> lateGraph;
  final DashboardAbsentGraphModel absentGraph;

  factory EmployeeDashboardModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    final profile = data['profile'] is Map<String, dynamic>
        ? data['profile'] as Map<String, dynamic>
        : <String, dynamic>{};

    List<Map<String, dynamic>> asMapList(dynamic raw) {
      if (raw is! List) return const [];
      return raw.whereType<Map<String, dynamic>>().toList();
    }

    return EmployeeDashboardModel(
      employeeId: profile['employeeId']?.toString() ?? '',
      name: profile['name']?.toString() ?? '',
      firstName: profile['firstName']?.toString() ?? '',
      lastName: profile['lastName']?.toString() ?? '',
      department: profile['department']?.toString() ?? '',
      role: profile['role']?.toString() ?? '',
      status: profile['status']?.toString() ?? 'active',
      location: data['location']?.toString() ?? '',
      shift: _parseDashboardShift(data),
      attendance: asMapList(
        data['attendance'],
      ).map(DashboardAttendanceItemModel.fromJson).toList(),
      leaves: asMapList(
        data['leaves'],
      ).map(DashboardLeaveItemModel.fromJson).toList(),
      birthdaysToday: asMapList(
        data['birthdaysToday'],
      ).map(DashboardPersonEventModel.fromJson).toList(),
      anniversariesToday: asMapList(
        data['anniversariesToday'],
      ).map(DashboardPersonEventModel.fromJson).toList(),
      leavesToday: asMapList(
        data['leavesToday'],
      ).map(DashboardPersonEventModel.fromJson).toList(),
      assignedWorkingDays:
          (profile['assignedWorkingDays'] as num?)?.toInt() ?? 26,
      stats: DashboardStatsModel.fromJson(
        json['stats'] is Map<String, dynamic>
            ? json['stats'] as Map<String, dynamic>
            : data['stats'] is Map<String, dynamic>
            ? data['stats'] as Map<String, dynamic>
            : const <String, dynamic>{},
      ),
      lateGraph: asMapList(
        data['lateGraph'],
      ).map((e) => _asDouble(e['lateMinutes'])).toList(),
      absentGraph: DashboardAbsentGraphModel.fromJson(data['absentGraph']),
    );
  }
}

int _asInt(dynamic value) {
  if (value is num) return value.toInt();
  if (value is String) return num.tryParse(value)?.toInt() ?? 0;
  return 0;
}

DateTime? _parseDate(dynamic value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value);
}

double _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

DashboardShiftModel _parseDashboardShift(Map<String, dynamic> data) {
  final shiftRaw = data['shift'];
  if (shiftRaw is Map) {
    return DashboardShiftModel.fromJson(Map<String, dynamic>.from(shiftRaw));
  }
  if (shiftRaw is String && shiftRaw.trim().isNotEmpty) {
    return DashboardShiftModel(shiftTiming: _normalizeShiftRange(shiftRaw));
  }

  final profile = data['profile'] is Map
      ? Map<String, dynamic>.from(data['profile'] as Map)
      : <String, dynamic>{};
  final merged = <String, dynamic>{
    ...profile,
    ...data,
    if (data['currentShift'] is Map) 'currentShift': data['currentShift'],
    if (data['assignedShift'] is Map) 'assignedShift': data['assignedShift'],
  };
  return DashboardShiftModel.fromJson(merged);
}
