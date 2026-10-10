class Issue {
  const Issue({
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
}

class RaiseIssueParams {
  const RaiseIssueParams({
    required this.employeeId,
    required this.employeeName,
    required this.department,
    required this.issueTitle,
    required this.issueDescription,
    required this.issueType,
    required this.priority,
  });

  final String employeeId;
  final String employeeName;
  final String department;
  final String issueTitle;
  final String issueDescription;
  final String issueType;
  final String priority;
}
