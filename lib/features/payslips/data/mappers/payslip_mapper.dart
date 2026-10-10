import 'package:timelay_health/features/payslips/data/models/payslip_model.dart';
import 'package:timelay_health/features/payslips/domain/entities/payslip.dart';

class PayslipMapper {
  const PayslipMapper._();

  static Payslip toEntity(PayslipModel model) {
    return Payslip(
      salaryPerMonth: model.salaryPerMonth,
      basicPay: model.basicPay,
      hra: model.hra,
      conveyanceAllowance: model.conveyanceAllowance,
      medicalAllowance: model.medicalAllowance,
      performanceAllowance: model.performanceAllowance,
      specialAllowance: model.specialAllowance,
      ctc: model.ctc,
      effectiveFrom: model.effectiveFrom,
      employeeId: model.employeeId,
      name: model.name,
    );
  }
}
