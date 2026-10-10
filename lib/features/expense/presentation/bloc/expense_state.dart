import 'package:equatable/equatable.dart';
import 'package:timelay_health/features/expense/presentation/models/expense_claim_ui_model.dart';

sealed class ExpenseState extends Equatable {
  const ExpenseState();

  @override
  List<Object?> get props => [];
}

class ExpenseInitial extends ExpenseState {
  const ExpenseInitial();
}

class ExpenseLoading extends ExpenseState {
  const ExpenseLoading({
    this.expenses = const [],
    this.summary = ExpenseSummaryUi.empty,
  });

  final List<ExpenseClaimUiModel> expenses;
  final ExpenseSummaryUi summary;

  @override
  List<Object?> get props => [expenses, summary];
}

class ExpenseLoaded extends ExpenseState {
  const ExpenseLoaded({required this.expenses, required this.summary});

  final List<ExpenseClaimUiModel> expenses;
  final ExpenseSummaryUi summary;

  @override
  List<Object?> get props => [expenses, summary];
}

class ExpenseFailureState extends ExpenseState {
  const ExpenseFailureState(
    this.message, {
    this.expenses = const [],
    this.summary = ExpenseSummaryUi.empty,
  });

  final String message;
  final List<ExpenseClaimUiModel> expenses;
  final ExpenseSummaryUi summary;

  @override
  List<Object?> get props => [message, expenses, summary];
}
