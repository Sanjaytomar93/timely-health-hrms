class LeaveRecordModel {
  const LeaveRecordModel({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.leaveType,
    required this.days,
    required this.reason,
    required this.status,
    required this.isConvertedToCompOff,
    this.startDate,
    this.endDate,
    this.appliedDate,
    this.approvedBy,
    this.approvedByRole,
    this.approvedDate,
  });

  final String id;
  final String employeeId;
  final String employeeName;
  final String leaveType;
  final DateTime? startDate;
  final DateTime? endDate;
  final double days;
  final String reason;
  final String status;
  final bool isConvertedToCompOff;
  final DateTime? appliedDate;
  final String? approvedBy;
  final String? approvedByRole;
  final DateTime? approvedDate;

  factory LeaveRecordModel.fromJson(Map<String, dynamic> json) {
    return LeaveRecordModel(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      employeeId: json['employeeId']?.toString() ?? '',
      employeeName: json['employeeName']?.toString() ?? '',
      leaveType: json['leaveType']?.toString() ?? '',
      startDate: _parseDate(json['startDate']),
      endDate: _parseDate(json['endDate']),
      days: _asDouble(json['days']),
      reason: json['reason']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      isConvertedToCompOff: json['isConvertedToCompOff'] as bool? ?? false,
      appliedDate: _parseDate(json['appliedDate']),
      approvedBy: json['approvedBy']?.toString(),
      approvedByRole: json['approvedByRole']?.toString(),
      approvedDate: _parseDate(json['approvedDate']),
    );
  }
}

class AddLeaveRequestModel {
  const AddLeaveRequestModel({
    required this.employeeId,
    required this.employeeName,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.days,
    required this.reason,
  });

  final String employeeId;
  final String employeeName;
  final String leaveType;
  final String startDate;
  final String endDate;
  final int days;
  final String reason;

  Map<String, dynamic> toJson() => {
    'employeeId': employeeId,
    'employeeName': employeeName,
    'leaveType': leaveType,
    'startDate': startDate,
    'endDate': endDate,
    'days': days,
    'reason': reason,
  };
}

class AddLeaveResponseModel {
  const AddLeaveResponseModel({required this.message, required this.leave});

  final String message;
  final LeaveRecordModel leave;

  factory AddLeaveResponseModel.fromJson(Map<String, dynamic> json) {
    final raw = json['leave'] ?? json['data'];
    if (raw is! Map<String, dynamic>) {
      throw const FormatException('Missing leave');
    }
    return AddLeaveResponseModel(
      message: json['message']?.toString() ?? '',
      leave: LeaveRecordModel.fromJson(raw),
    );
  }
}

class LeaveStatsModel {
  const LeaveStatsModel({
    required this.totalLeaves,
    required this.approvedLeaves,
    required this.pendingLeaves,
    required this.rejectedLeaves,
    required this.casualLeaves,
    required this.sickLeaves,
    required this.earnedLeaves,
    required this.compOffLeaves,
    required this.weekOffPerMonth,
    required this.totalAssignedDays,
    required this.presentDays,
    required this.absentDays,
    required this.extraDaysWorked,
  });

  final int totalLeaves;
  final int approvedLeaves;
  final int pendingLeaves;
  final int rejectedLeaves;
  final int casualLeaves;
  final int sickLeaves;
  final int earnedLeaves;
  final int compOffLeaves;
  final int weekOffPerMonth;
  final int totalAssignedDays;
  final int presentDays;
  final int absentDays;
  final int extraDaysWorked;

  factory LeaveStatsModel.fromJson(Map<String, dynamic> json) {
    return LeaveStatsModel(
      totalLeaves: _asInt(json['totalLeaves']),
      approvedLeaves: _asInt(json['approvedLeaves']),
      pendingLeaves: _asInt(json['pendingLeaves']),
      rejectedLeaves: _asInt(json['rejectedLeaves']),
      casualLeaves: _asInt(json['casualLeaves']),
      sickLeaves: _asInt(json['sickLeaves']),
      earnedLeaves: _asInt(json['earnedLeaves']),
      compOffLeaves: _asInt(json['compOffLeaves']),
      weekOffPerMonth: _asInt(json['weekOffPerMonth']),
      totalAssignedDays: _asInt(json['totalAssignedDays']),
      presentDays: _asInt(json['presentDays']),
      absentDays: _asInt(json['absentDays']),
      extraDaysWorked: _asInt(json['extraDaysWorked']),
    );
  }
}

class EmployeeLeavesResponseModel {
  const EmployeeLeavesResponseModel({
    required this.success,
    required this.stats,
    required this.records,
  });

  final bool success;
  final LeaveStatsModel stats;
  final List<LeaveRecordModel> records;

  factory EmployeeLeavesResponseModel.fromJson(Map<String, dynamic> json) {
    final raw = json['records'] ?? json['data'];
    final list = raw is List
        ? raw
              .whereType<Map<String, dynamic>>()
              .map(LeaveRecordModel.fromJson)
              .toList()
        : <LeaveRecordModel>[];
    final stats = json['stats'];
    return EmployeeLeavesResponseModel(
      success: json['success'] as bool? ?? true,
      stats: LeaveStatsModel.fromJson(
        stats is Map<String, dynamic> ? stats : const {},
      ),
      records: list,
    );
  }
}

class CompOffRequestModel {
  const CompOffRequestModel({
    required this.id,
    required this.reason,
    required this.count,
    required this.status,
    this.workDate,
    this.leaveDate,
    this.workType,
    this.totalHours,
    this.approvedBy,
    this.createdAt,
  });

  final String id;
  final DateTime? workDate;
  final DateTime? leaveDate;
  final String reason;
  final double count;
  final String? workType;
  final double? totalHours;
  final String status;
  final String? approvedBy;
  final DateTime? createdAt;

  factory CompOffRequestModel.fromJson(Map<String, dynamic> json) {
    final extra = json['extraDayDetails'];
    final details = extra is Map<String, dynamic>
        ? extra
        : const <String, dynamic>{};
    return CompOffRequestModel(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      workDate: _parseDate(json['workDate'] ?? details['date']),
      leaveDate: _parseDate(json['leaveDate']),
      reason: json['reason']?.toString() ?? '',
      count: _asDouble(json['count']),
      workType: details['workType']?.toString(),
      totalHours: details['totalHours'] == null
          ? null
          : _asDouble(details['totalHours']),
      status: json['status']?.toString() ?? '',
      approvedBy: json['approvedBy']?.toString(),
      createdAt: _parseDate(json['createdAt']),
    );
  }
}

class CompOffRequestsResponseModel {
  const CompOffRequestsResponseModel({
    required this.success,
    required this.totalCompOff,
    required this.usedCompOffCount,
    required this.remainingCompOffCount,
    required this.status,
    required this.records,
  });

  final bool success;
  final int totalCompOff;
  final int usedCompOffCount;
  final int remainingCompOffCount;
  final String status;
  final List<CompOffRequestModel> records;

  factory CompOffRequestsResponseModel.fromJson(Map<String, dynamic> json) {
    final raw = json['records'];
    return CompOffRequestsResponseModel(
      success: json['success'] as bool? ?? true,
      totalCompOff: _asInt(json['totalCompOff']),
      usedCompOffCount: _asInt(json['usedCompOffCount']),
      remainingCompOffCount: _asInt(json['remainingCompOffCount']),
      status: json['status']?.toString() ?? '',
      records: raw is List
          ? raw
                .whereType<Map<String, dynamic>>()
                .map(CompOffRequestModel.fromJson)
                .toList()
          : const [],
    );
  }
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

int _asInt(dynamic value) {
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
