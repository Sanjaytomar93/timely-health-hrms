import 'package:timelay_health/features/expense/domain/entities/add_expense_params.dart';
import 'package:timelay_health/features/expense/domain/entities/expense_claim.dart';

abstract class ExpenseRepository {
  Future<ExpenseOverview> getMyExpenses({required String employeeId});

  Future<ExpenseClaim> addExpense(AddExpenseParams params);
}
