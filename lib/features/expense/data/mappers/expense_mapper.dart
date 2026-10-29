import 'package:timelay_health/features/expense/data/models/expense_claim_model.dart';
import 'package:timelay_health/features/expense/domain/entities/expense_claim.dart';

class ExpenseMapper {
  const ExpenseMapper._();

  static ExpenseClaim toEntity(ExpenseClaimModel model) {
    return ExpenseClaim(
      id: model.id,
      employeeId: model.employeeId,
      purpose: model.purpose,
      date: model.date,
      km: model.km,
      rateApplied: model.rateApplied,
      totalAmount: model.totalAmount,
      orderValue: model.orderValue,
      upsellValue: model.upsellValue,
      remark: model.remark,
      stops: model.stops.map(_stopToEntity).toList(),
      status: model.status,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  static ExpenseStop _stopToEntity(ExpenseStopModel model) {
    return ExpenseStop(
      id: model.id,
      locationName: model.locationName,
      outcome: model.outcome,
      orderValue: model.orderValue,
      upsellValue: model.upsellValue,
      km: model.km,
      amount: model.amount,
    );
  }
}
