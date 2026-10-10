import 'package:equatable/equatable.dart';
import 'package:timelay_health/features/payslips/presentation/models/payslip_ui_model.dart';

sealed class PayslipsState extends Equatable {
  const PayslipsState({
    required this.selectedDate,
    this.payslip,
    this.stats = PayslipStatsUiModel.empty,
    this.search = '',
  });

  final DateTime selectedDate;
  final PayslipUiModel? payslip;
  final PayslipStatsUiModel stats;
  final String search;

  @override
  List<Object?> get props => [selectedDate, payslip, stats, search];
}

class PayslipsInitial extends PayslipsState {
  PayslipsInitial() : super(selectedDate: DateTime.now());
}

class PayslipsLoading extends PayslipsState {
  const PayslipsLoading({
    required super.selectedDate,
    super.payslip,
    super.stats,
    super.search,
  });
}

class PayslipsLoaded extends PayslipsState {
  const PayslipsLoaded({
    required super.selectedDate,
    required PayslipUiModel payslip,
    required super.stats,
    super.search,
  }) : super(payslip: payslip);

  @override
  PayslipUiModel get payslip => super.payslip!;
}

class PayslipsFailureState extends PayslipsState {
  const PayslipsFailureState(
    this.message, {
    required super.selectedDate,
    super.payslip,
    super.stats,
    super.search,
  });

  final String message;

  @override
  List<Object?> get props => [message, ...super.props];
}
