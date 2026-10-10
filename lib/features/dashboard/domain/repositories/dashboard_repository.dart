import 'package:timelay_health/features/dashboard/domain/entities/employee_dashboard.dart';
import 'package:timelay_health/features/dashboard/domain/entities/employee_performance.dart';

abstract class DashboardRepository {
  Future<EmployeeDashboard> getEmployeeDashboard({
    required String employeeId,
    required int month,
    required int year,
  });

  Future<EmployeeDashboard> attachMyShift({
    required EmployeeDashboard dashboard,
    required String employeeId,
  });

  Future<EmployeePerformance> getEmployeePerformance({
    required String employeeCode,
    required int month,
    required int year,
  });
}
