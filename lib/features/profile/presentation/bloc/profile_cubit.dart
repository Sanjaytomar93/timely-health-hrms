import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelay_health/features/auth/data/auth_session.dart';
import 'package:timelay_health/features/auth/data/repositories_impl/auth_repository_impl.dart';
import 'package:timelay_health/features/auth/domain/entities/employee.dart';
import 'package:timelay_health/features/auth/domain/failures/auth_failure.dart';
import 'package:timelay_health/features/auth/domain/usecases/get_employee_usecase.dart';
import 'package:timelay_health/features/profile/presentation/bloc/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({GetEmployeeUseCase? getEmployeeUseCase})
    : _getEmployeeUseCase =
          getEmployeeUseCase ?? GetEmployeeUseCase(AuthRepositoryImpl()),
      super(const ProfileInitial());

  final GetEmployeeUseCase _getEmployeeUseCase;

  Future<void> load({
    bool showFullScreenLoader = true,
    bool refresh = true,
  }) async {
    final cached = AuthSession.currentEmployee ?? await AuthSession.load();
    if (isClosed) return;

    if (!refresh && cached != null) {
      emit(ProfileLoaded(cached));
      return;
    }

    if (showFullScreenLoader || cached == null) {
      emit(ProfileLoading(employee: cached));
    } else {
      emit(ProfileLoaded(cached));
    }

    final employeeId = cached?.employeeId ?? '';
    if (employeeId.isEmpty) {
      if (isClosed) return;
      emit(const ProfileFailure('Employee ID not found. Please login again.'));
      return;
    }

    try {
      final employee = await _getEmployeeUseCase(employeeId);
      if (isClosed) return;
      await AuthSession.save(employee);
      if (isClosed) return;
      emit(ProfileLoaded(employee));
    } on AuthFailure catch (e) {
      if (isClosed) return;
      emit(ProfileFailure(e.message, employee: cached));
    } catch (_) {
      if (isClosed) return;
      emit(
        ProfileFailure(
          'Failed to load profile. Please try again.',
          employee: cached,
        ),
      );
    }
  }

  void syncFromSession() {
    if (isClosed) return;
    final employee = AuthSession.currentEmployee;
    if (employee != null) {
      emit(ProfileLoaded(employee));
    }
  }

  Employee? get currentEmployee {
    final state = this.state;
    return switch (state) {
      ProfileLoaded(:final employee) => employee,
      ProfileLoading(:final employee) => employee,
      ProfileFailure(:final employee) => employee,
      _ => AuthSession.currentEmployee,
    };
  }
}
