import 'package:equatable/equatable.dart';
import 'package:timelay_health/features/admin/shift/presentation/models/admin_shift_model.dart';

abstract class AdminShiftState extends Equatable {
  const AdminShiftState({required this.ui});

  final AdminShiftUi ui;

  @override
  List<Object?> get props => [ui];
}

class AdminShiftInitial extends AdminShiftState {
  const AdminShiftInitial() : super(ui: AdminShiftUi.empty);
}

class AdminShiftLoading extends AdminShiftState {
  const AdminShiftLoading({required AdminShiftUi ui}) : super(ui: ui);
}

class AdminShiftLoaded extends AdminShiftState {
  const AdminShiftLoaded({required AdminShiftUi ui}) : super(ui: ui);
}

class AdminShiftFailureState extends AdminShiftState {
  const AdminShiftFailureState({
    required AdminShiftUi ui,
    required this.message,
  }) : super(ui: ui);

  final String message;

  @override
  List<Object?> get props => [ui, message];
}
