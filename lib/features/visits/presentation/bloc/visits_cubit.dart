import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:timelay_health/core/location/location_helper.dart';
import 'package:timelay_health/features/auth/data/auth_session.dart';
import 'package:timelay_health/features/visits/data/repositories_impl/visit_repository_impl.dart';
import 'package:timelay_health/features/visits/domain/entities/visit.dart';
import 'package:timelay_health/features/visits/domain/failures/visit_failure.dart';
import 'package:timelay_health/features/visits/domain/usecases/add_visit_usecase.dart';
import 'package:timelay_health/features/visits/domain/usecases/delete_visit_usecase.dart';
import 'package:timelay_health/features/visits/domain/usecases/get_my_visits_usecase.dart';
import 'package:timelay_health/features/visits/domain/usecases/update_visit_usecase.dart';
import 'package:timelay_health/features/visits/presentation/bloc/visits_state.dart';
import 'package:timelay_health/features/visits/presentation/models/visit_ui_model.dart';

class VisitsCubit extends Cubit<VisitsState> {
  VisitsCubit({
    GetMyVisitsUseCase? getMyVisitsUseCase,
    AddVisitUseCase? addVisitUseCase,
    UpdateVisitUseCase? updateVisitUseCase,
    DeleteVisitUseCase? deleteVisitUseCase,
  }) : _getMyVisits =
           getMyVisitsUseCase ?? GetMyVisitsUseCase(VisitRepositoryImpl()),
       _addVisit = addVisitUseCase ?? AddVisitUseCase(VisitRepositoryImpl()),
       _updateVisit =
           updateVisitUseCase ?? UpdateVisitUseCase(VisitRepositoryImpl()),
       _deleteVisit =
           deleteVisitUseCase ?? DeleteVisitUseCase(VisitRepositoryImpl()),
       super(VisitsInitial());

  final GetMyVisitsUseCase _getMyVisits;
  final AddVisitUseCase _addVisit;
  final UpdateVisitUseCase _updateVisit;
  final DeleteVisitUseCase _deleteVisit;

  List<VisitUiModel> _all = const [];
  List<String> _monthOptions = const ['All Months'];
  String _search = '';
  String _status = 'All Status';
  String _month = VisitUiMapper.monthLabel(DateTime.now()) ?? 'All Months';

  Future<void> load({bool keepExisting = false}) async {
    emit(
      VisitsLoading(
        visits: keepExisting ? state.visits : const [],
        allVisits: keepExisting ? _all : const [],
        stats: keepExisting ? state.stats : VisitStatsUiModel.empty,
        search: _search,
        status: _status,
        month: _month,
        monthOptions: keepExisting ? _monthOptions : const ['All Months'],
      ),
    );

    final employeeId =
        AuthSession.currentEmployee?.employeeId ??
        (await AuthSession.load())?.employeeId ??
        '';

    if (isClosed) return;
    if (employeeId.isEmpty) {
      emit(
        VisitsFailureState(
          'Employee ID missing. Please login again.',
          visits: keepExisting ? state.visits : const [],
          allVisits: keepExisting ? _all : const [],
          stats: keepExisting ? state.stats : VisitStatsUiModel.empty,
          search: _search,
          status: _status,
          month: _month,
          monthOptions: _monthOptions,
        ),
      );
      return;
    }

    try {
      final visits = await _getMyVisits(employeeId);
      if (isClosed) return;
      _all = VisitUiMapper.toUiList(visits);
      _monthOptions = _buildMonthOptions(_all);
      final current = VisitUiMapper.monthLabel(DateTime.now()) ?? 'All Months';
      if (!_monthOptions.contains(_month)) {
        _month = _monthOptions.contains(current) ? current : 'All Months';
      }
      _emitFiltered();
    } on VisitFailure catch (e) {
      if (isClosed) return;
      emit(
        VisitsFailureState(
          e.message,
          visits: keepExisting ? state.visits : const [],
          allVisits: keepExisting ? _all : const [],
          stats: keepExisting ? state.stats : VisitStatsUiModel.empty,
          search: _search,
          status: _status,
          month: _month,
          monthOptions: _monthOptions,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        VisitsFailureState(
          'Failed to load visits. Please try again.',
          visits: keepExisting ? state.visits : const [],
          allVisits: keepExisting ? _all : const [],
          stats: keepExisting ? state.stats : VisitStatsUiModel.empty,
          search: _search,
          status: _status,
          month: _month,
          monthOptions: _monthOptions,
        ),
      );
    }
  }

  void setSearch(String value) {
    _search = value;
    _emitFiltered();
  }

  void setStatus(String value) {
    _status = value;
    _emitFiltered();
  }

  void setMonth(String value) {
    _month = value;
    _emitFiltered();
  }

  VisitStatsUiModel statsForMonth(String monthLabel) {
    if (monthLabel == 'All Months') {
      return VisitUiMapper.toStatsFromUi(_all);
    }
    final filtered = _all.where((v) {
      return VisitUiMapper.monthLabel(v.createdAt) == monthLabel;
    }).toList();
    return VisitUiMapper.toStatsFromUi(filtered);
  }

  Future<void> addVisit({
    required String centerName,
    required String clientName,
    required String contact,
    required String address,
    required String addressLink,
    required String status,
    required String remarks,
  }) async {
    final employeeId = await _requireEmployeeId();
    final position = await _captureLocation();

    await _addVisit(
      AddVisitParams(
        employeeId: employeeId,
        centerName: centerName.trim(),
        clientName: clientName.trim(),
        contact: contact.trim(),
        address: address.trim(),
        addressLink: addressLink.trim(),
        status: status.trim(),
        remarks: remarks.trim(),
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
      ),
    );

    await load(keepExisting: true);
  }

  Future<void> updateVisit({
    required String id,
    required String centerName,
    required String clientName,
    required String contact,
    required String address,
    required String addressLink,
    required String status,
    required String remarks,
  }) async {
    final employeeId = await _requireEmployeeId();
    final position = await _captureLocation();

    await _updateVisit(
      UpdateVisitParams(
        id: id,
        employeeId: employeeId,
        centerName: centerName.trim(),
        clientName: clientName.trim(),
        contact: contact.trim(),
        address: address.trim(),
        addressLink: addressLink.trim(),
        status: status.trim(),
        remarks: remarks.trim(),
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
      ),
    );

    await load(keepExisting: true);
  }

  Future<void> deleteVisit(String id) async {
    if (id.trim().isEmpty) {
      throw const VisitFailure('Visit ID missing.');
    }
    await _deleteVisit(id);
    await load(keepExisting: true);
  }

  Future<String> _requireEmployeeId() async {
    final employeeId =
        AuthSession.currentEmployee?.employeeId ??
        (await AuthSession.load())?.employeeId ??
        '';
    if (employeeId.isEmpty) {
      throw const VisitFailure('Employee ID missing. Please login again.');
    }
    return employeeId;
  }

  Future<Position> _captureLocation() async {
    try {
      return await LocationHelper.getCurrentPosition();
    } on LocationFailure catch (e) {
      throw VisitFailure(e.message);
    }
  }

  void _emitFiltered() {
    final filtered = _applyFilters(_all);
    emit(
      VisitsLoaded(
        visits: filtered,
        allVisits: _all,
        stats: VisitUiMapper.toStatsFromUi(filtered),
        search: _search,
        status: _status,
        month: _month,
        monthOptions: _monthOptions,
      ),
    );
  }

  List<VisitUiModel> _applyFilters(List<VisitUiModel> source) {
    final q = _search.trim().toLowerCase();
    return source.where((v) {
      if (q.isNotEmpty) {
        final hay =
            '${v.center} ${v.contact} ${v.phone} ${v.address} ${v.remark}'
                .toLowerCase();
        if (!hay.contains(q)) return false;
      }
      if (_status != 'All Status' &&
          v.status.toLowerCase() != _status.toLowerCase()) {
        return false;
      }
      if (_month != 'All Months') {
        final label = VisitUiMapper.monthLabel(v.createdAt);
        if (label != _month) return false;
      }
      return true;
    }).toList();
  }

  List<String> _buildMonthOptions(List<VisitUiModel> visits) {
    final seen = <String>{};
    final months = <String>[];
    final current = VisitUiMapper.monthLabel(DateTime.now());
    if (current != null) {
      seen.add(current);
      months.add(current);
    }
    for (final v in visits) {
      final label = VisitUiMapper.monthLabel(v.createdAt);
      if (label != null && seen.add(label)) {
        months.add(label);
      }
    }
    return ['All Months', ...months];
  }
}
