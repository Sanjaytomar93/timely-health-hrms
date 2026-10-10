import 'package:timelay_health/features/issues/domain/entities/issue.dart';

abstract class IssueRepository {
  Future<List<Issue>> getMyIssues({required String employeeId});

  Future<Issue> raiseIssue(RaiseIssueParams params);

  Future<Issue> updateIssue({
    required String issueId,
    required RaiseIssueParams params,
  });

  Future<void> deleteIssue({required String issueId});
}
