import 'package:timelay_health/features/expense/domain/entities/add_expense_params.dart';
import 'package:timelay_health/features/expense/domain/entities/expense_claim.dart';
import 'package:timelay_health/features/expense/domain/repositories/expense_repository.dart';

class AddExpenseUseCase {
  const AddExpenseUseCase(this._repository);

  final ExpenseRepository _repository;

  Future<ExpenseClaim> call(AddExpenseParams params) {
    return _repository.addExpense(params);
  }
}
