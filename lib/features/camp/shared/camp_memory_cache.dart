import 'package:timelay_health/features/camp/camps/presentation/models/camp_list_ui.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/models/camp_dashboard_ui.dart';
import 'package:timelay_health/features/camp/patients/presentation/models/patient_list_ui.dart';

/// Session-scoped in-memory cache for camp module (stale-while-revalidate).
class CampMemoryCache {
  CampMemoryCache._();

  static const ttl = Duration(minutes: 5);

  static String? _employeeKey;
  static CampDashboardUi? _dashboard;
  static DateTime? _dashboardAt;
  static List<CampItemUi>? _camps;
  static List<CampListStatUi>? _campStats;
  static DateTime? _campsAt;
  static PatientListUi? _patients;
  static DateTime? _patientsAt;

  static void _ensureKey(String employeeName) {
    final key = employeeName.trim().toLowerCase();
    if (_employeeKey == key) return;
    _employeeKey = key;
    clear();
    _employeeKey = key;
  }

  static bool _fresh(DateTime? at) =>
      at != null && DateTime.now().difference(at) < ttl;

  static CampDashboardUi? dashboard(String employeeName) {
    _ensureKey(employeeName);
    return _fresh(_dashboardAt) ? _dashboard : null;
  }

  static void setDashboard(String employeeName, CampDashboardUi data) {
    _ensureKey(employeeName);
    _dashboard = data;
    _dashboardAt = DateTime.now();
  }

  static ({List<CampItemUi> camps, List<CampListStatUi> stats})? camps(
    String employeeName,
  ) {
    _ensureKey(employeeName);
    final camps = _camps;
    final stats = _campStats;
    if (!_fresh(_campsAt) || camps == null || stats == null) return null;
    return (camps: camps, stats: stats);
  }

  static void setCamps(
    String employeeName, {
    required List<CampItemUi> camps,
    required List<CampListStatUi> stats,
  }) {
    _ensureKey(employeeName);
    _camps = camps;
    _campStats = stats;
    _campsAt = DateTime.now();
  }

  static PatientListUi? patients(String employeeName) {
    _ensureKey(employeeName);
    return _fresh(_patientsAt) ? _patients : null;
  }

  static void setPatients(String employeeName, PatientListUi data) {
    _ensureKey(employeeName);
    _patients = data;
    _patientsAt = DateTime.now();
  }

  static void clear() {
    _dashboard = null;
    _dashboardAt = null;
    _camps = null;
    _campStats = null;
    _campsAt = null;
    _patients = null;
    _patientsAt = null;
  }
}
