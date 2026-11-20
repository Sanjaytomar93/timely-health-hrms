import 'package:equatable/equatable.dart';
import 'package:timelay_health/features/admin/attendance/presentation/models/today_attendance_ui.dart';

abstract class TodayAttendanceState extends Equatable {
  const TodayAttendanceState({
    required this.ui,
    this.searchQuery = '',
    this.selectedMonth,
    this.selectedDate,
    this.page = 1,
    this.isFetchingMore = false,
    this.hasReachedMax = true,
    this.usePagedMonth = false,
  });

  final TodayAttendanceUi ui;
  final String searchQuery;
  final String? selectedMonth;
  final String? selectedDate;
  final int page;
  final bool isFetchingMore;
  final bool hasReachedMax;
  final bool usePagedMonth;

  @override
  List<Object?> get props => [
        ui,
        searchQuery,
        selectedMonth,
        selectedDate,
        page,
        isFetchingMore,
        hasReachedMax,
        usePagedMonth,
      ];
}

class TodayAttendanceInitial extends TodayAttendanceState {
  const TodayAttendanceInitial() : super(ui: TodayAttendanceUi.empty);
}

class TodayAttendanceLoading extends TodayAttendanceState {
  const TodayAttendanceLoading({
    required TodayAttendanceUi ui,
    String searchQuery = '',
    String? selectedMonth,
    String? selectedDate,
    int page = 1,
    bool isFetchingMore = false,
    bool hasReachedMax = false,
    bool usePagedMonth = false,
  }) : super(
          ui: ui,
          searchQuery: searchQuery,
          selectedMonth: selectedMonth,
          selectedDate: selectedDate,
          page: page,
          isFetchingMore: isFetchingMore,
          hasReachedMax: hasReachedMax,
          usePagedMonth: usePagedMonth,
        );
}

class TodayAttendanceLoaded extends TodayAttendanceState {
  const TodayAttendanceLoaded({
    required TodayAttendanceUi ui,
    String searchQuery = '',
    String? selectedMonth,
    String? selectedDate,
    int page = 1,
    bool isFetchingMore = false,
    bool hasReachedMax = true,
    bool usePagedMonth = false,
  }) : super(
          ui: ui,
          searchQuery: searchQuery,
          selectedMonth: selectedMonth,
          selectedDate: selectedDate,
          page: page,
          isFetchingMore: isFetchingMore,
          hasReachedMax: hasReachedMax,
          usePagedMonth: usePagedMonth,
        );

  TodayAttendanceLoaded copyWith({
    TodayAttendanceUi? ui,
    String? searchQuery,
    String? selectedMonth,
    String? selectedDate,
    int? page,
    bool? isFetchingMore,
    bool? hasReachedMax,
    bool? usePagedMonth,
  }) {
    return TodayAttendanceLoaded(
      ui: ui ?? this.ui,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedDate: selectedDate ?? this.selectedDate,
      page: page ?? this.page,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      usePagedMonth: usePagedMonth ?? this.usePagedMonth,
    );
  }
}

class TodayAttendanceFailureState extends TodayAttendanceState {
  const TodayAttendanceFailureState({
    required this.message,
    required TodayAttendanceUi ui,
    String searchQuery = '',
    String? selectedMonth,
    String? selectedDate,
    int page = 1,
    bool isFetchingMore = false,
    bool hasReachedMax = true,
    bool usePagedMonth = false,
  }) : super(
          ui: ui,
          searchQuery: searchQuery,
          selectedMonth: selectedMonth,
          selectedDate: selectedDate,
          page: page,
          isFetchingMore: isFetchingMore,
          hasReachedMax: hasReachedMax,
          usePagedMonth: usePagedMonth,
        );

  final String message;

  @override
  List<Object?> get props => [
        message,
        ui,
        searchQuery,
        selectedMonth,
        selectedDate,
        page,
        isFetchingMore,
        hasReachedMax,
        usePagedMonth,
      ];
}
