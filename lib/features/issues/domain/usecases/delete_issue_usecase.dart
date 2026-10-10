import 'package:timelay_health/features/issues/domain/repositories/issue_repository.dart';

class DeleteIssueUseCase {
  const DeleteIssueUseCase(this._repository);

  final IssueRepository _repository;

  Future<void> call(String issueId) {
    return _repository.deleteIssue(issueId: issueId);
  }
}
