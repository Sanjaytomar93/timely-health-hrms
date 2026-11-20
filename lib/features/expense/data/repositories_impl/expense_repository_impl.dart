import 'package:timelay_health/features/expense/data/datasources/expense_remote_datasource.dart';
import 'package:timelay_health/features/expense/data/mappers/expense_mapper.dart';
import 'package:timelay_health/features/expense/domain/entities/add_expense_params.dart';
import 'package:timelay_health/features/expense/domain/entities/expense_claim.dart';
import 'package:timelay_health/features/expense/domain/entities/update_expense_params.dart';
import 'package:timelay_health/features/expense/domain/repositories/expense_repository.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  ExpenseRepositoryImpl({ExpenseRemoteDataSource? remoteDataSource})
    : _remote = remoteDataSource ?? ExpenseRemoteDataSource();

  final ExpenseRemoteDataSource _remote;

  @override
  Future<ExpenseOverview> getMyExpenses({required String employeeId}) async {
    final parsed = await _remote.getMyExpenses(employeeId: employeeId);
    return ExpenseOverview(
      claims: parsed.data.map(ExpenseMapper.toEntity).toList(),
      totalClaims: parsed.totalClaims,
      totalAmount: parsed.totalAmount,
      monthlyClaims: parsed.monthlyClaims,
      totalDistance: parsed.totalDistance,
      pendingClaims: parsed.pendingClaims,
      rate: parsed.rate,
    );
  }

  @override
  Future<ExpenseClaim> addExpense(AddExpenseParams params) async {
    final model = await _remote.addExpense(params);
    return ExpenseMapper.toEntity(model);
  }

  @override
  Future<ExpenseClaim> updateExpense(UpdateExpenseParams params) async {
    final model = await _remote.updateExpense(params);
    return ExpenseMapper.toEntity(model);
  }

  @override
  Future<void> deleteExpense({required String id}) {
    return _remote.deleteExpense(id: id);
  }
}
