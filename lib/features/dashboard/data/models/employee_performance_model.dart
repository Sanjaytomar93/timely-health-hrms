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

  factory EmployeePerformanceModel.fromJson(Map<String, dynamic> json) {
    final employee = json['employee'] is Map<String, dynamic>
        ? json['employee'] as Map<String, dynamic>
        : const <String, dynamic>{};

    return EmployeePerformanceModel(
      employeeName: employee['name']?.toString() ?? '',
      employeeCode: employee['employeeCode']?.toString() ?? '',
      month: _asInt(json['month']),
      year: _asInt(json['year']),
      presentDays: _asInt(json['presentDays']),
      absentDays: _asInt(json['absentDays']),
      lateComingDays: _asInt(json['lateComingDays']),
      expectedWorkingHours: _asDouble(json['expectedWorkingHours']),
      actualWorkingHours: _asDouble(json['actualWorkingHours']),
      performancePercentage: _asDouble(json['performancePercentage']),
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
