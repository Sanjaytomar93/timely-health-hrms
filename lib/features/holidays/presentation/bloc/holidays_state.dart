import 'package:equatable/equatable.dart';
import 'package:timelay_health/features/holidays/presentation/models/holiday_ui_model.dart';

sealed class HolidaysState extends Equatable {
  const HolidaysState({
    this.holidays = const [],
    this.allHolidays = const [],
    this.stats = HolidayStatsUiModel.empty,
    this.search = '',
    this.type = 'All',
    this.month,
  });

  final List<HolidayUiModel> holidays;
  final List<HolidayUiModel> allHolidays;
  final HolidayStatsUiModel stats;
  final String search;
  final String type;

  /// First day of the filtered month, or null for all months.
  final DateTime? month;

  @override
  List<Object?> get props => [
    holidays,
    allHolidays,
    stats,
    search,
    type,
    month,
  ];
}

class HolidaysInitial extends HolidaysState {
  const HolidaysInitial();
}

class HolidaysLoading extends HolidaysState {
  const HolidaysLoading({
    super.holidays,
    super.allHolidays,
    super.stats,
    super.search,
    super.type,
    super.month,
  });
}

class HolidaysLoaded extends HolidaysState {
  const HolidaysLoaded({
    required super.holidays,
    required super.allHolidays,
    required super.stats,
    super.search,
    super.type,
    super.month,
  });
}

class HolidaysFailureState extends HolidaysState {
  const HolidaysFailureState(
    this.message, {
    super.holidays,
    super.allHolidays,
    super.stats,
    super.search,
    super.type,
    super.month,
  });

  final String message;

  @override
  List<Object?> get props => [message, ...super.props];
}
