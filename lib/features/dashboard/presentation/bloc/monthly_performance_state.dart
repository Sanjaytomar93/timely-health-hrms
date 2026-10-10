import 'package:equatable/equatable.dart';
import 'package:timelay_health/features/dashboard/domain/entities/employee_performance.dart';

sealed class MonthlyPerformanceState extends Equatable {
  const MonthlyPerformanceState();

  @override
  List<Object?> get props => [];
}

class MonthlyPerformanceInitial extends MonthlyPerformanceState {
  const MonthlyPerformanceInitial();
}

class MonthlyPerformanceReady extends MonthlyPerformanceState {
  const MonthlyPerformanceReady(this.review);

  final EmployeePerformance review;

  @override
  List<Object?> get props => [review.employeeCode, review.month, review.year];
}

class MonthlyPerformanceUnavailable extends MonthlyPerformanceState {
  const MonthlyPerformanceUnavailable();
}
