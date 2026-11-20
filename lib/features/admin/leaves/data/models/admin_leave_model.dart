class AdminLeaveModel {
  const AdminLeaveModel({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.days,
    required this.reason,
    required this.status,
    this.isConvertedToCompOff = false,
    this.appliedDate,
    this.createdAt,
    this.updatedAt,
    this.approvedBy,
    this.approvedByRole,
    this.approvedDate,
    this.compOffId,
    this.convertedDate,
    this.department,
    this.designation,
  });

  final String id;
  final String employeeId;
  final String employeeName;
  final String leaveType;
  final String startDate;
  final String endDate;
  final double days;
  final String reason;
  final String status;
  final bool isConvertedToCompOff;
  final String? appliedDate;
  final String? createdAt;
  final String? updatedAt;
  final String? approvedBy;
  final String? approvedByRole;
  final String? approvedDate;
  final String? compOffId;
  final String? convertedDate;
  final String? department;
  final String? designation;

  factory AdminLeaveModel.fromJson(Map<String, dynamic> json) {
    double parseDays(dynamic v) {
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    return AdminLeaveModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      employeeId: (json['employeeId'] ?? '').toString().trim(),
      employeeName: (json['employeeName'] ?? json['name'] ?? '').toString().trim(),
      leaveType: (json['leaveType'] ?? json['type'] ?? '').toString().trim(),
      startDate: (json['startDate'] ?? json['from'] ?? '').toString().trim(),
      endDate: (json['endDate'] ?? json['to'] ?? '').toString().trim(),
      days: parseDays(json['days']),
      reason: (json['reason'] ?? '').toString().trim(),
      status: (json['status'] ?? 'pending').toString().trim(),
      isConvertedToCompOff: json['isConvertedToCompOff'] == true,
      appliedDate: json['appliedDate']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      approvedBy: json['approvedBy']?.toString(),
      approvedByRole: json['approvedByRole']?.toString(),
      approvedDate: json['approvedDate']?.toString(),
      compOffId: json['compOffId']?.toString(),
      convertedDate: json['convertedDate']?.toString(),
      department: json['department']?.toString(),
      designation: json['designation']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'leaveType': leaveType,
      'startDate': startDate,
      'endDate': endDate,
      'days': days,
      'reason': reason,
      'status': status,
      'isConvertedToCompOff': isConvertedToCompOff,
      'appliedDate': appliedDate,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'approvedBy': approvedBy,
      'approvedByRole': approvedByRole,
      'approvedDate': approvedDate,
      'compOffId': compOffId,
      'convertedDate': convertedDate,
      'department': department,
      'designation': designation,
    };
  }
}
