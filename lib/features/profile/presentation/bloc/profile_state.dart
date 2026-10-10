import 'package:equatable/equatable.dart';
import 'package:timelay_health/features/auth/domain/entities/employee.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading({this.employee});

  final Employee? employee;

  @override
  List<Object?> get props => [employee?.id, employee?.employeeId];
}

class ProfileLoaded extends ProfileState {
  const ProfileLoaded(this.employee);

  final Employee employee;

  @override
  List<Object?> get props => [
    employee.id,
    employee.employeeId,
    employee.name,
    employee.email,
    employee.role,
    employee.department,
    employee.status,
    employee.salaryPerMonth,
    employee.basicPay,
    employee.hra,
    employee.conveyanceAllowance,
    employee.medicalAllowance,
    employee.performanceAllowance,
    employee.specialAllowance,
    employee.otherDeductions,
    employee.salaryIncrements.length,
  ];
}

class ProfileFailure extends ProfileState {
  const ProfileFailure(this.message, {this.employee});

  final String message;
  final Employee? employee;

  @override
  List<Object?> get props => [message, employee?.id];
}
