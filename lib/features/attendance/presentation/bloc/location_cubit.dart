import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelay_health/features/attendance/data/repositories_impl/attendance_repository_impl.dart';
import 'package:timelay_health/features/attendance/domain/failures/attendance_failure.dart';
import 'package:timelay_health/features/attendance/domain/usecases/get_my_location_usecase.dart';
import 'package:timelay_health/features/attendance/presentation/bloc/location_state.dart';
import 'package:timelay_health/features/attendance/presentation/models/location_ui_model.dart';
import 'package:timelay_health/features/auth/data/auth_session.dart';

class LocationCubit extends Cubit<LocationState> {
  LocationCubit({GetMyLocationUseCase? getMyLocationUseCase})
    : _getMyLocation =
          getMyLocationUseCase ??
          GetMyLocationUseCase(AttendanceRepositoryImpl()),
      super(const LocationInitial());

  final GetMyLocationUseCase _getMyLocation;

  Future<void> load({bool keepExisting = false}) async {
    emit(
      LocationLoading(
        location: keepExisting ? state.location : null,
        headerDate: keepExisting ? state.headerDate : '',
      ),
    );

    final employee = AuthSession.currentEmployee ?? await AuthSession.load();
    final employeeId = employee?.employeeId ?? '';

    if (isClosed) return;

    if (employeeId.isEmpty) {
      emit(
        LocationFailureState(
          'Employee ID missing. Please login again.',
          location: keepExisting ? state.location : null,
          headerDate: keepExisting ? state.headerDate : '',
        ),
      );
      return;
    }

    try {
      final location = await _getMyLocation(employeeId);
      if (isClosed) return;
      emit(
        LocationLoaded(
          location: LocationUiMapper.toUi(
            location: location,
            employeeName: employee?.displayName ?? '',
            employeeId: employeeId,
          ),
          headerDate: LocationUiMapper.headerDateLabel(),
        ),
      );
    } on AttendanceFailure catch (e) {
      if (isClosed) return;
      emit(
        LocationFailureState(
          e.message,
          location: keepExisting ? state.location : null,
          headerDate: keepExisting ? state.headerDate : '',
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        LocationFailureState(
          'Failed to load location. Please try again.',
          location: keepExisting ? state.location : null,
          headerDate: keepExisting ? state.headerDate : '',
        ),
      );
    }
  }
}
