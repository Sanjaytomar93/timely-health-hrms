import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelay_health/features/holidays/data/repositories_impl/holiday_repository_impl.dart';
import 'package:timelay_health/features/holidays/domain/failures/holiday_failure.dart';
import 'package:timelay_health/features/holidays/domain/usecases/get_all_holidays_usecase.dart';
import 'package:timelay_health/features/holidays/presentation/bloc/holidays_state.dart';
import 'package:timelay_health/features/holidays/presentation/models/holiday_ui_model.dart';

class HolidaysCubit extends Cubit<HolidaysState> {
  HolidaysCubit({GetAllHolidaysUseCase? getAllHolidaysUseCase})
    : _getAll =
          getAllHolidaysUseCase ??
          GetAllHolidaysUseCase(HolidayRepositoryImpl()),
      super(const HolidaysInitial());

  final GetAllHolidaysUseCase _getAll;

  List<HolidayUiModel> _all = const [];
  HolidayStatsUiModel _stats = HolidayStatsUiModel.empty;
  String _search = '';
  String _type = 'All';
  DateTime? _month;

  Future<void> load({bool keepExisting = false}) async {
    emit(
      HolidaysLoading(
        holidays: keepExisting ? state.holidays : const [],
        allHolidays: keepExisting ? _all : const [],
        stats: keepExisting ? _stats : HolidayStatsUiModel.empty,
        search: _search,
        type: _type,
        month: _month,
      ),
    );

    try {
      final holidays = await _getAll();
      if (isClosed) return;
      _all = HolidayUiMapper.toUiList(holidays);
      _stats = HolidayUiMapper.toStats(holidays);
      _emitFiltered();
    } on HolidayFailure catch (e) {
      if (isClosed) return;
      emit(
        HolidaysFailureState(
          e.message,
          holidays: keepExisting ? state.holidays : const [],
          allHolidays: keepExisting ? _all : const [],
          stats: keepExisting ? _stats : HolidayStatsUiModel.empty,
          search: _search,
          type: _type,
          month: _month,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        HolidaysFailureState(
          'Failed to load holidays. Please try again.',
          holidays: keepExisting ? state.holidays : const [],
          allHolidays: keepExisting ? _all : const [],
          stats: keepExisting ? _stats : HolidayStatsUiModel.empty,
          search: _search,
          type: _type,
          month: _month,
        ),
      );
    }
  }

  void setSearch(String value) {
    _search = value;
    _emitFiltered();
  }

  void setType(String value) {
    _type = value;
    _emitFiltered();
  }

  void setMonth(DateTime? value) {
    _month = value == null ? null : DateTime(value.year, value.month);
    _emitFiltered();
  }

  void _emitFiltered() {
    emit(
      HolidaysLoaded(
        holidays: _applyFilters(_all),
        allHolidays: _all,
        stats: _stats,
        search: _search,
        type: _type,
        month: _month,
      ),
    );
  }

  List<HolidayUiModel> _applyFilters(List<HolidayUiModel> source) {
    final q = _search.trim().toLowerCase();
    final month = _month;
    return source.where((h) {
      if (_type != 'All' && h.type.toLowerCase() != _type.toLowerCase()) {
        return false;
      }
      if (month != null) {
        final d = h.fromDate?.toLocal();
        if (d == null || d.year != month.year || d.month != month.month) {
          return false;
        }
      }
      if (q.isNotEmpty) {
        final hay = '${h.name} ${h.category} ${h.dateRange}'.toLowerCase();
        if (!hay.contains(q)) return false;
      }
      return true;
    }).toList();
  }
}
