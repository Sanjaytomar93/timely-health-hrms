import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelay_health/features/auth/data/auth_session.dart';
import 'package:timelay_health/features/expense/data/repositories_impl/expense_repository_impl.dart';
import 'package:timelay_health/features/expense/domain/entities/add_expense_params.dart';
import 'package:timelay_health/features/expense/domain/failures/expense_failure.dart';
import 'package:timelay_health/features/expense/domain/usecases/add_expense_usecase.dart';

sealed class RecordExpenseState extends Equatable {
  const RecordExpenseState();

  @override
  List<Object?> get props => [];
}

class RecordExpenseInitial extends RecordExpenseState {
  const RecordExpenseInitial();
}

class RecordExpenseSubmitting extends RecordExpenseState {
  const RecordExpenseSubmitting();
}

class RecordExpenseSuccess extends RecordExpenseState {
  const RecordExpenseSuccess(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class RecordExpenseFailure extends RecordExpenseState {
  const RecordExpenseFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class RecordExpenseCubit extends Cubit<RecordExpenseState> {
  RecordExpenseCubit({AddExpenseUseCase? addExpenseUseCase})
    : _addExpense =
          addExpenseUseCase ?? AddExpenseUseCase(ExpenseRepositoryImpl()),
      super(const RecordExpenseInitial());

  final AddExpenseUseCase _addExpense;

  static const double ratePerKm = 4;

  Future<void> submit({
    required String purpose,
    required DateTime? date,
    required String remark,
    required List<AddExpenseStopInput> stops,
  }) async {
    emit(const RecordExpenseSubmitting());

    final trimmedPurpose = purpose.trim();
    if (trimmedPurpose.isEmpty) {
      emit(const RecordExpenseFailure('Please enter purpose of travel.'));
      return;
    }
    if (date == null) {
      emit(const RecordExpenseFailure('Please select travel date.'));
      return;
    }
    if (stops.isEmpty) {
      emit(const RecordExpenseFailure('Please add at least one stop.'));
      return;
    }
    for (var i = 0; i < stops.length; i++) {
      final stop = stops[i];
      if (stop.locationName.trim().isEmpty) {
        emit(RecordExpenseFailure('Please enter location for stop ${i + 1}.'));
        return;
      }
      if (stop.km <= 0) {
        emit(
          RecordExpenseFailure('Please enter distance (KM) for stop ${i + 1}.'),
        );
        return;
      }
    }

    final employeeId =
        AuthSession.currentEmployee?.employeeId ??
        (await AuthSession.load())?.employeeId ??
        '';

    if (isClosed) return;

    if (employeeId.isEmpty) {
      emit(
        const RecordExpenseFailure('Employee ID missing. Please login again.'),
      );
      return;
    }

    final totalKm = stops.fold<double>(0, (sum, s) => sum + s.km);

    try {
      await _addExpense(
        AddExpenseParams(
          purpose: trimmedPurpose,
          date: date,
          employeeId: employeeId,
          km: totalKm,
          remark: remark.trim(),
          stops: stops,
        ),
      );
      if (isClosed) return;
      emit(const RecordExpenseSuccess('Expense recorded successfully'));
    } on ExpenseFailure catch (e) {
      if (isClosed) return;
      emit(RecordExpenseFailure(e.message));
    } catch (_) {
      if (isClosed) return;
      emit(
        const RecordExpenseFailure(
          'Failed to record expense. Please try again.',
        ),
      );
    }
  }
}
