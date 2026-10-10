import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelay_health/features/auth/data/auth_session.dart';
import 'package:timelay_health/features/expense/data/repositories_impl/expense_repository_impl.dart';
import 'package:timelay_health/features/expense/domain/failures/expense_failure.dart';
import 'package:timelay_health/features/expense/domain/usecases/get_my_expenses_usecase.dart';
import 'package:timelay_health/features/expense/presentation/bloc/expense_state.dart';
import 'package:timelay_health/features/expense/presentation/mappers/expense_ui_mapper.dart';
import 'package:timelay_health/features/expense/presentation/models/expense_claim_ui_model.dart';

class ExpenseCubit extends Cubit<ExpenseState> {
  ExpenseCubit({GetMyExpensesUseCase? getMyExpensesUseCase})
    : _getMyExpenses =
          getMyExpensesUseCase ?? GetMyExpensesUseCase(ExpenseRepositoryImpl()),
      super(const ExpenseInitial());

  final GetMyExpensesUseCase _getMyExpenses;

  Future<void> load({bool keepExisting = false}) async {
    final existingExpenses = switch (state) {
      ExpenseLoaded(:final expenses) => expenses,
      ExpenseLoading(:final expenses) => expenses,
      ExpenseFailureState(:final expenses) => expenses,
      _ => const <ExpenseClaimUiModel>[],
    };
    final existingSummary = switch (state) {
      ExpenseLoaded(:final summary) => summary,
      ExpenseLoading(:final summary) => summary,
      ExpenseFailureState(:final summary) => summary,
      _ => ExpenseSummaryUi.empty,
    };

    emit(
      ExpenseLoading(
        expenses: keepExisting ? existingExpenses : const [],
        summary: keepExisting ? existingSummary : ExpenseSummaryUi.empty,
      ),
    );

    final employee = AuthSession.currentEmployee ?? await AuthSession.load();
    final employeeId = employee?.performanceCode ?? '';

    if (isClosed) return;

    if (employeeId.isEmpty) {
      emit(
        const ExpenseFailureState('Employee ID missing. Please login again.'),
      );
      return;
    }

    try {
      final overview = await _getMyExpenses(employeeId);
      if (isClosed) return;
      emit(
        ExpenseLoaded(
          expenses: ExpenseUiMapper.toUiList(overview.claims),
          summary: ExpenseUiMapper.toSummary(overview),
        ),
      );
    } on ExpenseFailure catch (e) {
      if (isClosed) return;
      emit(
        ExpenseFailureState(
          e.message,
          expenses: keepExisting ? existingExpenses : const [],
          summary: keepExisting ? existingSummary : ExpenseSummaryUi.empty,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        ExpenseFailureState(
          'Failed to load expenses. Please try again.',
          expenses: keepExisting ? existingExpenses : const [],
          summary: keepExisting ? existingSummary : ExpenseSummaryUi.empty,
        ),
      );
    }
  }
}
