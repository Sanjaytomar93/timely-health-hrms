import 'package:timelay_health/features/payslips/domain/entities/salary_summary.dart';

abstract class PayslipRepository {
  Future<SalarySummary> getSalarySummary({
    required String employeeId,
    required DateTime month,
  });
}
