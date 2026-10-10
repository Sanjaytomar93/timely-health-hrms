import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelay_health/features/auth/data/auth_session.dart';
import 'package:timelay_health/features/letters/data/repositories_impl/letter_repository_impl.dart';
import 'package:timelay_health/features/letters/domain/failures/letter_failure.dart';
import 'package:timelay_health/features/letters/domain/usecases/get_employee_letters_usecase.dart';
import 'package:timelay_health/features/letters/presentation/bloc/letters_state.dart';
import 'package:timelay_health/features/letters/presentation/models/employee_letter.dart';

class LettersCubit extends Cubit<LettersState> {
  LettersCubit({GetEmployeeLettersUseCase? getEmployeeLettersUseCase})
    : _getLetters =
          getEmployeeLettersUseCase ??
          GetEmployeeLettersUseCase(LetterRepositoryImpl()),
      super(const LettersInitial());

  final GetEmployeeLettersUseCase _getLetters;

  Future<void> load({bool keepExisting = false}) async {
    final previous = keepExisting ? state.letters : const <EmployeeLetter>[];
    emit(LettersLoading(letters: previous));

    final employeeId =
        AuthSession.currentEmployee?.employeeId ??
        (await AuthSession.load())?.employeeId ??
        '';
    if (isClosed) return;
    if (employeeId.isEmpty) {
      emit(
        LettersFailureState(
          'Employee session not found. Please log in again.',
          letters: previous,
        ),
      );
      return;
    }

    try {
      final letters = await _getLetters(employeeId);
      if (isClosed) return;
      emit(LettersLoaded(letters: LetterUiMapper.toUiList(letters)));
    } on LetterFailure catch (e) {
      if (isClosed) return;
      emit(LettersFailureState(e.message, letters: previous));
    } catch (_) {
      if (isClosed) return;
      emit(
        LettersFailureState(
          'Failed to load letters. Please try again.',
          letters: previous,
        ),
      );
    }
  }
}
