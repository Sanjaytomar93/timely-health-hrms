import 'package:timelay_health/features/dashboard/domain/entities/employee_performance.dart';

class EmployeePerformanceModel {
  const EmployeePerformanceModel({
    required this.employeeName,
    required this.employeeCode,
    required this.month,
    required this.year,
    required this.presentDays,
    required this.absentDays,
    required this.lateComingDays,
    required this.expectedWorkingHours,
    required this.actualWorkingHours,
    required this.performancePercentage,
    this.status,
  });

  final String employeeName;
  final String employeeCode;
  final int month;
  final int year;
  final int presentDays;
  final int absentDays;
  final int lateComingDays;
  final double expectedWorkingHours;
  final double actualWorkingHours;
  final double performancePercentage;
  final String? status;

  /// Same source as the web portal: `empdashboard` stats.
  factory EmployeePerformanceModel.fromDashboardJson(
    Map<String, dynamic> json, {
    required int month,
    required int year,
  }) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    final profile = data['profile'] is Map<String, dynamic>
        ? data['profile'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final stats = json['stats'] is Map<String, dynamic>
        ? json['stats'] as Map<String, dynamic>
        : data['stats'] is Map<String, dynamic>
        ? data['stats'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final filter = json['filter'] is Map<String, dynamic>
        ? json['filter'] as Map<String, dynamic>
        : const <String, dynamic>{};

    final parsedMonth = _asInt(filter['month'] ?? json['month']);
    final parsedYear = _asInt(filter['year'] ?? json['year']);

    return EmployeePerformanceModel(
      employeeName: profile['name']?.toString() ?? '',
      employeeCode:
          (profile['employeeId'] ?? profile['employeeCode'])?.toString() ?? '',
      month: parsedMonth > 0 ? parsedMonth : month,
      year: parsedYear > 0 ? parsedYear : year,
      presentDays: _asInt(stats['presentThisMonth'] ?? stats['present']),
      absentDays: _asInt(stats['absentThisMonth'] ?? stats['absent']),
      lateComingDays: _asInt(stats['lateThisMonth'] ?? stats['late']),
      expectedWorkingHours: 0,
      actualWorkingHours: 0,
      performancePercentage: _asDouble(
        stats['performance'] ??
            stats['performancePercentage'] ??
            stats['attendanceRate'],
      ),
      status: stats['status']?.toString() ??
          stats['grade']?.toString() ??
          stats['performanceStatus']?.toString(),
    );
  }

  factory EmployeePerformanceModel.fromJson(Map<String, dynamic> json) {
    final payload = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    final employee = payload['employee'] is Map<String, dynamic>
        ? payload['employee'] as Map<String, dynamic>
        : const <String, dynamic>{};

    return EmployeePerformanceModel(
      employeeName: employee['name']?.toString() ?? '',
      employeeCode: employee['employeeCode']?.toString() ?? '',
      month: _asInt(payload['month']),
      year: _asInt(payload['year']),
      presentDays: _asInt(payload['presentDays']),
      absentDays: _asInt(payload['absentDays']),
      lateComingDays: _asInt(payload['lateComingDays']),
      expectedWorkingHours: _asDouble(payload['expectedWorkingHours']),
      actualWorkingHours: _asDouble(payload['actualWorkingHours']),
      performancePercentage: _asDouble(payload['performancePercentage']),
      status: payload['status']?.toString() ??
          payload['grade']?.toString() ??
          payload['performanceStatus']?.toString(),
    );
  }

  EmployeePerformance toEntity() {
    return EmployeePerformance(
      employeeName: employeeName,
      employeeCode: employeeCode,
      month: month,
      year: year,
      presentDays: presentDays,
      absentDays: absentDays,
      lateComingDays: lateComingDays,
      expectedWorkingHours: expectedWorkingHours,
      actualWorkingHours: actualWorkingHours,
      performancePercentage: performancePercentage,
      status: status,
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
