import 'package:equatable/equatable.dart';
import 'package:timelay_health/features/auth/domain/entities/employee.dart';

sealed class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {
  const LoginInitial();
}

class LoginLoading extends LoginState {
  const LoginLoading();
}

class LoginSuccess extends LoginState {
  const LoginSuccess(this.employee);

  final Employee employee;

  @override
  List<Object?> get props => [employee.id, employee.employeeId];
}

class LoginFailure extends LoginState {
  const LoginFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
