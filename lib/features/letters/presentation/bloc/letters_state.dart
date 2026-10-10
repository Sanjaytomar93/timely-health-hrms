import 'package:equatable/equatable.dart';
import 'package:timelay_health/features/letters/presentation/models/employee_letter.dart';

sealed class LettersState extends Equatable {
  const LettersState({this.letters = const []});

  final List<EmployeeLetter> letters;

  @override
  List<Object?> get props => [letters];
}

class LettersInitial extends LettersState {
  const LettersInitial();
}

class LettersLoading extends LettersState {
  const LettersLoading({super.letters});
}

class LettersLoaded extends LettersState {
  const LettersLoaded({required super.letters});
}

class LettersFailureState extends LettersState {
  const LettersFailureState(this.message, {super.letters});

  final String message;

  @override
  List<Object?> get props => [message, ...super.props];
}
