import 'package:timelay_health/features/issues/data/models/issue_model.dart';
import 'package:timelay_health/features/issues/domain/entities/issue.dart';

class IssueMapper {
  const IssueMapper._();

  static Issue toEntity(IssueModel model) {
    return Issue(
      id: model.id,
      employeeId: model.employeeId,
      employeeName: model.employeeName,
      department: model.department,
      issueTitle: model.issueTitle,
      issueDescription: model.issueDescription,
      issueType: model.issueType,
      priority: model.priority,
      status: model.status,
      adminRemark: model.adminRemark,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  static RaiseIssueRequestModel toRequest(RaiseIssueParams params) {
    return RaiseIssueRequestModel(
      employeeName: params.employeeName,
      department: params.department,
      issueTitle: params.issueTitle,
      issueDescription: params.issueDescription,
      issueType: params.issueType,
      priority: params.priority,
    );
  }
}
