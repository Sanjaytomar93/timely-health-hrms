import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelay_health/features/admin/shift/data/repositories_impl/admin_shift_repository_impl.dart';
import 'package:timelay_health/features/admin/shift/domain/failures/admin_shift_failure.dart';
import 'package:timelay_health/features/admin/shift/domain/repositories/admin_shift_repository.dart';
import 'package:timelay_health/features/admin/shift/presentation/bloc/admin_shift_state.dart';
import 'package:timelay_health/features/admin/shift/presentation/models/admin_shift_model.dart';

class AdminShiftCubit extends Cubit<AdminShiftState> {
  AdminShiftCubit({AdminShiftRepository? repository})
      : _repository = repository ?? AdminShiftRepositoryImpl(),
        super(const AdminShiftInitial());

  final AdminShiftRepository _repository;

  Future<void> load({bool isRefresh = false}) async {
    if (!isRefresh && state is AdminShiftLoading) return;

    emit(AdminShiftLoading(ui: isRefresh ? state.ui : AdminShiftUi.empty));

    try {
      final ui = await _repository.getAssignments();
      if (isClosed) return;
      emit(AdminShiftLoaded(ui: ui));
    } catch (e) {
      if (isClosed) return;
      final msg = e is AdminShiftFailure
          ? e.message
          : 'Failed to load shift assignments. Please try again.';
      emit(AdminShiftFailureState(ui: state.ui, message: msg));
    }
  }
}
