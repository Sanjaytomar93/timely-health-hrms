import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelay_health/features/admin/employees/data/repositories_impl/employee_list_repository_impl.dart';
import 'package:timelay_health/features/admin/employees/domain/failures/employee_list_failure.dart';
import 'package:timelay_health/features/admin/employees/domain/usecases/get_employee_list_usecase.dart';
import 'package:timelay_health/features/admin/employees/presentation/bloc/employee_list_state.dart';

class EmployeeListCubit extends Cubit<EmployeeListState> {
  EmployeeListCubit({GetEmployeeListUseCase? useCase})
      : _useCase =
            useCase ?? GetEmployeeListUseCase(EmployeeListRepositoryImpl()),
        super(const EmployeeListInitial());

  final GetEmployeeListUseCase _useCase;

  Future<void> load({bool isRefresh = false}) async {
    final current = state.ui;
    emit(EmployeeListLoading(currentUi: isRefresh ? current : null));

    try {
      final ui = await _useCase();
      if (isClosed) return;
      emit(EmployeeListLoaded(ui));
    } on EmployeeListFailure catch (e) {
      if (isClosed) return;
      emit(EmployeeListFailureState(
        e.message,
        currentUi: current.employees.isNotEmpty ? current : null,
      ));
    } catch (_) {
      if (isClosed) return;
      emit(EmployeeListFailureState(
        'Failed to load employee list. Please check your connection and try again.',
        currentUi: current.employees.isNotEmpty ? current : null,
      ));
    }
  }
}
