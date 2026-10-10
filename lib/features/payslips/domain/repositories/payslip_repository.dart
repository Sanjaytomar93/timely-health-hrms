import 'package:timelay_health/features/payslips/domain/entities/payslip.dart';
import 'package:timelay_health/features/payslips/domain/entities/salary_summary.dart';

abstract class PayslipRepository {
  Future<Payslip> getSalaryForDate({
    required String employeeId,
    required DateTime date,
  });

  Future<SalarySummary> getSalarySummary({
    required String employeeId,
    required DateTime month,
  });
}
