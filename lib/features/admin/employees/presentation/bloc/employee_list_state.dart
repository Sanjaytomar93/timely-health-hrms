import 'package:equatable/equatable.dart';
import 'package:timelay_health/features/admin/employees/presentation/models/employee_list_ui.dart';

abstract class EmployeeListState extends Equatable {
  const EmployeeListState({
    required this.ui,
  });

  final EmployeeListUi ui;

  @override
  List<Object?> get props => [ui];
}

class EmployeeListInitial extends EmployeeListState {
  const EmployeeListInitial() : super(ui: EmployeeListUi.empty);
}

class EmployeeListLoading extends EmployeeListState {
  const EmployeeListLoading({EmployeeListUi? currentUi})
      : super(ui: currentUi ?? EmployeeListUi.empty);
}

class EmployeeListLoaded extends EmployeeListState {
  const EmployeeListLoaded(EmployeeListUi ui) : super(ui: ui);
}

class EmployeeListFailureState extends EmployeeListState {
  const EmployeeListFailureState(
    this.message, {
    EmployeeListUi? currentUi,
  }) : super(ui: currentUi ?? EmployeeListUi.empty);

  final String message;

  @override
  List<Object?> get props => [message, ui];
}
