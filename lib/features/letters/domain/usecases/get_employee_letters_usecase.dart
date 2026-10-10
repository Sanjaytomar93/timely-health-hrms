import 'package:timelay_health/features/letters/domain/entities/letter.dart';
import 'package:timelay_health/features/letters/domain/repositories/letter_repository.dart';

class GetEmployeeLettersUseCase {
  const GetEmployeeLettersUseCase(this._repository);
  final LetterRepository _repository;

  Future<List<Letter>> call(String employeeId) =>
      _repository.getEmployeeLetters(employeeId);
}
