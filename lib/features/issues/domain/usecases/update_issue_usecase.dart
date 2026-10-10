import 'package:timelay_health/features/issues/domain/entities/issue.dart';
import 'package:timelay_health/features/issues/domain/repositories/issue_repository.dart';

class UpdateIssueUseCase {
  const UpdateIssueUseCase(this._repository);

  final IssueRepository _repository;

  Future<Issue> call({
    required String issueId,
    required RaiseIssueParams params,
  }) {
    return _repository.updateIssue(issueId: issueId, params: params);
  }
}
