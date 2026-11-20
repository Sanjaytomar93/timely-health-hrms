import 'package:equatable/equatable.dart';
import 'package:timelay_health/features/admin/attendance/presentation/models/attendance_records_ui.dart';

abstract class AttendanceRecordsState extends Equatable {
  const AttendanceRecordsState({
    required this.ui,
    required this.selectedMonth,
    this.selectedDepartment,
    this.selectedDesignation,
    this.selectedDate,
    this.searchQuery = '',
    this.page = 1,
    this.isFetchingMore = false,
    this.hasReachedMax = false,
  });

  final AttendanceRecordsUi ui;
  final String selectedMonth;
  final String? selectedDepartment;
  final String? selectedDesignation;
  final String? selectedDate;
  final String searchQuery;
  final int page;
  final bool isFetchingMore;
  final bool hasReachedMax;

  @override
  List<Object?> get props => [
        ui,
        selectedMonth,
        selectedDepartment,
        selectedDesignation,
        selectedDate,
        searchQuery,
        page,
        isFetchingMore,
        hasReachedMax,
      ];
}

class AttendanceRecordsInitial extends AttendanceRecordsState {
  AttendanceRecordsInitial({required String month})
      : super(
          ui: AttendanceRecordsUi.empty,
          selectedMonth: month,
        );
}

class AttendanceRecordsLoading extends AttendanceRecordsState {
  const AttendanceRecordsLoading({
    required AttendanceRecordsUi ui,
    required String selectedMonth,
    String? selectedDepartment,
    String? selectedDesignation,
    String? selectedDate,
    String searchQuery = '',
    int page = 1,
    bool isFetchingMore = false,
    bool hasReachedMax = false,
  }) : super(
          ui: ui,
          selectedMonth: selectedMonth,
          selectedDepartment: selectedDepartment,
          selectedDesignation: selectedDesignation,
          selectedDate: selectedDate,
          searchQuery: searchQuery,
          page: page,
          isFetchingMore: isFetchingMore,
          hasReachedMax: hasReachedMax,
        );
}

class AttendanceRecordsLoaded extends AttendanceRecordsState {
  const AttendanceRecordsLoaded({
    required AttendanceRecordsUi ui,
    required String selectedMonth,
    String? selectedDepartment,
    String? selectedDesignation,
    String? selectedDate,
    String searchQuery = '',
    int page = 1,
    bool isFetchingMore = false,
    bool hasReachedMax = false,
  }) : super(
          ui: ui,
          selectedMonth: selectedMonth,
          selectedDepartment: selectedDepartment,
          selectedDesignation: selectedDesignation,
          selectedDate: selectedDate,
          searchQuery: searchQuery,
          page: page,
          isFetchingMore: isFetchingMore,
          hasReachedMax: hasReachedMax,
        );

  AttendanceRecordsLoaded copyWith({
    AttendanceRecordsUi? ui,
    String? selectedMonth,
    String? selectedDepartment,
    String? selectedDesignation,
    String? selectedDate,
    String? searchQuery,
    int? page,
    bool? isFetchingMore,
    bool? hasReachedMax,
  }) {
    return AttendanceRecordsLoaded(
      ui: ui ?? this.ui,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedDepartment: selectedDepartment ?? this.selectedDepartment,
      selectedDesignation: selectedDesignation ?? this.selectedDesignation,
      selectedDate: selectedDate ?? this.selectedDate,
      searchQuery: searchQuery ?? this.searchQuery,
      page: page ?? this.page,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class AttendanceRecordsFailureState extends AttendanceRecordsState {
  const AttendanceRecordsFailureState({
    required this.message,
    required AttendanceRecordsUi ui,
    required String selectedMonth,
    String? selectedDepartment,
    String? selectedDesignation,
    String? selectedDate,
    String searchQuery = '',
    int page = 1,
    bool isFetchingMore = false,
    bool hasReachedMax = false,
  }) : super(
          ui: ui,
          selectedMonth: selectedMonth,
          selectedDepartment: selectedDepartment,
          selectedDesignation: selectedDesignation,
          selectedDate: selectedDate,
          searchQuery: searchQuery,
          page: page,
          isFetchingMore: isFetchingMore,
          hasReachedMax: hasReachedMax,
        );

  final String message;

  @override
  List<Object?> get props => [
        message,
        ui,
        selectedMonth,
        selectedDepartment,
        selectedDesignation,
        selectedDate,
        searchQuery,
        page,
        isFetchingMore,
        hasReachedMax,
      ];
}
