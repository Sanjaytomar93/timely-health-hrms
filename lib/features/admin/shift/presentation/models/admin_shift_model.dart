import 'package:flutter/material.dart';

class AdminShiftStats {
  const AdminShiftStats({
    required this.totalEmployees,
    required this.activeShifts,
    required this.assignedShifts,
    required this.onShiftToday,
  });

  final int totalEmployees;
  final int activeShifts;
  final int assignedShifts;
  final int onShiftToday;

  static const empty = AdminShiftStats(
    totalEmployees: 0,
    activeShifts: 0,
    assignedShifts: 0,
    onShiftToday: 0,
  );

  factory AdminShiftStats.fromJson(Map<String, dynamic>? json) {
    if (json == null) return empty;
    return AdminShiftStats(
      totalEmployees: (json['totalEmployees'] as num?)?.toInt() ?? 0,
      activeShifts: (json['activeShifts'] as num?)?.toInt() ?? 0,
      assignedShifts: (json['assignedShifts'] as num?)?.toInt() ?? 0,
      onShiftToday: (json['onShiftToday'] as num?)?.toInt() ?? 0,
    );
  }
}

class AdminShiftEmployeeItem {
  final String id;
  final String employeeId;
  final String name;
  final String initials;
  final String designation;
  final String shiftCode;
  final String shiftName;
  final String shiftMessage;
  final String timeRange;
  final Color avatarColor;
  final Color shiftBadgeBg;
  final Color shiftBadgeText;
  final String department;
  final bool isLive;
  final String shiftCategory;
  final bool isBrakeShift;

  const AdminShiftEmployeeItem({
    required this.id,
    required this.employeeId,
    required this.name,
    required this.initials,
    required this.designation,
    required this.shiftCode,
    required this.shiftName,
    required this.shiftMessage,
    required this.timeRange,
    required this.avatarColor,
    required this.shiftBadgeBg,
    required this.shiftBadgeText,
    required this.department,
    this.isLive = true,
    this.shiftCategory = '',
    this.isBrakeShift = false,
  });

  static const _avatarColors = [
    Color(0xFF1E1B4B),
    Color(0xFFF59E0B),
    Color(0xFF0D9488),
    Color(0xFFEA580C),
    Color(0xFF7C3AED),
    Color(0xFFE11D48),
    Color(0xFF059669),
    Color(0xFF2563EB),
    Color(0xFFD97706),
    Color(0xFF9333EA),
  ];

  static const _badgePairs = [
    (Color(0xFFEFF6FF), Color(0xFF4F46E5)),
    (Color(0xFFFAF5FF), Color(0xFF9333EA)),
    (Color(0xFFFEF3C7), Color(0xFFD97706)),
    (Color(0xFFECFDF5), Color(0xFF059669)),
    (Color(0xFFFFF1F2), Color(0xFFE11D48)),
    (Color(0xFFEEF2FF), Color(0xFF2563EB)),
  ];

  static Color _colorFor(String key) {
    if (key.isEmpty) return _avatarColors.first;
    return _avatarColors[key.hashCode.abs() % _avatarColors.length];
  }

  static (Color, Color) _badgeFor(String key) {
    if (key.isEmpty) return _badgePairs.first;
    return _badgePairs[key.hashCode.abs() % _badgePairs.length];
  }

  static String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final s = parts.first;
      return s.length >= 2 ? s.substring(0, 2).toUpperCase() : s.toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  factory AdminShiftEmployeeItem.fromJson(
    Map<String, dynamic> json, {
    Map<String, dynamic>? employeeInfo,
  }) {
    final assignment = json['employeeAssignment'] is Map<String, dynamic>
        ? json['employeeAssignment'] as Map<String, dynamic>
        : <String, dynamic>{};

    final id = (json['_id'] ?? json['id'] ?? '').toString();
    final employeeId = (assignment['employeeId'] ?? json['employeeId'] ?? '')
        .toString()
        .trim();
    final name = (assignment['employeeName'] ??
            json['employeeName'] ??
            employeeInfo?['name'] ??
            employeeInfo?['employeeName'] ??
            '')
        .toString()
        .trim();

    final shiftType = (json['shiftType'] ?? '').toString().trim();
    final shiftName = (json['shiftName'] ?? '').toString().trim();
    final shiftCategory = (json['shiftCategory'] ?? '').toString().trim();

    final timeRange = (assignment['selectedTimeRange'] ??
            (json['timeSlots'] is List &&
                    (json['timeSlots'] as List).isNotEmpty &&
                    (json['timeSlots'] as List).first is Map
                ? ((json['timeSlots'] as List).first as Map)['timeRange']
                : null) ??
            '')
        .toString()
        .trim();

    final rawMessage = (assignment['selectedDescription'] ??
            (json['timeSlots'] is List &&
                    (json['timeSlots'] as List).isNotEmpty &&
                    (json['timeSlots'] as List).first is Map
                ? ((json['timeSlots'] as List).first as Map)['description']
                : null) ??
            '')
        .toString()
        .trim();

    final designation = (employeeInfo?['role'] ??
            employeeInfo?['designation'] ??
            json['designation'] ??
            json['role'] ??
            '')
        .toString()
        .trim();

    final department = (employeeInfo?['department'] ??
            json['department'] ??
            '')
        .toString()
        .trim();

    final isActive = json['isActive'] != false;
    final isBrakeShift = json['isBrakeShift'] == true ||
        (assignment['scheduledChange'] is Map &&
            (assignment['scheduledChange'] as Map)['isBrakeShift'] == true);

    final shiftCode = shiftType.isNotEmpty ? 'Shift $shiftType' : 'Shift';
    final badge = _badgeFor(shiftType.isNotEmpty ? shiftType : id);
    final resolvedName = shiftName.isNotEmpty ? shiftName.trim() : shiftCode;
    // API sometimes sends codes like "OO"/"NN" as description — use shift name instead.
    final isCodeMessage = rawMessage.length <= 2 ||
        (shiftType.isNotEmpty &&
            rawMessage.toUpperCase() ==
                (shiftType + shiftType).toUpperCase());
    final resolvedMessage = (!isCodeMessage && rawMessage.isNotEmpty)
        ? rawMessage
        : resolvedName;

    return AdminShiftEmployeeItem(
      id: id.isNotEmpty ? id : employeeId,
      employeeId: employeeId,
      name: name.isNotEmpty ? name : employeeId,
      initials: _initials(name.isNotEmpty ? name : employeeId),
      designation: designation.isNotEmpty ? designation : 'Staff',
      shiftCode: shiftCode,
      shiftName: resolvedName,
      shiftMessage: resolvedMessage,
      timeRange: timeRange.isNotEmpty ? timeRange : '-',
      avatarColor: _colorFor(employeeId.isNotEmpty ? employeeId : name),
      shiftBadgeBg: badge.$1,
      shiftBadgeText: badge.$2,
      department: department.isNotEmpty ? department : 'General',
      isLive: isActive,
      shiftCategory: shiftCategory,
      isBrakeShift: isBrakeShift,
    );
  }
}

class AdminShiftUi {
  const AdminShiftUi({
    required this.records,
    required this.stats,
  });

  final List<AdminShiftEmployeeItem> records;
  final AdminShiftStats stats;

  static const empty = AdminShiftUi(
    records: [],
    stats: AdminShiftStats.empty,
  );

  factory AdminShiftUi.fromJson(
    Map<String, dynamic> json, {
    Map<String, Map<String, dynamic>> employeeMap = const {},
  }) {
    final raw = json['data'];
    final list = (raw is List)
        ? raw.whereType<Map>().map((e) {
            final map = Map<String, dynamic>.from(e);
            final assignment =
                map['employeeAssignment'] is Map<String, dynamic>
                    ? map['employeeAssignment'] as Map<String, dynamic>
                    : <String, dynamic>{};
            final empId =
                (assignment['employeeId'] ?? map['employeeId'] ?? '')
                    .toString()
                    .trim()
                    .toLowerCase();
            return AdminShiftEmployeeItem.fromJson(
              map,
              employeeInfo: empId.isNotEmpty ? employeeMap[empId] : null,
            );
          }).toList()
        : <AdminShiftEmployeeItem>[];

    final statsJson = json['stats'] is Map<String, dynamic>
        ? json['stats'] as Map<String, dynamic>
        : null;

    final stats = AdminShiftStats.fromJson(statsJson);
    final resolvedStats = stats.totalEmployees == 0 && list.isNotEmpty
        ? AdminShiftStats(
            totalEmployees: list.length,
            activeShifts: stats.activeShifts > 0
                ? stats.activeShifts
                : list.where((e) => e.isLive).length,
            assignedShifts:
                stats.assignedShifts > 0 ? stats.assignedShifts : list.length,
            onShiftToday: stats.onShiftToday > 0
                ? stats.onShiftToday
                : list.where((e) => e.isLive).length,
          )
        : stats;

    return AdminShiftUi(records: list, stats: resolvedStats);
  }
}
