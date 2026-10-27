import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:timelay_health/core/location/location_helper.dart';
import 'package:timelay_health/features/attendance/data/repositories_impl/attendance_repository_impl.dart';
import 'package:timelay_health/features/attendance/domain/entities/attendance_record.dart';
import 'package:timelay_health/features/attendance/domain/entities/check_in_params.dart';
import 'package:timelay_health/features/attendance/domain/entities/employee_location_assignment.dart';
import 'package:timelay_health/features/attendance/domain/failures/attendance_failure.dart';
import 'package:timelay_health/features/attendance/domain/usecases/check_in_usecase.dart';
import 'package:timelay_health/features/attendance/domain/usecases/get_all_locations_usecase.dart';
import 'package:timelay_health/features/attendance/domain/usecases/get_my_attendance_usecase.dart';
import 'package:timelay_health/features/attendance/domain/usecases/get_my_location_usecase.dart';
import 'package:timelay_health/features/attendance/presentation/bloc/check_in_state.dart';
import 'package:timelay_health/features/auth/data/auth_session.dart';
import 'package:timelay_health/features/auth/data/repositories_impl/auth_repository_impl.dart';
import 'package:timelay_health/features/auth/domain/entities/employee.dart';
import 'package:timelay_health/features/auth/domain/failures/auth_failure.dart';
import 'package:timelay_health/features/auth/domain/usecases/get_employee_usecase.dart';

class CheckInCubit extends Cubit<CheckInState> {
  CheckInCubit({
    GetEmployeeUseCase? getEmployeeUseCase,
    GetMyLocationUseCase? getMyLocationUseCase,
    GetMyAttendanceUseCase? getMyAttendanceUseCase,
    CheckInUseCase? checkInUseCase,
    CheckOutUseCase? checkOutUseCase,
    GetAllLocationsUseCase? getAllLocationsUseCase,
  }) : _getEmployee =
           getEmployeeUseCase ?? GetEmployeeUseCase(AuthRepositoryImpl()),
       _getLocation =
           getMyLocationUseCase ??
           GetMyLocationUseCase(AttendanceRepositoryImpl()),
       _getAttendance =
           getMyAttendanceUseCase ??
           GetMyAttendanceUseCase(AttendanceRepositoryImpl()),
       _checkIn = checkInUseCase ?? CheckInUseCase(AttendanceRepositoryImpl()),
       _checkOut =
           checkOutUseCase ?? CheckOutUseCase(AttendanceRepositoryImpl()),
       _getAllLocations =
           getAllLocationsUseCase ??
           GetAllLocationsUseCase(AttendanceRepositoryImpl()),
       super(const CheckInInitial());

  final GetEmployeeUseCase _getEmployee;
  final GetMyLocationUseCase _getLocation;
  final GetMyAttendanceUseCase _getAttendance;
  final CheckInUseCase _checkIn;
  final CheckOutUseCase _checkOut;
  final GetAllLocationsUseCase _getAllLocations;

  static const officeRadiusMeters = 50;

  CheckInReadyData? _data;
  Future<void>? _prepareFuture;
  List<EmployeeLocationAssignment>? _allLocations;

  Future<void> prepare() {
    return _prepareFuture ??= _doPrepare();
  }

  Future<void> _doPrepare() async {
    emit(const CheckInPreparing());
    try {
      final cached = AuthSession.currentEmployee ?? await AuthSession.load();
      if (isClosed) return;
      final employeeId = cached?.employeeId.trim() ?? '';
      if (employeeId.isEmpty) {
        emit(
          const CheckInFailureState('Employee ID missing. Please login again.'),
        );
        return;
      }

      final employeeFuture = _resolveEmployee(employeeId, cached);
      final officeFuture = _getLocation(employeeId);
      final attendanceFuture = _safeAttendance(employeeId);

      final results = await Future.wait<Object?>([
        employeeFuture,
        officeFuture,
        attendanceFuture,
      ]);

      if (isClosed) return;

      final employee = results[0] as Employee;
      final office = results[1] as EmployeeLocationAssignment;
      final attendance = results[2] as MyAttendanceResult?;

      if (office.latitude == 0 && office.longitude == 0) {
        emit(
          const CheckInFailureState(
            'No office location assigned. Contact admin.',
          ),
        );
        return;
      }

      _data = CheckInReadyData(
        employeeId: employeeId,
        employeeEmail: employee.email.trim(),
        displayName: employee.displayName,
        requirePhoto: employee.isAllowedImageCapturedAttendance,
        mode: _resolveMode(attendance),
        latitude: 0,
        longitude: 0,
        distanceMeters: 0,
        withinRadius: true,
        officeRadiusMeters: officeRadiusMeters,
        now: DateTime.now(),
        office: office,
        employeeAddress: employee.address?.trim() ?? '',
        locationCaptured: false,
      );
      // ignore: avoid_print
      print(
        '[attendance] isAllowedImageCapturedAttendance='
        '${employee.isAllowedImageCapturedAttendance}',
      );
      emit(CheckInReady(_data!));
    } on AttendanceFailure catch (e) {
      if (isClosed) return;
      _prepareFuture = null;
      emit(CheckInFailureState(e.message));
    } on AuthFailure catch (e) {
      if (isClosed) return;
      _prepareFuture = null;
      emit(CheckInFailureState(e.message));
    } catch (_) {
      if (isClosed) return;
      _prepareFuture = null;
      emit(
        const CheckInFailureState(
          'Unable to prepare attendance. Please try again.',
        ),
      );
    }
  }

  Future<Employee> _resolveEmployee(String employeeId, Employee? cached) async {
    if (cached != null) return cached;
    final employee = await _getEmployee(employeeId);
    await AuthSession.save(employee);
    return employee;
  }

  Future<MyAttendanceResult?> _safeAttendance(String employeeId) async {
    try {
      return await _getAttendance(employeeId);
    } catch (_) {
      return null;
    }
  }

  MarkAttendanceMode _resolveMode(MyAttendanceResult? attendance) {
    if (attendance == null) return MarkAttendanceMode.checkIn;
    final today = DateTime.now();
    final todayRecords = attendance.records.where((r) {
      final d = r.checkInTime;
      if (d == null) return false;
      final local = d.toLocal();
      return local.year == today.year &&
          local.month == today.month &&
          local.day == today.day;
    });
    final latest = todayRecords.isEmpty
        ? null
        : todayRecords.reduce((a, b) {
            final at = a.checkInTime ?? DateTime(1970);
            final bt = b.checkInTime ?? DateTime(1970);
            return at.isAfter(bt) ? a : b;
          });
    if (latest != null && latest.isCheckedIn && latest.checkOutTime == null) {
      return MarkAttendanceMode.checkOut;
    }
    return MarkAttendanceMode.checkIn;
  }

  Future<void> captureLocation() async {
    final current = _data;
    if (current == null) return;
    final office = current.office;
    if (office == null) {
      emit(CheckInFailureState('No office location assigned.', data: current));
      return;
    }

    emit(CheckInCapturingLocation(current));
    try {
      var requirePhoto = current.requirePhoto;
      try {
        final employee = await _getEmployee(current.employeeId);
        await AuthSession.save(employee);
        requirePhoto = employee.isAllowedImageCapturedAttendance;
      } catch (_) {}

      final position = await LocationHelper.getCurrentPosition(
        allowFallback: false,
        precise: true,
      );
      if (isClosed) return;
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        office.latitude,
        office.longitude,
      ).round();
      final within = distance <= officeRadiusMeters;

      _data = current.copyWith(
        latitude: position.latitude,
        longitude: position.longitude,
        distanceMeters: distance,
        withinRadius: within,
        now: DateTime.now(),
        locationCaptured: true,
        requirePhoto: requirePhoto,
      );
      emit(CheckInReady(_data!));
    } on LocationFailure catch (e) {
      if (isClosed) return;
      emit(CheckInFailureState(e.message, data: current));
      emit(CheckInReady(current));
    } catch (_) {
      if (isClosed) return;
      emit(
        CheckInFailureState(
          'Unable to get location. Please try again.',
          data: current,
        ),
      );
      emit(CheckInReady(current));
    }
  }

  Future<void> refreshLocation() => captureLocation();

  Future<List<EmployeeLocationAssignment>> loadAllLocations() async {
    final cached = _allLocations;
    if (cached != null) return cached;
    final all = await _getAllLocations();
    return _allLocations = all.where((l) => l.isActive).toList();
  }

  void selectOffice(EmployeeLocationAssignment office) {
    final current = _data;
    if (current == null || isClosed) return;
    if (!current.locationCaptured) {
      _data = current.copyWith(office: office);
    } else {
      final distance = Geolocator.distanceBetween(
        current.latitude,
        current.longitude,
        office.latitude,
        office.longitude,
      ).round();
      _data = current.copyWith(
        office: office,
        distanceMeters: distance,
        withinRadius: distance <= officeRadiusMeters,
      );
    }
    emit(CheckInReady(_data!));
  }

  String? _resolveReason(String? reason, {required bool withinRadius}) {
    final selected = reason?.trim() ?? '';
    if (selected.isNotEmpty) return selected;
    if (withinRadius) return 'Onsite';
    return null;
  }

  bool needsReason() {
    final data = _data;
    if (data == null || !data.locationCaptured) return false;
    if (data.mode == MarkAttendanceMode.checkOut) return false;
    return !data.withinRadius;
  }

  Future<void> submit({String? reason, String? imagePath}) async {
    final data = _data;
    if (data == null) return;

    if (!data.locationCaptured) {
      emit(CheckInFailureState('Please get location first.', data: data));
      return;
    }

    if (data.requirePhoto && (imagePath == null || imagePath.trim().isEmpty)) {
      emit(
        CheckInFailureState('Please capture a photo to continue.', data: data),
      );
      return;
    }

    if (data.mode == MarkAttendanceMode.checkIn &&
        data.employeeEmail.trim().isEmpty) {
      emit(
        CheckInFailureState(
          'Employee email missing. Please login again.',
          data: data,
        ),
      );
      return;
    }

    if (data.mode == MarkAttendanceMode.checkIn &&
        !data.withinRadius &&
        (reason == null || reason.trim().isEmpty)) {
      emit(
        CheckInFailureState('Please select a reason for check-in.', data: data),
      );
      return;
    }

    final resolvedReason = _resolveReason(
      reason,
      withinRadius: data.withinRadius,
    );

    emit(CheckInSubmitting(data));
    try {
      if (data.mode == MarkAttendanceMode.checkOut) {
        final result = await _checkOut(
          CheckOutParams(
            employeeId: data.employeeId,
            employeeEmail: data.employeeEmail,
            latitude: data.latitude,
            longitude: data.longitude,
            reason: resolvedReason,
            imagePath: data.requirePhoto ? imagePath : null,
          ),
        );
        if (isClosed) return;
        emit(CheckInSuccess(data: data, result: null, checkOutResult: result));
        return;
      }

      final result = await _checkIn(
        CheckInParams(
          employeeId: data.employeeId,
          employeeEmail: data.employeeEmail,
          latitude: data.latitude,
          longitude: data.longitude,
          reason: resolvedReason,
          imagePath: data.requirePhoto ? imagePath : null,
        ),
      );
      if (isClosed) return;
      emit(CheckInSuccess(data: data, result: result));
    } on AttendanceFailure catch (e) {
      if (isClosed) return;
      emit(CheckInFailureState(e.message, data: data));
    } catch (e) {
      if (isClosed) return;
      emit(CheckInFailureState('Attendance request failed: $e', data: data));
    }
  }
}
