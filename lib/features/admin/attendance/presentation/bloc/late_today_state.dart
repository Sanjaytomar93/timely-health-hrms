import 'package:equatable/equatable.dart';
import 'package:timelay_health/features/admin/attendance/presentation/models/late_today_ui.dart';

abstract class LateTodayState extends Equatable {
  const LateTodayState({
    required this.ui,
    this.searchQuery = '',
    this.selectedDate,
    this.selectedMonth,
  });

  final LateTodayUi ui;
  final String searchQuery;
  final String? selectedDate;
  final String? selectedMonth;

  @override
  List<Object?> get props => [
        ui,
        searchQuery,
        selectedDate,
        selectedMonth,
      ];
}

class LateTodayInitial extends LateTodayState {
  const LateTodayInitial() : super(ui: LateTodayUi.empty);
}

class LateTodayLoading extends LateTodayState {
  const LateTodayLoading({
    required LateTodayUi ui,
    String searchQuery = '',
    String? selectedDate,
    String? selectedMonth,
  }) : super(
          ui: ui,
          searchQuery: searchQuery,
          selectedDate: selectedDate,
          selectedMonth: selectedMonth,
        );
}

class LateTodayLoaded extends LateTodayState {
  const LateTodayLoaded({
    required LateTodayUi ui,
    String searchQuery = '',
    String? selectedDate,
    String? selectedMonth,
  }) : super(
          ui: ui,
          searchQuery: searchQuery,
          selectedDate: selectedDate,
          selectedMonth: selectedMonth,
        );

  LateTodayLoaded copyWith({
    LateTodayUi? ui,
    String? searchQuery,
    String? selectedDate,
    String? selectedMonth,
  }) {
    return LateTodayLoaded(
      ui: ui ?? this.ui,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedMonth: selectedMonth ?? this.selectedMonth,
    );
  }
}

class LateTodayFailureState extends LateTodayState {
  const LateTodayFailureState({
    required LateTodayUi ui,
    required this.message,
    String searchQuery = '',
    String? selectedDate,
    String? selectedMonth,
  }) : super(
          ui: ui,
          searchQuery: searchQuery,
          selectedDate: selectedDate,
          selectedMonth: selectedMonth,
        );

  final String message;

  @override
  List<Object?> get props => [
        ui,
        message,
        searchQuery,
        selectedDate,
        selectedMonth,
      ];
}
