import 'package:timelay_health/features/expense/domain/entities/expense_claim.dart';
import 'package:timelay_health/features/expense/domain/repositories/expense_repository.dart';

class GetMyExpensesUseCase {
  const GetMyExpensesUseCase(this._repository);

  final ExpenseRepository _repository;

  Future<ExpenseOverview> call(String employeeId) {
    return _repository.getMyExpenses(employeeId: employeeId);
  }
}
