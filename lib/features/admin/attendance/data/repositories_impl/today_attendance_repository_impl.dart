import 'package:timelay_health/features/admin/attendance/data/datasources/attendance_records_remote_datasource.dart';
import 'package:timelay_health/features/admin/attendance/data/datasources/today_attendance_remote_datasource.dart';
import 'package:timelay_health/features/admin/attendance/domain/repositories/today_attendance_repository.dart';
import 'package:timelay_health/features/admin/attendance/presentation/models/today_attendance_ui.dart';

class TodayAttendanceRepositoryImpl implements TodayAttendanceRepository {
  TodayAttendanceRepositoryImpl({
    TodayAttendanceRemoteDataSource? remote,
    AttendanceRecordsRemoteDataSource? attendanceRemote,
  })  : _remote = remote ?? TodayAttendanceRemoteDataSource(),
        _attendanceRemote =
            attendanceRemote ?? AttendanceRecordsRemoteDataSource();

  final TodayAttendanceRemoteDataSource _remote;
  final AttendanceRecordsRemoteDataSource _attendanceRemote;

  static String _currentMonth() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  static String? _recordDateString(Map<String, dynamic> json) {
    final inTimeRaw = json['checkInTime'] ?? json['createdAt'] ?? json['date'];
    if (inTimeRaw == null) return null;
    final dt = DateTime.tryParse(inTimeRaw.toString())?.toLocal();
    if (dt == null) return null;
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  Future<Map<String, Map<String, dynamic>>> _employeeMap(String month) async {
    try {
      final page = await _attendanceRemote.getPageData(
        month: month,
        page: 1,
        limit: 1,
      );
      final employees = page['employees'];
      final map = <String, Map<String, dynamic>>{};
      if (employees is List) {
        for (final e in employees) {
          if (e is Map<String, dynamic>) {
            final id = (e['employeeId'] ?? '').toString();
            if (id.isNotEmpty) map[id] = e;
          }
        }
      }
      return map;
    } catch (_) {
      return const {};
    }
  }

  Map<String, dynamic> _enrichRecord(
    Map<String, dynamic> record,
    Map<String, Map<String, dynamic>> employees,
  ) {
    final id = (record['employeeId'] ?? '').toString();
    final emp = employees[id];
    if (emp == null) return record;
    return {
      ...record,
      'employeeDepartment':
          record['employeeDepartment'] ?? emp['department'],
      'employeeDesignation':
          record['employeeDesignation'] ?? emp['designation'],
      'employeeName': record['employeeName'] ?? emp['name'] ?? record['name'],
      'employeeProfilePicture':
          record['employeeProfilePicture'] ?? emp['profilePicture'],
      'department': record['department'] ?? emp['department'],
      'designation': record['designation'] ?? emp['designation'],
    };
  }

  TodayAttendanceUi _toUi(
    List<Map<String, dynamic>> records, {
    List<String> departments = const [],
    List<String> designations = const [],
    int? totalRecords,
    int totalPages = 1,
    int currentPage = 1,
  }) {
    final ui = TodayAttendanceUi.fromJson({'records': records});
    return TodayAttendanceUi(
      totalCheckIn: totalRecords ?? ui.totalCheckIn,
      activeWorking: ui.activeWorking,
      onsiteCount: ui.onsiteCount,
      remoteCount: ui.remoteCount,
      records: ui.records,
      departments: departments.isNotEmpty ? departments : ui.departments,
      designations: designations.isNotEmpty ? designations : ui.designations,
      totalPages: totalPages,
      currentPage: currentPage,
      totalRecords: totalRecords ?? ui.records.length,
    );
  }

  @override
  Future<TodayAttendanceUi> getTodayAttendance() async {
    final raw = await _remote.getTodayAttendance();
    final employees = await _employeeMap(_currentMonth());
    final records = <Map<String, dynamic>>[];
    final rawRecords = raw['records'];
    if (rawRecords is List) {
      for (final r in rawRecords) {
        if (r is Map<String, dynamic>) {
          records.add(_enrichRecord(r, employees));
        }
      }
    }

    final depts = <String>{};
    final desigs = <String>{};
    for (final e in employees.values) {
      final d = (e['department'] ?? '').toString().trim();
      final g = (e['designation'] ?? '').toString().trim();
      if (d.isNotEmpty) depts.add(d);
      if (g.isNotEmpty) desigs.add(g);
    }

    return _toUi(
      records,
      departments: depts.toList(),
      designations: desigs.toList(),
      totalRecords: records.length,
      totalPages: 1,
      currentPage: 1,
    );
  }

  @override
  Future<TodayAttendanceUi> getByMonth({
    required String month,
    String? date,
    int page = 1,
    int limit = 15,
  }) async {
    final hasDate = date != null && date.trim().isNotEmpty;

    if (hasDate) {
      final all = <Map<String, dynamic>>[];
      var p = 1;
      var totalPages = 1;
      List<String> metaDepts = const [];
      List<String> metaDesigs = const [];

      do {
        final raw = await _attendanceRemote.getPageData(
          month: month,
          page: p,
          limit: 100,
        );
        final meta = raw['meta'];
        if (meta is Map<String, dynamic>) {
          totalPages = (meta['totalPages'] as num?)?.toInt() ?? 1;
          if (meta['departments'] is List) {
            metaDepts = (meta['departments'] as List)
                .where((e) => e != null)
                .map((e) => e.toString())
                .toList();
          }
          if (meta['designations'] is List) {
            metaDesigs = (meta['designations'] as List)
                .where((e) => e != null)
                .map((e) => e.toString())
                .toList();
          }
        }
        final recs = raw['records'];
        if (recs is List) {
          for (final r in recs) {
            if (r is Map<String, dynamic>) all.add(r);
          }
        }
        p++;
      } while (p <= totalPages && p <= 50);

      final filtered =
          all.where((r) => _recordDateString(r) == date.trim()).toList();
      return _toUi(
        filtered,
        departments: metaDepts,
        designations: metaDesigs,
        totalRecords: filtered.length,
        totalPages: 1,
        currentPage: 1,
      );
    }

    final raw = await _attendanceRemote.getPageData(
      month: month,
      page: page,
      limit: limit,
    );

    List<String> metaDepts = const [];
    List<String> metaDesigs = const [];
    var totalPages = 1;
    var totalRecords = 0;
    var onsiteEntries = 0;
    var activeCheckedIn = 0;
    final currentPage = page;
    final meta = raw['meta'];
    if (meta is Map<String, dynamic>) {
      totalPages = (meta['totalPages'] as num?)?.toInt() ?? 1;
      totalRecords = (meta['totalRecords'] as num?)?.toInt() ?? 0;
      if (meta['departments'] is List) {
        metaDepts = (meta['departments'] as List)
            .where((e) => e != null)
            .map((e) => e.toString())
            .toList();
      }
      if (meta['designations'] is List) {
        metaDesigs = (meta['designations'] as List)
            .where((e) => e != null)
            .map((e) => e.toString())
            .toList();
      }
    }
    final stats = raw['stats'];
    if (stats is Map<String, dynamic>) {
      totalRecords =
          (stats['totalRecords'] as num?)?.toInt() ?? totalRecords;
      onsiteEntries = (stats['onsiteEntries'] as num?)?.toInt() ?? 0;
      activeCheckedIn = (stats['activeCheckedIn'] as num?)?.toInt() ?? 0;
    }

    final records = <Map<String, dynamic>>[];
    final recs = raw['records'];
    if (recs is List) {
      for (final r in recs) {
        if (r is Map<String, dynamic>) records.add(r);
      }
    }
    if (totalRecords <= 0) totalRecords = records.length;

    final ui = _toUi(
      records,
      departments: metaDepts,
      designations: metaDesigs,
      totalRecords: totalRecords,
      totalPages: totalPages,
      currentPage: currentPage,
    );

    return ui.copyWith(
      totalCheckIn: totalRecords,
      activeWorking: activeCheckedIn > 0 ? activeCheckedIn : ui.activeWorking,
      onsiteCount: onsiteEntries > 0 ? onsiteEntries : ui.onsiteCount,
      remoteCount: totalRecords > 0
          ? (totalRecords - onsiteEntries).clamp(0, totalRecords)
          : ui.remoteCount,
    );
  }
}
