class EmployeeShiftModel {
  const EmployeeShiftModel({
    required this.id,
    required this.shiftType,
    required this.shiftName,
    required this.shiftCategory,
    required this.isBrakeShift,
    required this.isAssigned,
    required this.startTime,
    required this.endTime,
    required this.timeRange,
    required this.description,
    required this.assignedDate,
    this.effectiveFrom,
    this.scheduledChange,
  });

  final String id;
  final String shiftType;
  final String shiftName;
  final String shiftCategory;
  final bool isBrakeShift;
  final bool isAssigned;
  final String startTime;
  final String endTime;
  final String timeRange;
  final String description;
  final DateTime? assignedDate;
  final DateTime? effectiveFrom;
  final ScheduledShiftChangeModel? scheduledChange;

  factory EmployeeShiftModel.fromJson(Map<String, dynamic> json) {
    final scheduledRaw = json['scheduledChange'];
    return EmployeeShiftModel(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      shiftType: json['shiftType']?.toString() ?? '',
      shiftName: json['shiftName']?.toString() ?? '',
      shiftCategory: json['shiftCategory']?.toString() ?? '',
      isBrakeShift: json['isBrakeShift'] as bool? ?? false,
      isAssigned: json['isAssigned'] as bool? ?? false,
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
      timeRange: json['timeRange']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      assignedDate: json['assignedDate'] != null
          ? DateTime.tryParse(json['assignedDate'].toString())
          : null,
      effectiveFrom: json['effectiveFrom'] != null
          ? DateTime.tryParse(json['effectiveFrom'].toString())
          : null,
      scheduledChange: scheduledRaw is Map
          ? ScheduledShiftChangeModel.fromJson(
              Map<String, dynamic>.from(scheduledRaw),
            )
          : null,
    );
  }
}

class ScheduledShiftChangeModel {
  const ScheduledShiftChangeModel({
    required this.shiftType,
    required this.shiftName,
    required this.timeRange,
    this.effectiveFrom,
  });

  final String shiftType;
  final String shiftName;
  final String timeRange;
  final DateTime? effectiveFrom;

  factory ScheduledShiftChangeModel.fromJson(Map<String, dynamic> json) {
    return ScheduledShiftChangeModel(
      shiftType: json['shiftType']?.toString() ?? '',
      shiftName: json['shiftName']?.toString() ?? '',
      timeRange:
          json['selectedTimeRange']?.toString() ??
          json['timeRange']?.toString() ??
          '',
      effectiveFrom: json['effectiveFrom'] != null
          ? DateTime.tryParse(json['effectiveFrom'].toString())
          : null,
    );
  }
}

class MyShiftResponseModel {
  const MyShiftResponseModel({required this.success, required this.data});

  final bool success;
  final EmployeeShiftModel? data;

  factory MyShiftResponseModel.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    return MyShiftResponseModel(
      success: json['success'] as bool? ?? false,
      data: raw is Map<String, dynamic>
          ? EmployeeShiftModel.fromJson(raw)
          : null,
    );
  }
}
