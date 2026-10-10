import 'package:timelay_health/features/payslips/domain/entities/salary_summary.dart';
import 'package:timelay_health/features/payslips/domain/repositories/payslip_repository.dart';

class GetSalarySummaryUseCase {
  const GetSalarySummaryUseCase(this._repository);

  final PayslipRepository _repository;

  Future<SalarySummary> call({
    required String employeeId,
    required DateTime month,
  }) {
    return _repository.getSalarySummary(employeeId: employeeId, month: month);
  }
}
