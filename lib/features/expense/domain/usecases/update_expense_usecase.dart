import 'package:timelay_health/features/expense/domain/entities/expense_claim.dart';
import 'package:timelay_health/features/expense/domain/entities/update_expense_params.dart';
import 'package:timelay_health/features/expense/domain/repositories/expense_repository.dart';

class UpdateExpenseUseCase {
  const UpdateExpenseUseCase(this._repository);

  final ExpenseRepository _repository;

  Future<ExpenseClaim> call(UpdateExpenseParams params) {
    return _repository.updateExpense(params);
  }
}
