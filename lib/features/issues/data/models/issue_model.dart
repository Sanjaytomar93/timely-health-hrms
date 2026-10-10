class IssueModel {
  const IssueModel({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.department,
    required this.issueTitle,
    required this.issueDescription,
    required this.issueType,
    required this.priority,
    required this.status,
    required this.adminRemark,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String employeeId;
  final String employeeName;
  final String department;
  final String issueTitle;
  final String issueDescription;
  final String issueType;
  final String priority;
  final String status;
  final String adminRemark;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory IssueModel.fromJson(Map<String, dynamic> json) {
    return IssueModel(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      employeeId: json['employeeId'] as String? ?? '',
      employeeName: json['employeeName'] as String? ?? '',
      department: json['department'] as String? ?? '',
      issueTitle: json['issueTitle'] as String? ?? '',
      issueDescription: json['issueDescription'] as String? ?? '',
      issueType: json['issueType'] as String? ?? '',
      priority: json['priority'] as String? ?? '',
      status: json['status'] as String? ?? '',
      adminRemark: json['adminRemark'] as String? ?? '',
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }
}

class RaiseIssueRequestModel {
  const RaiseIssueRequestModel({
    required this.employeeName,
    required this.department,
    required this.issueTitle,
    required this.issueDescription,
    required this.issueType,
    required this.priority,
  });

  final String employeeName;
  final String department;
  final String issueTitle;
  final String issueDescription;
  final String issueType;
  final String priority;

  Map<String, dynamic> toJson() => {
    'employeeName': employeeName,
    'department': department,
    'issueTitle': issueTitle,
    'issueDescription': issueDescription,
    'issueType': issueType,
    'priority': priority,
  };
}

class RaiseIssueResponseModel {
  const RaiseIssueResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool success;
  final String message;
  final IssueModel data;

  factory RaiseIssueResponseModel.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    if (raw is! Map<String, dynamic>) {
      throw const FormatException('Missing issue data');
    }
    return RaiseIssueResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: IssueModel.fromJson(raw),
    );
  }
}

class MyIssuesResponseModel {
  const MyIssuesResponseModel({required this.success, required this.data});

  final bool success;
  final List<IssueModel> data;

  factory MyIssuesResponseModel.fromJson(Map<String, dynamic> json) {
    final raw = json['data'] ?? json['issues'] ?? json['records'];
    final list = <IssueModel>[];
    if (raw is List) {
      for (final item in raw) {
        if (item is Map<String, dynamic>) {
          list.add(IssueModel.fromJson(item));
        }
      }
    } else if (raw is Map<String, dynamic>) {
      final nested = raw['issues'] ?? raw['data'];
      if (nested is List) {
        for (final item in nested) {
          if (item is Map<String, dynamic>) {
            list.add(IssueModel.fromJson(item));
          }
        }
      }
    }
    return MyIssuesResponseModel(
      success: json['success'] as bool? ?? true,
      data: list,
    );
  }
}

DateTime? _parseDate(dynamic value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value);
}
