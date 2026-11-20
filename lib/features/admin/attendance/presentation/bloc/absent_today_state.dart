import 'package:equatable/equatable.dart';
import 'package:timelay_health/features/admin/attendance/presentation/models/absent_today_ui.dart';

abstract class AbsentTodayState extends Equatable {
  const AbsentTodayState({
    required this.ui,
    this.searchQuery = '',
    this.selectedFromDate,
    this.selectedToDate,
  });

  final AbsentTodayUi ui;
  final String searchQuery;
  final String? selectedFromDate;
  final String? selectedToDate;

  @override
  List<Object?> get props => [
        ui,
        searchQuery,
        selectedFromDate,
        selectedToDate,
      ];
}

class AbsentTodayInitial extends AbsentTodayState {
  const AbsentTodayInitial() : super(ui: AbsentTodayUi.empty);
}

class AbsentTodayLoading extends AbsentTodayState {
  const AbsentTodayLoading({
    required AbsentTodayUi ui,
    String searchQuery = '',
    String? selectedFromDate,
    String? selectedToDate,
  }) : super(
          ui: ui,
          searchQuery: searchQuery,
          selectedFromDate: selectedFromDate,
          selectedToDate: selectedToDate,
        );
}

class AbsentTodayLoaded extends AbsentTodayState {
  const AbsentTodayLoaded({
    required AbsentTodayUi ui,
    String searchQuery = '',
    String? selectedFromDate,
    String? selectedToDate,
  }) : super(
          ui: ui,
          searchQuery: searchQuery,
          selectedFromDate: selectedFromDate,
          selectedToDate: selectedToDate,
        );

  AbsentTodayLoaded copyWith({
    AbsentTodayUi? ui,
    String? searchQuery,
    String? selectedFromDate,
    String? selectedToDate,
  }) {
    return AbsentTodayLoaded(
      ui: ui ?? this.ui,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedFromDate: selectedFromDate ?? this.selectedFromDate,
      selectedToDate: selectedToDate ?? this.selectedToDate,
    );
  }
}

class AbsentTodayFailureState extends AbsentTodayState {
  const AbsentTodayFailureState({
    required AbsentTodayUi ui,
    required this.message,
    String searchQuery = '',
    String? selectedFromDate,
    String? selectedToDate,
  }) : super(
          ui: ui,
          searchQuery: searchQuery,
          selectedFromDate: selectedFromDate,
          selectedToDate: selectedToDate,
        );

  final String message;

  @override
  List<Object?> get props => [
        ...super.props,
        message,
      ];
}
