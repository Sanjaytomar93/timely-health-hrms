class AttendanceRecordModel {
  const AttendanceRecordModel({
    required this.id,
    required this.employeeId,
    required this.name,
    required this.employeeEmail,
    required this.checkInTime,
    required this.status,
    required this.totalBreakMinutes,
    required this.totalHours,
    required this.workingHours,
    required this.assignedShiftHours,
    required this.otHours,
    required this.otAmount,
    required this.otMultiplier,
    required this.latitude,
    required this.longitude,
    required this.distance,
    required this.onsite,
    required this.officeName,
    required this.reason,
    required this.comment,
    this.checkOutTime,
  });

  final String id;
  final String employeeId;
  final String name;
  final String employeeEmail;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final String status;
  final double totalBreakMinutes;
  final double totalHours;
  final double workingHours;
  final double assignedShiftHours;
  final double otHours;
  final double otAmount;
  final double otMultiplier;
  final double latitude;
  final double longitude;
  final double distance;
  final bool onsite;
  final String officeName;
  final String reason;
  final String comment;

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    return AttendanceRecordModel(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      employeeId: json['employeeId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      employeeEmail: json['employeeEmail'] as String? ?? '',
      checkInTime: _parseDate(json['checkInTime']),
      checkOutTime: _parseDate(json['checkOutTime']),
      status: json['status'] as String? ?? '',
      totalBreakMinutes: _asDouble(json['totalBreakMinutes']),
      totalHours: _asDouble(json['totalHours']),
      workingHours: _asDouble(json['workingHours']),
      assignedShiftHours: _asDouble(json['assignedShiftHours']),
      otHours: _asDouble(json['otHours']),
      otAmount: _asDouble(json['otAmount']),
      otMultiplier: _asDouble(json['otMultiplier']),
      latitude: _asDouble(json['latitude']),
      longitude: _asDouble(json['longitude']),
      distance: _asDouble(json['distance']),
      onsite: json['onsite'] as bool? ?? false,
      officeName: json['officeName'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      comment: json['comment'] as String? ?? '',
    );
  }
}

class AttendanceStatsModel {
  const AttendanceStatsModel({
    required this.totalRecords,
    required this.onsiteDays,
    required this.checkedIn,
    required this.fullDays,
    required this.otHours,
    required this.otHoursFormatted,
    required this.claimedOT,
  });

  final int totalRecords;
  final int onsiteDays;
  final int checkedIn;
  final int fullDays;
  final double otHours;
  final String otHoursFormatted;
  final int claimedOT;

  factory AttendanceStatsModel.fromJson(Map<String, dynamic> json) {
    return AttendanceStatsModel(
      totalRecords: _asDouble(json['totalRecords']).round(),
      onsiteDays: _asDouble(json['onsiteDays']).round(),
      checkedIn: _asDouble(json['checkedIn']).round(),
      fullDays: _asDouble(json['fullDays']).round(),
      otHours: _asDouble(json['otHours']),
      otHoursFormatted: json['otHoursFormatted']?.toString() ?? '',
      claimedOT: _asDouble(json['claimedOT']).round(),
    );
  }
}

class MyAttendanceResponseModel {
  const MyAttendanceResponseModel({
    required this.message,
    required this.employeeName,
    required this.records,
    this.claimedAttendanceIds = const {},
    this.stats,
  });

  final String message;
  final String employeeName;
  final List<AttendanceRecordModel> records;
  final Set<String> claimedAttendanceIds;
  final AttendanceStatsModel? stats;

  factory MyAttendanceResponseModel.fromJson(Map<String, dynamic> json) {
    final raw = json['records'];
    final list = raw is List
        ? raw
              .whereType<Map>()
              .map(
                (e) => AttendanceRecordModel.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList()
        : <AttendanceRecordModel>[];
    final rawStats = json['stats'];
    final rawClaims = json['claims'];
    final claimedIds = <String>{
      if (rawClaims is List)
        for (final claim in rawClaims.whereType<Map>())
          if (_claimAttendanceId(claim) case final id? when id.isNotEmpty) id,
    };
    return MyAttendanceResponseModel(
      message: json['message']?.toString() ?? '',
      employeeName: json['employeeName'] as String? ?? '',
      records: list,
      claimedAttendanceIds: claimedIds,
      stats: rawStats is Map
          ? AttendanceStatsModel.fromJson(Map<String, dynamic>.from(rawStats))
          : null,
    );
  }
}

String? _claimAttendanceId(Map claim) {
  final raw = claim['attendanceId'];
  if (raw is Map) return (raw['_id'] ?? raw['id'])?.toString();
  return raw?.toString();
}

DateTime? _parseDate(dynamic value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value);
}

double _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}
