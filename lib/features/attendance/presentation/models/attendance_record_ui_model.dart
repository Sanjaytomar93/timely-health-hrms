import 'package:equatable/equatable.dart';

class AttendanceRecordUiModel {
  const AttendanceRecordUiModel({
    required this.id,
    required this.date,
    required this.checkInDate,
    required this.statusLabel,
    required this.isActive,
    required this.checkIn,
    required this.checkOut,
    required this.shiftTag,
    required this.durationTag,
    required this.locationTag,
    required this.distanceTag,
    required this.note,
    required this.onsite,
    required this.workingHours,
    required this.otHours,
    required this.otClaimed,
    required this.claimableOtHours,
    required this.otAmount,
    required this.otMultiplier,
    required this.assignedShiftHours,
    required this.distanceMeters,
    required this.exportDate,
    required this.exportCheckIn,
    required this.exportCheckOut,
    required this.exportStatus,
  });

  final String id;
  final String date;
  final DateTime? checkInDate;
  final String statusLabel;
  final bool isActive;
  final String checkIn;
  final String checkOut;
  final String shiftTag;
  final String durationTag;
  final String locationTag;
  final String distanceTag;
  final String note;
  final bool onsite;
  final double workingHours;
  final double otHours;
  final bool otClaimed;
  final double claimableOtHours;
  final double otAmount;

  bool get hasClaimableOt => claimableOtHours > 0 && !otClaimed;
  final double otMultiplier;
  final double assignedShiftHours;
  final double distanceMeters;
  final String exportDate;
  final String exportCheckIn;
  final String exportCheckOut;
  final String exportStatus;
}

class AttendanceStatsUiModel extends Equatable {
  const AttendanceStatsUiModel({
    required this.totalRecords,
    required this.onsiteDays,
    required this.checkedIn,
    required this.fullDays,
    required this.otHours,
    required this.otHoursLabel,
    required this.claimedOt,
  });

  final int totalRecords;
  final int onsiteDays;
  final int checkedIn;
  final int fullDays;
  final double otHours;
  final String otHoursLabel;
  final int claimedOt;

  bool get hasOt => otHours > 0;

  static const empty = AttendanceStatsUiModel(
    totalRecords: 0,
    onsiteDays: 0,
    checkedIn: 0,
    fullDays: 0,
    otHours: 0,
    otHoursLabel: '0',
    claimedOt: 0,
  );

  @override
  List<Object?> get props => [
    totalRecords,
    onsiteDays,
    checkedIn,
    fullDays,
    otHours,
    otHoursLabel,
    claimedOt,
  ];
}

class AttendanceFilter extends Equatable {
  const AttendanceFilter({
    this.exactDate,
    this.fromDate,
    this.toDate,
    this.status = AttendanceStatusFilter.all,
    this.location = AttendanceLocationFilter.all,
    this.otOnly = false,
  });

  final DateTime? exactDate;
  final DateTime? fromDate;
  final DateTime? toDate;
  final AttendanceStatusFilter status;
  final AttendanceLocationFilter location;
  final bool otOnly;

  static const empty = AttendanceFilter();

  bool get hasActiveFilters =>
      exactDate != null ||
      fromDate != null ||
      toDate != null ||
      status != AttendanceStatusFilter.all ||
      location != AttendanceLocationFilter.all ||
      otOnly;

  AttendanceFilter copyWith({
    DateTime? exactDate,
    DateTime? fromDate,
    DateTime? toDate,
    AttendanceStatusFilter? status,
    AttendanceLocationFilter? location,
    bool? otOnly,
    bool clearExactDate = false,
    bool clearFromDate = false,
    bool clearToDate = false,
  }) {
    return AttendanceFilter(
      exactDate: clearExactDate ? null : (exactDate ?? this.exactDate),
      fromDate: clearFromDate ? null : (fromDate ?? this.fromDate),
      toDate: clearToDate ? null : (toDate ?? this.toDate),
      status: status ?? this.status,
      location: location ?? this.location,
      otOnly: otOnly ?? this.otOnly,
    );
  }

  @override
  List<Object?> get props => [
    exactDate,
    fromDate,
    toDate,
    status,
    location,
    otOnly,
  ];
}

enum AttendanceStatusFilter { all, active, loggedOut }

enum AttendanceLocationFilter { all, onsite, wfh }
