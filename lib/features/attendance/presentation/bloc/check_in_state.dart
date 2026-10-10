import 'package:equatable/equatable.dart';
import 'package:timelay_health/features/attendance/domain/entities/check_in_result.dart';
import 'package:timelay_health/features/attendance/domain/entities/employee_location_assignment.dart';

enum MarkAttendanceMode { checkIn, checkOut }

class CheckInReadyData extends Equatable {
  const CheckInReadyData({
    required this.employeeId,
    required this.employeeEmail,
    required this.displayName,
    required this.requirePhoto,
    required this.mode,
    required this.latitude,
    required this.longitude,
    required this.distanceMeters,
    required this.withinRadius,
    required this.officeRadiusMeters,
    required this.now,
    this.office,
    this.employeeAddress = '',
    this.locationCaptured = false,
  });

  final String employeeId;
  final String employeeEmail;
  final String displayName;
  final bool requirePhoto;
  final MarkAttendanceMode mode;
  final double latitude;
  final double longitude;
  final int distanceMeters;
  final bool withinRadius;
  final int officeRadiusMeters;
  final DateTime now;
  final EmployeeLocationAssignment? office;
  final String employeeAddress;
  final bool locationCaptured;

  String get officeName {
    final name = office?.name.trim() ?? '';
    return name.isEmpty ? 'Assigned office' : name;
  }

  CheckInReadyData copyWith({
    double? latitude,
    double? longitude,
    int? distanceMeters,
    bool? withinRadius,
    DateTime? now,
    EmployeeLocationAssignment? office,
    bool? locationCaptured,
    MarkAttendanceMode? mode,
    bool? requirePhoto,
  }) {
    return CheckInReadyData(
      employeeId: employeeId,
      employeeEmail: employeeEmail,
      displayName: displayName,
      requirePhoto: requirePhoto ?? this.requirePhoto,
      mode: mode ?? this.mode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      withinRadius: withinRadius ?? this.withinRadius,
      officeRadiusMeters: officeRadiusMeters,
      now: now ?? this.now,
      office: office ?? this.office,
      employeeAddress: employeeAddress,
      locationCaptured: locationCaptured ?? this.locationCaptured,
    );
  }

  @override
  List<Object?> get props => [
    employeeId,
    employeeEmail,
    displayName,
    requirePhoto,
    mode,
    latitude,
    longitude,
    distanceMeters,
    withinRadius,
    officeRadiusMeters,
    now,
    office,
    employeeAddress,
    locationCaptured,
  ];
}

sealed class CheckInState extends Equatable {
  const CheckInState();

  CheckInReadyData? get readyData => null;

  @override
  List<Object?> get props => [];
}

class CheckInInitial extends CheckInState {
  const CheckInInitial();
}

class CheckInPreparing extends CheckInState {
  const CheckInPreparing();
}

class CheckInReady extends CheckInState {
  const CheckInReady(this.data);
  final CheckInReadyData data;

  @override
  CheckInReadyData? get readyData => data;

  @override
  List<Object?> get props => [data];
}

class CheckInCapturingLocation extends CheckInState {
  const CheckInCapturingLocation(this.data);
  final CheckInReadyData data;

  @override
  CheckInReadyData? get readyData => data;

  @override
  List<Object?> get props => [data];
}

class CheckInSubmitting extends CheckInState {
  const CheckInSubmitting(this.data);
  final CheckInReadyData data;

  @override
  CheckInReadyData? get readyData => data;

  @override
  List<Object?> get props => [data];
}

class CheckInSuccess extends CheckInState {
  const CheckInSuccess({
    required this.data,
    required this.result,
    this.checkOutResult,
  });

  final CheckInReadyData data;
  final CheckInResult? result;
  final CheckOutResult? checkOutResult;

  @override
  CheckInReadyData? get readyData => data;

  @override
  List<Object?> get props => [data, result, checkOutResult];
}

class CheckInFailureState extends CheckInState {
  const CheckInFailureState(this.message, {this.data});

  final String message;
  final CheckInReadyData? data;

  @override
  CheckInReadyData? get readyData => data;

  @override
  List<Object?> get props => [message, data];
}
