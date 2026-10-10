import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelay_health/features/auth/data/auth_session.dart';
import 'package:timelay_health/features/payslips/data/repositories_impl/payslip_repository_impl.dart';
import 'package:timelay_health/features/payslips/domain/failures/payslip_failure.dart';
import 'package:timelay_health/features/payslips/domain/usecases/get_salary_summary_usecase.dart';
import 'package:timelay_health/features/payslips/presentation/bloc/payslips_state.dart';
import 'package:timelay_health/features/payslips/presentation/models/payslip_ui_model.dart';

class PayslipsCubit extends Cubit<PayslipsState> {
  PayslipsCubit({GetSalarySummaryUseCase? getSalarySummaryUseCase})
    : _getSummary =
          getSalarySummaryUseCase ??
          GetSalarySummaryUseCase(PayslipRepositoryImpl()),
      super(PayslipsInitial());

  final GetSalarySummaryUseCase _getSummary;

  String _search = '';

  Future<void> load({DateTime? date, bool keepExisting = false}) async {
    final selected = date ?? state.selectedDate;
    emit(
      PayslipsLoading(
        selectedDate: selected,
        payslip: keepExisting ? state.payslip : null,
        stats: keepExisting ? state.stats : PayslipStatsUiModel.empty,
        search: _search,
      ),
    );

    final employee = AuthSession.currentEmployee ?? await AuthSession.load();
    if (isClosed) return;

    final pathId = (employee?.id.trim().isNotEmpty == true)
        ? employee!.id.trim()
        : (employee?.employeeId.trim() ?? '');

    if (pathId.isEmpty) {
      emit(
        PayslipsFailureState(
          'Employee ID missing. Please login again.',
          selectedDate: selected,
          payslip: keepExisting ? state.payslip : null,
          stats: keepExisting ? state.stats : PayslipStatsUiModel.empty,
          search: _search,
        ),
      );
      return;
    }

    try {
      final summary = await _getSummary(employeeId: pathId, month: selected);
      if (isClosed) return;
      final month = summary.months.isEmpty ? null : summary.months.first;
      emit(
        PayslipsLoaded(
          selectedDate: selected,
          payslip: month == null
              ? PayslipUiMapper.empty(selected)
              : PayslipUiMapper.fromMonth(month, selected),
          stats: PayslipUiMapper.statsFrom(summary),
          search: _search,
        ),
      );
    } on PayslipFailure catch (e) {
      if (isClosed) return;
      emit(
        PayslipsFailureState(
          e.message,
          selectedDate: selected,
          payslip: keepExisting ? state.payslip : null,
          stats: keepExisting ? state.stats : PayslipStatsUiModel.empty,
          search: _search,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        PayslipsFailureState(
          'Failed to load payslip. Please try again.',
          selectedDate: selected,
          payslip: keepExisting ? state.payslip : null,
          stats: keepExisting ? state.stats : PayslipStatsUiModel.empty,
          search: _search,
        ),
      );
    }
  }

  void setSearch(String value) {
    _search = value;
    final current = state;
    if (current is PayslipsLoaded) {
      emit(
        PayslipsLoaded(
          selectedDate: current.selectedDate,
          payslip: current.payslip,
          stats: current.stats,
          search: _search,
        ),
      );
    } else if (current is PayslipsFailureState) {
      emit(
        PayslipsFailureState(
          current.message,
          selectedDate: current.selectedDate,
          payslip: current.payslip,
          stats: current.stats,
          search: _search,
        ),
      );
    }
  }

  Future<void> selectMonth(DateTime month) {
    final now = DateTime.now();
    final isCurrent = month.year == now.year && month.month == now.month;
    final date = isCurrent
        ? DateTime(now.year, now.month, now.day)
        : DateTime(month.year, month.month, 14);
    return load(date: date, keepExisting: true);
  }

  Future<void> selectCurrentMonth() {
    final now = DateTime.now();
    return load(
      date: DateTime(now.year, now.month, now.day),
      keepExisting: true,
    );
  }

  bool matchesSearch(PayslipUiModel? payslip) {
    final q = _search.trim().toLowerCase();
    if (q.isEmpty || payslip == null) return true;
    return payslip.monthLabel.toLowerCase().contains(q) ||
        payslip.name.toLowerCase().contains(q) ||
        payslip.employeeCode.toLowerCase().contains(q);
  }
}
