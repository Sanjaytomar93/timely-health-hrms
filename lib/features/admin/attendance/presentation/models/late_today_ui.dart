import 'package:flutter/material.dart';

enum DelaySeverity {
  minimal,
  minor,
  moderate,
  significant,
  high,
  critical,
}

class LateEmployeeItem {
  const LateEmployeeItem({
    required this.id,
    required this.name,
    required this.employeeId,
    required this.avatarLetter,
    required this.department,
    required this.designation,
    required this.expectedTime,
    required this.actualTime,
    required this.dateLabel,
    required this.delayLabel,
    this.severity = DelaySeverity.minor,
    this.lateByMinutes = 0,
    this.shiftType = '',
    this.reason = '',
    this.officeName = '',
    this.checkInImage,
    this.employeeEmail = '',
    this.onsite = true,
    this.distance = 0,
  });

  final String id;
  final String name;
  final String employeeId;
  final String avatarLetter;
  final String department;
  final String designation;
  final String expectedTime;
  final String actualTime;
  final String dateLabel;
  final String delayLabel;
  final DelaySeverity severity;
  final int lateByMinutes;
  final String shiftType;
  final String reason;
  final String officeName;
  final String? checkInImage;
  final String employeeEmail;
  final bool onsite;
  final int distance;

  Color get delayColor {
    switch (severity) {
      case DelaySeverity.minimal:
        return const Color(0xFF0284C7); // Sky blue
      case DelaySeverity.minor:
        return const Color(0xFF10B981); // Emerald green
      case DelaySeverity.moderate:
        return const Color(0xFFF59E0B); // Amber
      case DelaySeverity.significant:
        return const Color(0xFFF97316); // Orange
      case DelaySeverity.high:
      case DelaySeverity.critical:
        return const Color(0xFFEF4444); // Red
    }
  }

  static (DelaySeverity, String) computeDelay(int minutes) {
    if (minutes <= 15) {
      return (DelaySeverity.minimal, 'Minimal Delay (${minutes}m)');
    }
    if (minutes <= 30) {
      return (DelaySeverity.minor, 'Minor Delay (${minutes}m)');
    }
    if (minutes <= 45) {
      return (DelaySeverity.moderate, 'Moderate Delay (${minutes}m)');
    }
    if (minutes <= 60) {
      return (DelaySeverity.significant, 'Significant Delay (${minutes}m)');
    }
    return (DelaySeverity.critical, 'Critical Delay (${minutes}m)');
  }

  static String formatTime(dynamic raw) {
    if (raw == null) return '-';
    final str = raw.toString().trim();
    if (str.isEmpty || str == 'null') return '-';
    if (str.toUpperCase().contains('AM') || str.toUpperCase().contains('PM')) {
      return str;
    }
    final dt = DateTime.tryParse(str)?.toLocal();
    if (dt == null) return str;
    final hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = hour >= 12 ? 'PM' : 'AM';
    final h12 = hour % 12 == 0 ? 12 : hour % 12;
    return '${h12.toString().padLeft(2, '0')}:$minute $ampm';
  }

  static String formatDate(dynamic raw, {String? defaultDate}) {
    if (raw != null) {
      final dt = DateTime.tryParse(raw.toString().trim())?.toLocal();
      if (dt != null) {
        final d = dt.day.toString().padLeft(2, '0');
        final m = dt.month.toString().padLeft(2, '0');
        return '$d-$m-${dt.year}';
      }
    }
    if (defaultDate != null && defaultDate.isNotEmpty) {
      final dt = DateTime.tryParse(defaultDate)?.toLocal();
      if (dt != null) {
        final d = dt.day.toString().padLeft(2, '0');
        final m = dt.month.toString().padLeft(2, '0');
        return '$d-$m-${dt.year}';
      }
      return defaultDate;
    }
    final now = DateTime.now();
    final d = now.day.toString().padLeft(2, '0');
    final m = now.month.toString().padLeft(2, '0');
    return '$d-$m-${now.year}';
  }

  factory LateEmployeeItem.fromJson(
    Map<String, dynamic> json, {
    Map<String, dynamic>? employeeInfo,
    String? defaultDate,
  }) {
    final id = (json['_id'] ?? json['id'] ?? '').toString();
    final employeeId = (json['employeeId'] ?? '').toString().trim();
    final name = (json['name'] ??
            json['employeeName'] ??
            employeeInfo?['name'] ??
            employeeInfo?['employeeName'] ??
            '')
        .toString()
        .trim();

    final dept = (json['department'] ??
            employeeInfo?['department'] ??
            'General')
        .toString()
        .trim();

    final desig = (json['designation'] ??
            json['role'] ??
            employeeInfo?['designation'] ??
            employeeInfo?['role'] ??
            'Staff')
        .toString()
        .trim();

    final lateMins = json['lateByMinutes'] is num
        ? (json['lateByMinutes'] as num).toInt()
        : int.tryParse(json['lateByMinutes']?.toString() ?? '') ?? 0;

    final (severity, delayLabel) = computeDelay(lateMins);

    final expectedTime = (json['expectedTime']?.toString().isNotEmpty == true)
        ? json['expectedTime'].toString()
        : formatTime(json['shiftStart']);

    final actualTime = (json['actualTime']?.toString().isNotEmpty == true)
        ? json['actualTime'].toString()
        : formatTime(json['actualCheckIn'] ?? json['checkInTime']);

    final dateLabel = formatDate(
      json['actualCheckIn'] ?? json['checkInTime'] ?? json['date'],
      defaultDate: defaultDate,
    );

    final avatarLetter = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return LateEmployeeItem(
      id: id.isNotEmpty ? id : 'late_${DateTime.now().microsecondsSinceEpoch}',
      name: name.isNotEmpty ? name : 'Employee',
      employeeId: employeeId.isNotEmpty ? employeeId : 'EMP',
      avatarLetter: avatarLetter,
      department: dept.isNotEmpty ? dept : 'General',
      designation: desig.isNotEmpty ? desig : 'Staff',
      expectedTime: expectedTime,
      actualTime: actualTime,
      dateLabel: dateLabel,
      delayLabel: delayLabel,
      severity: severity,
      lateByMinutes: lateMins,
      shiftType: (json['shiftType'] ?? '').toString(),
      reason: (json['reason'] ?? '').toString(),
      officeName: (json['officeName'] ?? '').toString(),
      checkInImage: json['checkInImage']?.toString(),
      employeeEmail: (json['employeeEmail'] ?? '').toString(),
      onsite: json['onsite'] == true,
      distance: json['distance'] is num
          ? (json['distance'] as num).toInt()
          : int.tryParse(json['distance']?.toString() ?? '') ?? 0,
    );
  }
}

class LateTodayUi {
  const LateTodayUi({
    required this.totalLate,
    required this.filteredLate,
    required this.activeEmployees,
    required this.onTimeEmployees,
    required this.records,
    this.totalLateMinutes = 0,
    this.avgLateMinutes = 0,
    this.mostLateName = '',
    this.mostLateMinutes = 0,
    this.departments = const [],
    this.designations = const [],
  });

  final int totalLate;
  final int filteredLate;
  final int activeEmployees;
  final int onTimeEmployees;
  final List<LateEmployeeItem> records;
  final int totalLateMinutes;
  final int avgLateMinutes;
  final String mostLateName;
  final int mostLateMinutes;
  final List<String> departments;
  final List<String> designations;

  static const LateTodayUi empty = LateTodayUi(
    totalLate: 0,
    filteredLate: 0,
    activeEmployees: 0,
    onTimeEmployees: 0,
    records: [],
  );

  LateTodayUi copyWith({
    int? totalLate,
    int? filteredLate,
    int? activeEmployees,
    int? onTimeEmployees,
    List<LateEmployeeItem>? records,
    int? totalLateMinutes,
    int? avgLateMinutes,
    String? mostLateName,
    int? mostLateMinutes,
    List<String>? departments,
    List<String>? designations,
  }) {
    return LateTodayUi(
      totalLate: totalLate ?? this.totalLate,
      filteredLate: filteredLate ?? this.filteredLate,
      activeEmployees: activeEmployees ?? this.activeEmployees,
      onTimeEmployees: onTimeEmployees ?? this.onTimeEmployees,
      records: records ?? this.records,
      totalLateMinutes: totalLateMinutes ?? this.totalLateMinutes,
      avgLateMinutes: avgLateMinutes ?? this.avgLateMinutes,
      mostLateName: mostLateName ?? this.mostLateName,
      mostLateMinutes: mostLateMinutes ?? this.mostLateMinutes,
      departments: departments ?? this.departments,
      designations: designations ?? this.designations,
    );
  }

  factory LateTodayUi.fromJson(
    Map<String, dynamic> json, {
    Map<String, Map<String, dynamic>>? employeeMap,
    String? selectedDateString,
  }) {
    final rawRecords = json['records'];
    final stats = json['stats'] is Map<String, dynamic>
        ? json['stats'] as Map<String, dynamic>
        : const <String, dynamic>{};

    final items = <LateEmployeeItem>[];
    final deptSet = <String>{};
    final designSet = <String>{};

    if (rawRecords is List) {
      for (final r in rawRecords) {
        if (r is Map<String, dynamic>) {
          final empId = (r['employeeId'] ?? '').toString().trim().toLowerCase();
          final empInfo = employeeMap?[empId];
          final item = LateEmployeeItem.fromJson(
            r,
            employeeInfo: empInfo,
            defaultDate: selectedDateString,
          );
          items.add(item);
          if (item.department.isNotEmpty) deptSet.add(item.department);
          if (item.designation.isNotEmpty) designSet.add(item.designation);
        }
      }
    }

    final totalLate = stats['totalLate'] is num
        ? (stats['totalLate'] as num).toInt()
        : items.length;

    final totalLateMins = stats['totalLateMinutes'] is num
        ? (stats['totalLateMinutes'] as num).toInt()
        : items.fold<int>(0, (sum, i) => sum + i.lateByMinutes);

    final avgLateMins = stats['avgLateMinutes'] is num
        ? (stats['avgLateMinutes'] as num).toInt()
        : (items.isNotEmpty ? (totalLateMins / items.length).round() : 0);

    final mostLate = stats['mostLateEmployee'] is Map<String, dynamic>
        ? stats['mostLateEmployee'] as Map<String, dynamic>
        : null;

    final mostLateName = (mostLate?['name'] ?? '').toString();
    final mostLateMins = mostLate?['lateByMinutes'] is num
        ? (mostLate!['lateByMinutes'] as num).toInt()
        : 0;

    return LateTodayUi(
      totalLate: totalLate,
      filteredLate: items.length,
      activeEmployees: items.length,
      onTimeEmployees: 0,
      totalLateMinutes: totalLateMins,
      avgLateMinutes: avgLateMins,
      mostLateName: mostLateName,
      mostLateMinutes: mostLateMins,
      records: items,
      departments: deptSet.toList()..sort(),
      designations: designSet.toList()..sort(),
    );
  }

  static LateTodayUi sample() {
    return const LateTodayUi(
      totalLate: 140,
      filteredLate: 140,
      activeEmployees: 25,
      onTimeEmployees: 115,
      totalLateMinutes: 282,
      avgLateMinutes: 40,
      records: [
        LateEmployeeItem(
          id: 'late_1',
          name: 'G NARESH KUMAR',
          employeeId: 'TH001',
          avatarLetter: 'G',
          department: 'Consultant',
          designation: 'Phlebotomist',
          expectedTime: '05:00 PM',
          actualTime: '05:13 PM',
          dateLabel: '18-11-2026',
          delayLabel: 'Minor Delay (13m)',
          severity: DelaySeverity.minor,
        ),
        LateEmployeeItem(
          id: 'late_2',
          name: 'Janapala Bharath Sai Reddy',
          employeeId: 'TH002',
          avatarLetter: 'J',
          department: 'Developer',
          designation: 'AI Intern',
          expectedTime: '10:00 AM',
          actualTime: '11:38 AM',
          dateLabel: '18-11-2026',
          delayLabel: 'Critical Delay (98m)',
          severity: DelaySeverity.critical,
        ),
      ],
    );
  }
}
