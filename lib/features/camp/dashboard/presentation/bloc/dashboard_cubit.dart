import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelay_health/features/auth/data/auth_session.dart';
import 'package:timelay_health/features/camp/dashboard/data/repositories_impl/dashboard_repository_impl.dart';
import 'package:timelay_health/features/camp/dashboard/domain/failures/dashboard_failure.dart';
import 'package:timelay_health/features/camp/dashboard/domain/usecases/get_volunteer_dashboard_usecase.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/models/camp_dashboard_ui.dart';
import 'package:timelay_health/features/camp/shared/camp_memory_cache.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({GetVolunteerDashboardUseCase? getVolunteerDashboardUseCase})
      : _getDashboard = getVolunteerDashboardUseCase ??
            GetVolunteerDashboardUseCase(DashboardRepositoryImpl()),
        super(const DashboardInitial());

  final GetVolunteerDashboardUseCase _getDashboard;

  CampDashboardUi _data = CampDashboardUi.empty;

  Future<void> load({bool keepExisting = false}) async {
    final employee = AuthSession.currentEmployee ?? await AuthSession.load();
    final employeeName = employee?.displayName.trim() ?? '';

    if (isClosed) return;

    if (employeeName.isEmpty) {
      emit(
        DashboardFailureState(
          'Employee name missing. Please login again.',
          data: keepExisting ? _data : CampDashboardUi.empty,
        ),
      );
      return;
    }

    final cached = CampMemoryCache.dashboard(employeeName);
    final hasCache = cached != null && cached.stats.isNotEmpty;
    if (cached != null && hasCache) {
      _data = cached;
      emit(DashboardLoaded(data: _data));
    } else {
      emit(
        DashboardLoading(
          data: keepExisting ? _data : CampDashboardUi.empty,
        ),
      );
    }

    try {
      final dashboard = await _getDashboard(employeeName);
      if (isClosed) return;
      _data = CampDashboardUiMapper.fromEntity(
        dashboard,
        employeeName: employeeName,
      );
      CampMemoryCache.setDashboard(employeeName, _data);
      emit(DashboardLoaded(data: _data));
    } on DashboardFailure catch (e) {
      if (isClosed) return;
      if (hasCache) return;
      emit(
        DashboardFailureState(
          e.message,
          data: keepExisting ? _data : CampDashboardUi.empty,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      if (hasCache) return;
      emit(
        DashboardFailureState(
          'Failed to load dashboard. Please try again.',
          data: keepExisting ? _data : CampDashboardUi.empty,
        ),
      );
    }
  }
}
